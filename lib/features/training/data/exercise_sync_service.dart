import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/features/training/data/wger_repository.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';

class ExerciseSyncService {
  final WgerRepository _apiRepo = WgerRepository();
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();

  static const String _lastSyncKey = 'last_wger_sync_timestamp';
  static const int _syncIntervalDays = 15;

  Future<void> syncIfNeeded(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncMs = prefs.getInt(_lastSyncKey) ?? 0;
      final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);

      final now = DateTime.now();
      final difference = now.difference(lastSyncDate).inDays;

      final localExercises = await _localDb.getAllExercises();
      final isDbEmpty = localExercises.isEmpty;

      if (isDbEmpty || difference >= _syncIntervalDays) {
        final int languageId = languageCode == 'es' ? 4 : 2;

        final apiExercises = await _apiRepo.getExercises(
          limit: 150,
          languageId: languageId,
        );

        if (apiExercises.isNotEmpty) {
          await _localDb.insertExercises(apiExercises);
          await prefs.setInt(_lastSyncKey, now.millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      debugPrint('ExerciseSyncService Error: $e');
    }
  }
}
