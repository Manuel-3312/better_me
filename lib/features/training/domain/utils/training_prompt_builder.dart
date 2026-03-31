import '../../../profile/domain/models/profile.dart';
import '../models/training.dart';

/// Utility class responsible for generating highly structured prompts for the AI
/// to create fitness routines. Includes localization constraints.
class TrainingPromptBuilder {
  /// Private constructor to prevent instantiation.
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

  /// Generates the system prompt by merging user biometrics and training preferences.
  /// Enforces a strict JSON output format and restricts the response [language].
  static String buildTrainingPrompt(
    Profile profile,
    Training training,
    String language,
  ) {
    final age = _calculateAge(profile.birthDate);

    return '''
Act as an elite personal trainer.
Create a personalized ${training.maxDays}-day workout routine for a client with the following profile:
- Sex: ${profile.sex}
- Age: $age years old
- Weight: ${profile.weight} kg
- Height: ${profile.height} cm
- Main Objective: ${training.objective}
- Max Session Time: ${training.maxTime.toInt()} minutes per day.

Strict Constraints:
1. You MUST respond ONLY with a valid JSON object. Do NOT include markdown blocks.
2. The entire content inside the JSON (exercise names, focus, descriptions) MUST be written entirely in $language.

The JSON structure must strictly follow this exact schema:
{
  "days": [
    {
      "day": 1,
      "focus": "Upper Body Strength",
      "exercises": [
        {
          "name": "Barbell Bench Press",
          "sets": 4,
          "reps": "8-10",
          "rest_seconds": 90,
          "description": "Keep your core tight and lower the bar slowly to your chest."
        }
      ]
    }
  ]
}
''';
  }
}
