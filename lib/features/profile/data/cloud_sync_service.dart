import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/diets/data/diet_repository.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for synchronizing data between local storage and Supabase cloud.
class CloudSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileRepository _localRepo = ProfileRepository();
  final DietRepository _dietRepo = DietRepository();
  final TrainingRepository _trainingRepo = TrainingRepository();

  /// Uploads local user profiles to the cloud, updating existing ones or inserting new ones.
  Future<void> backupProfilesToCloud() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No auth');

      final localProfiles = await _localRepo.getAllProfiles();

      for (final profile in localProfiles) {
        final profileMap = {
          'user_id': currentUser.id,
          'name': profile.name,
          'sex': profile.sex,
          'weight': profile.weight,
          'height': profile.height,
          'birth_date': profile.birthDate.toIso8601String(),
          'active_diet_id': profile.activeDietId,
          'active_training_id': profile.activeTrainingId,
        };

        final existingCloudProfile = await _supabase
            .from('profile')
            .select('id_profile')
            .eq('user_id', currentUser.id)
            .eq('name', profile.name)
            .maybeSingle();

        if (existingCloudProfile != null) {
          await _supabase
              .from('profile')
              .update(profileMap)
              .eq('id_profile', existingCloudProfile['id_profile']);
        } else {
          await _supabase.from('profile').insert(profileMap);
        }
      }
    } catch (e) {
      debugPrint('Error backing up profiles: $e');
      rethrow;
    }
  }

  /// Downloads profiles from the cloud and saves them locally if they don't already exist.
  Future<void> restoreProfilesFromCloud() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No auth');

      final cloudProfiles = await _supabase
          .from('profile')
          .select()
          .eq('user_id', currentUser.id);

      final localProfiles = await _localRepo.getAllProfiles();

      for (final cloudMap in cloudProfiles) {
        final existsLocally = localProfiles.any(
          (p) => p.name == cloudMap['name'],
        );

        if (!existsLocally) {
          final newProfile = Profile(
            userId: currentUser.id,
            name: cloudMap['name'],
            sex: cloudMap['sex'],
            weight: (cloudMap['weight'] as num).toDouble(),
            height: (cloudMap['height'] as num).toDouble(),
            birthDate: DateTime.parse(cloudMap['birth_date']),
            activeDietId: cloudMap['active_diet_id'],
            activeTrainingId: cloudMap['active_training_id'],
          );
          await _localRepo.createProfile(newProfile);
        }
      }
    } catch (e) {
      debugPrint('Error restoring profiles: $e');
      rethrow;
    }
  }

  /// Uploads local diets and training plans to the cloud.
  Future<void> backupPlansToCloud() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      final localProfiles = await _localRepo.getAllProfiles();

      for (final profile in localProfiles) {
        if (profile.idProfile == null) continue;

        // Backup Diets
        final diets = await _dietRepo.getDietsByProfile(profile.idProfile!);
        for (final diet in diets) {
          final dietMap = {
            'user_id': currentUser.id,
            'profile_name': profile.name,
            'name': diet.name,
            'objective': diet.objective,
            'allergies': diet.allergies,
            'additional_data': diet.additionalData,
            'generated_content': diet.generatedContent,
          };

          final existing = await _supabase
              .from('diet')
              .select('id_diet')
              .eq('user_id', currentUser.id)
              .eq('profile_name', profile.name)
              .eq('name', diet.name)
              .maybeSingle();

          if (existing != null) {
            await _supabase
                .from('diet')
                .update(dietMap)
                .eq('id_diet', existing['id_diet']);
          } else {
            await _supabase.from('diet').insert(dietMap);
          }
        }

        // Backup Trainings
        final trainings = await _trainingRepo.getTrainingsByProfile(
          profile.idProfile!,
        );
        for (final training in trainings) {
          final trainingMap = {
            'user_id': currentUser.id,
            'profile_name': profile.name,
            'name': training.name,
            'objective': training.objective,
            'max_days': training.maxDays,
            'max_time': training.maxTime,
            'generated_content': training.generatedContent,
          };

          debugPrint('Attempting to save training: ${training.name}');

          final existing = await _supabase
              .from('training')
              .select('id_training')
              .eq('user_id', currentUser.id)
              .eq('profile_name', profile.name)
              .eq('name', training.name)
              .maybeSingle();

          if (existing != null) {
            debugPrint('Training already exists, updating...');
            await _supabase
                .from('training')
                .update(trainingMap)
                .eq('id_training', existing['id_training']);
          } else {
            debugPrint('New training, inserting: $trainingMap');
            await _supabase.from('training').insert(trainingMap);
          }
          debugPrint('Training successfully saved in Supabase!');
        }
      }
    } catch (e) {
      debugPrint('=============================================');
      debugPrint('FATAL ERROR SAVING TO SUPABASE:');
      debugPrint(e.toString());
      debugPrint('=============================================');
    }
  }

  /// Downloads diets and training plans from the cloud and saves them locally.
  Future<void> restorePlansFromCloud() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      final localProfiles = await _localRepo.getAllProfiles();

      // Restore Diets
      final cloudDiets = await _supabase
          .from('diet')
          .select()
          .eq('user_id', currentUser.id);
      for (final cloudMap in cloudDiets) {
        final targetProfile = localProfiles
            .where((p) => p.name == cloudMap['profile_name'])
            .firstOrNull;

        if (targetProfile != null && targetProfile.idProfile != null) {
          final localDiets = await _dietRepo.getDietsByProfile(
            targetProfile.idProfile!,
          );
          final exists = localDiets.any((d) => d.name == cloudMap['name']);

          if (!exists) {
            final newDiet = Diet(
              idProfile: targetProfile.idProfile!,
              name: cloudMap['name'],
              objective: cloudMap['objective'],
              allergies: cloudMap['allergies'],
              additionalData: cloudMap['additional_data'],
              generatedContent: cloudMap['generated_content'],
            );
            await _dietRepo.createDiet(newDiet);
          }
        }
      }

      // Restore Trainings
      final cloudTrainings = await _supabase
          .from('training')
          .select()
          .eq('user_id', currentUser.id);
      for (final cloudMap in cloudTrainings) {
        final targetProfile = localProfiles
            .where((p) => p.name == cloudMap['profile_name'])
            .firstOrNull;

        if (targetProfile != null && targetProfile.idProfile != null) {
          final localTrainings = await _trainingRepo.getTrainingsByProfile(
            targetProfile.idProfile!,
          );
          final exists = localTrainings.any((t) => t.name == cloudMap['name']);

          if (!exists) {
            final newTraining = Training(
              idProfile: targetProfile.idProfile!,
              name: cloudMap['name'],
              objective: cloudMap['objective'],
              maxDays: cloudMap['max_days'],
              maxTime: (cloudMap['max_time'] as num).toDouble(),
              generatedContent: cloudMap['generated_content'],
            );
            await _trainingRepo.createTraining(newTraining);
          }
        }
      }
    } catch (e) {
      debugPrint('Error restoring plans: $e');
    }
  }

  /// Replaces the local exercise catalog with the cloud version based on the app's selected language.
  Future<void> syncExerciseCatalog() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString('selected_locale') ?? 'es';
      final targetLanguage = savedLocale.startsWith('en') ? 'en' : 'es';

      final cloudExercises = await _supabase
          .from('exercise_catalog')
          .select()
          .eq('language', targetLanguage);

      final localDb = ExerciseLocalDatabase();

      await localDb.clearAllExercises();

      List<WgerExercise> exercisesToInsert = [];

      for (final cloudMap in cloudExercises) {
        List<int> parsedSecondaryIds = [];
        if (cloudMap['secondary_muscle_ids'] != null) {
          final decodedList =
              jsonDecode(cloudMap['secondary_muscle_ids']) as List;
          parsedSecondaryIds = decodedList.map((e) => e as int).toList();
        }

        final exercise = WgerExercise(
          id: cloudMap['id'] ?? 0,
          name: cloudMap['name'] ?? '',
          description: cloudMap['description'] ?? '',
          categoryId: cloudMap['category_id'] ?? 0,
          categoryName: cloudMap['category_name'] ?? 'Unknown',
          mainMuscleId: cloudMap['main_muscle_id'],
          secondaryMuscleIds: parsedSecondaryIds,
          exerciseImageUrl: cloudMap['exercise_image_url'],
        );
        exercisesToInsert.add(exercise);
      }

      if (exercisesToInsert.isNotEmpty) {
        await localDb.insertExercises(exercisesToInsert);
      }
    } catch (e) {
      debugPrint('Error syncing catalog: $e');
    }
  }

  /// Performs a full data restore from the cloud (profiles, plans, and exercises). Usually called on login.
  Future<void> syncAllDataOnLogin() async {
    try {
      debugPrint('Starting full cloud download...');

      await restoreProfilesFromCloud();
      await restorePlansFromCloud();
      await syncExerciseCatalog();

      debugPrint('Download completed successfully.');
    } catch (e) {
      debugPrint('Error during complete download: $e');
    }
  }

  /// Specifically backs up all local diets to the cloud.
  Future<void> backupDietsToCloud() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final localProfiles = await _localRepo.getAllProfiles();

      for (final profile in localProfiles) {
        if (profile.idProfile == null) continue;

        final localDiets = await _dietRepo.getDietsByProfile(
          profile.idProfile!,
        );

        for (final diet in localDiets) {
          final dietMap = diet.toMap();
          dietMap['user_id'] = currentUser.id;

          await _supabase.from('diet').upsert(dietMap);
        }
      }
    } catch (e) {
      debugPrint('Error syncing diets to the cloud: $e');
    }
  }
}
