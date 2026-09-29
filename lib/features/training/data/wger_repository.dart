import 'package:flutter/foundation.dart';
import '../../../core/network/wger_api_client.dart';
import '../domain/models/wger_exercise.dart';

/// Repository responsible for fetching exercise data from the wger API.
class WgerRepository {
  final WgerApiClient _apiClient;

  WgerRepository({WgerApiClient? apiClient})
      : _apiClient = apiClient ?? WgerApiClient();

  /// Retrieves a list of correctly parsed exercises that contain execution images.
  Future<List<WgerExercise>> getExercises({int limit = 100, int languageId = 2}) async {
    try {
      final response = await _apiClient.get('/exerciseinfo/?language=$languageId&limit=200');
      final List<dynamic> results = response['results'] as List<dynamic>? ?? [];

      final exercises = results.map((json) {
        try {
          return WgerExercise.fromJson(json as Map<String, dynamic>, languageId: languageId);
        } catch (e) {
          return null;
        }
      })
          .whereType<WgerExercise>()
          .where((ex) => ex.name != 'Unnamed Exercise')
          .where((ex) => ex.exerciseImageUrl != null)
          .toList();

      return exercises.take(limit).toList();
    } catch (e) {
      debugPrint('Critical error in WgerRepository: $e');
      rethrow;
    }
  }
}