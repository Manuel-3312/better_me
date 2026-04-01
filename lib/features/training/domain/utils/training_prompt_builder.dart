import '../../../profile/domain/models/profile.dart';
import '../models/training.dart';
import '../models/wger_exercise.dart';

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
  /// and the local database of available exercises.
  static String buildTrainingPrompt(
      Profile profile,
      Training training,
      String language,
      List<WgerExercise> availableExercises,
      ) {
    final age = _calculateAge(profile.birthDate);

    final String exerciseContext = availableExercises
        .map((e) => 'ID: ${e.id} | Name: ${e.name} | Category: ${e.categoryName}')
        .join('\n');

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

The JSON structure must strictly follow this exact schema:
{
  "days": [
    {
      "day": 1,
      "focus": "Upper Body Strength",
      "exercises": [
        {
          "exercise_id": 60,
          "sets": 4,
          "reps": "8-10",
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