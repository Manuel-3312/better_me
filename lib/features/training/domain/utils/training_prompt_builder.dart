import 'dart:convert';
import '../../../profile/domain/models/profile.dart';
import '../models/training.dart';
import '../models/wger_exercise.dart';
import '../models/favorite_exercise.dart';

/// Utility class responsible for generating highly structured prompts for the AI
/// to create fitness routines using Retrieval-Augmented Generation (RAG).
class TrainingPromptBuilder {
  const TrainingPromptBuilder._();

  /// Calculates the exact age in years based on the provided [birthDate].
  static int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Generates the system prompt by merging user biometrics, training preferences,
  /// the local database of available exercises, and user's favorite exercises.
  static String buildTrainingPrompt(
      Profile profile,
      Training training,
      String language,
      List<WgerExercise> availableExercises, {
        List<FavoriteExercise> favoriteExercises = const [],
      }) {
    final age = _calculateAge(profile.birthDate);

    final String exerciseContext = availableExercises
        .map(
          (e) => 'ID: ${e.id} | Name: ${e.name} | Category: ${e.categoryName}',
    )
        .join('\n');

    String favoritesContext = '';
    if (favoriteExercises.isNotEmpty) {
      final exercisesJson = jsonEncode(
        favoriteExercises.map((f) => f.exercise.toJson()).toList(),
      );
      favoritesContext =
      '''
The user has a personal library of favorite exercises. You MUST try to prioritize and include these EXACT exercises with their preferred sets/reps if they target the muscle groups planned for the day.
Available Favorite Exercises:
$exercisesJson
''';
    }

    return '''
Act as an elite personal trainer.
Create a personalized ${training.maxDays}-day workout routine for a client with the following profile:
- Sex: ${profile.sex}
- Age: $age years old
- Weight: ${profile.weight} kg
- Height: ${profile.height} cm
- Main Objective: ${training.objective}
- Max Session Time: ${training.maxTime.toInt()} minutes per day.

AVAILABLE EXERCISES DATABASE:
You MUST select exercises EXCLUSIVELY from the following list. Do not invent any exercises.
$exerciseContext

Strict Constraints:
1. You MUST respond ONLY with a valid JSON object. Do NOT include markdown blocks.
2. The entire content inside the JSON (focus, tips) MUST be written entirely in $language.
3. Use the exact "id" from the AVAILABLE EXERCISES DATABASE for the "exercise_id" field.
4. The "focus" field MUST strictly be the names of the muscles worked that day (e.g., "Chest and Triceps", "Back and Biceps", "Legs"). Do NOT use generic names like "Push", "Pull", or "Day 1".
5. The "reps" field MUST always be a strict number or a numerical range (e.g., "10", "8-12", "10-15"). Do NOT use text or words like "to failure" or "max".
6. The "day" field MUST strictly be an integer number (e.g., 1, 2, 3). Do NOT include words like "Day" or "Día" in this field.
$favoritesContext

The JSON structure must strictly follow this exact schema:
{
  "days": [
    {
      "day": 1,
      "focus": "Chest and Triceps",
      "exercises": [
        {
          "exercise_id": 60,
          "sets": 4,
          "reps": "10-12",
          "rest_seconds": 90,
          "tips": "Keep your core tight and lower the bar slowly to your chest."
        }
      ]
    }
  ]
}
''';
  }
}