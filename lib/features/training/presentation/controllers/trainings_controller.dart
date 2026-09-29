import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/utils/training_prompt_builder.dart';
import 'package:better_me/core/network/gemini_service.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/data/favorite_exercises_repository.dart';
import 'package:better_me/features/training/domain/models/favorite_exercise.dart';
import 'package:better_me/features/profile/data/cloud_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Controller responsible for managing the state and business logic of training plans.
class TrainingsController extends ChangeNotifier {
  final TrainingRepository _repository = TrainingRepository();
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();
  final GeminiService _geminiService = GeminiService();
  final FavoriteExercisesRepository _favoritesRepository = FavoriteExercisesRepository();

  List<Training> _trainings = [];
  bool _isLoading = false;
  String? _error;
  Training? _pendingTraining;

  /// Gets the current list of available training plans.
  List<Training> get trainings => _trainings;

  /// Indicates whether a background operation is currently in progress.
  bool get isLoading => _isLoading;

  /// Contains the error message if a recent operation failed.
  String? get error => _error;

  /// Holds the preliminary training configuration while the AI generation is in progress.
  Training? get pendingTraining => _pendingTraining;

  /// Fetches all training plans associated with the specified profile identifier.
  Future<void> loadTrainings(int profileId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trainings = await _repository.getTrainingsByProfile(profileId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Synthesizes a personalized training plan using the generative AI service.
  Future<void> generateTrainingInBackground({
    required Training preliminaryTraining,
    required Profile profile,
    required String languageInstruction,
    required void Function() onSuccess,
    required void Function() onError,
  }) async {
    _pendingTraining = preliminaryTraining;
    notifyListeners();

    try {
      final availableExercises = await _localDb.getAllExercises();
      if (availableExercises.isEmpty) {
        throw Exception('Exercise database is empty.');
      }

      final includeFavs = await _favoritesRepository.getIncludeFavoritesPreference();
      List<FavoriteExercise> targetFavorites = [];

      if (includeFavs) {
        targetFavorites = await _favoritesRepository.getFavorites(
          preliminaryTraining.idProfile,
          objective: preliminaryTraining.objective,
        );
      }

      final prompt = TrainingPromptBuilder.buildTrainingPrompt(
        profile,
        preliminaryTraining,
        languageInstruction,
        availableExercises,
        favoriteExercises: targetFavorites,
      );

      final responseText = await _geminiService.generateContent(prompt);
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty AI response');
      }

      final cleanJsonString = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> jsonMap = jsonDecode(cleanJsonString);
      final aiPlan = AiTrainingPlan.fromJson(jsonMap);

      final finalTraining = Training(
        idProfile: preliminaryTraining.idProfile,
        name: preliminaryTraining.name,
        objective: preliminaryTraining.objective,
        maxDays: preliminaryTraining.maxDays,
        maxTime: preliminaryTraining.maxTime,
        generatedContent: cleanJsonString,
      );

      await _repository.saveFullAiTrainingPlan(finalTraining, aiPlan);
      CloudSyncService().backupPlansToCloud().catchError((e) {
        debugPrint('Error saving routine on Supabase: $e');
      });
      onSuccess();
    } catch (e) {
      debugPrint('Error generating training: $e');
      onError();
    } finally {
      _pendingTraining = null;
      await loadTrainings(preliminaryTraining.idProfile);
    }
  }

  /// Temporarily removes a training plan from the active list.
  void removeTrainingLocally(int index) {
    _trainings.removeAt(index);
    notifyListeners();
  }

  /// Restores a previously removed training plan to the active list.
  void restoreTrainingLocally(int index, Training training) {
    _trainings.insert(index, training);
    notifyListeners();
  }

  /// Permanently deletes a training record from the local database.
  Future<void> deleteTrainingPermanently(int trainingId) async {
    try {
      await _repository.deleteTraining(trainingId);

      await Supabase.instance.client
          .from('training')
          .delete()
          .eq('id_training', trainingId);

    } catch (e) {
      debugPrint('Error deleting training from database: $e');
    }
  }
}