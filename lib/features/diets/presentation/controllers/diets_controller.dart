import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/cloud_sync_service.dart';
import 'package:better_me/features/diets/data/diet_repository.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/domain/models/ai_diet_plan.dart';
import 'package:better_me/features/diets/domain/utils/diet_prompt_builder.dart';
import 'package:better_me/core/network/gemini_service.dart';
import 'package:better_me/features/diets/data/favorite_meals_repository.dart';
import 'package:better_me/features/diets/domain/models/favorite_meal.dart';

/// Controller managing the state and business logic for user diets.
class DietsController extends ChangeNotifier {
  final DietRepository _repository = DietRepository();
  final GeminiService _geminiService = GeminiService();
  final FavoriteMealsRepository _favoritesRepository = FavoriteMealsRepository();

  List<Diet> _diets = [];
  bool _isLoading = false;
  String? _error;
  Diet? _pendingDiet;

  List<Diet> get diets => _diets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Diet? get pendingDiet => _pendingDiet;

  /// Fetches and loads the list of diets for a specific [profileId].
  Future<void> loadDiets(int profileId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _diets = await _repository.getDietsByProfile(profileId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates a personalized diet plan via AI, saves it locally, and syncs it to the cloud.
  Future<void> generateDietInBackground({
    required Diet preliminaryDiet,
    required Profile profile,
    required String languageInstruction,
    required void Function() onSuccess,
    required void Function() onError,
  }) async {
    _pendingDiet = preliminaryDiet;
    notifyListeners();

    try {
      // Check if user wants to include their favorite meals in the AI prompt.
      final includeFavs = await _favoritesRepository.getIncludeFavoritesPreference();
      List<FavoriteMeal> targetFavorites = [];

      if (includeFavs) {
        targetFavorites = await _favoritesRepository.getFavorites(
          preliminaryDiet.idProfile,
          objective: preliminaryDiet.objective,
        );
      }

      // Build the prompt and request content from Gemini.
      final prompt = DietPromptBuilder.buildDietPrompt(
        profile,
        preliminaryDiet,
        language: languageInstruction,
        favoriteMeals: targetFavorites,
      );

      final responseText = await _geminiService.generateContent(prompt);
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty AI response');
      }

      // Clean and validate the JSON response.
      final cleanJsonString = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> jsonMap = jsonDecode(cleanJsonString);
      AiDietPlan.fromJson(jsonMap); // Throws if JSON structure is invalid.

      // Create the final diet object and save it.
      final finalDiet = Diet(
        idProfile: preliminaryDiet.idProfile,
        name: preliminaryDiet.name,
        objective: preliminaryDiet.objective,
        allergies: preliminaryDiet.allergies,
        additionalData: preliminaryDiet.additionalData,
        generatedContent: cleanJsonString,
      );

      await _repository.saveFullAiDietPlan(finalDiet);

      // Attempt cloud backup silently.
      CloudSyncService().backupPlansToCloud().catchError((e) {
        debugPrint('Error uploading diet to Supabase: $e');
      });

      onSuccess();
    } catch (e) {
      debugPrint('Error generating diet: $e');
      onError();
    } finally {
      _pendingDiet = null;
      await loadDiets(preliminaryDiet.idProfile);
    }
  }

  /// Temporarily removes a diet from the UI list at the given [index].
  void removeDietLocally(int index) {
    _diets.removeAt(index);
    notifyListeners();
  }

  /// Restores a previously removed diet at the given [index] (useful for Undo).
  void restoreDietLocally(int index, Diet diet) {
    _diets.insert(index, diet);
    notifyListeners();
  }

  /// Permanently deletes a diet from both the local database and Supabase.
  Future<void> deleteDietPermanently(int dietId) async {
    try {
      await _repository.deleteDiet(dietId);
      await Supabase.instance.client
          .from('diet')
          .delete()
          .eq('id_diet', dietId);
    } catch (e) {
      debugPrint('Error deleting diet from database: $e');
    }
  }
}