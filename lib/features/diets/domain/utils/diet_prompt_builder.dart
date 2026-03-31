import '../../../profile/domain/models/profile.dart';
import '../models/diet.dart';

/// Utility class responsible for generating highly structured prompts for the AI.
/// It ensures the AI receives strict constraints and user context to return safely parseable JSON.
class DietPromptBuilder {
  /// Private constructor to prevent instantiation of this utility class.
  const DietPromptBuilder._();

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

  /// Generates the system prompt by merging user biometrics and dietary preferences.
  /// Enforces a strict JSON output format and restricts the response [language].
  static String buildDietPrompt(
    Profile profile,
    Diet diet, {
    int days = 7,
    required String language,
  }) {
    final age = _calculateAge(profile.birthDate);

    final allergiesContext =
        (diet.allergies != null && diet.allergies!.trim().isNotEmpty)
        ? 'The user has the following allergies or intolerances: ${diet.allergies}. You MUST strictly avoid these ingredients.'
        : 'The user has no known allergies.';

    final additionalContext =
        (diet.additionalData != null && diet.additionalData!.trim().isNotEmpty)
        ? 'Additional user preferences or notes to consider: ${diet.additionalData}.'
        : '';

    return '''
Act as an elite sports nutritionist and expert dietitian.
Create a personalized $days-day meal plan for a client with the following profile:
- Sex: ${profile.sex} - Age: $age years old - Weight: ${profile.weight} kg - Height: ${profile.height} cm
- Main Objective: ${diet.objective}

Strict Dietary Constraints:
1. $allergiesContext
2. $additionalContext
3. You MUST respond ONLY with a valid JSON object. Do NOT include markdown blocks.
4. IMPORTANT: The entire content inside the JSON (meal names, descriptions, and types) MUST be written entirely in $language.

The JSON structure must strictly follow this exact schema:
{
  "days": [
    {
      "day": 1,
      "total_calories": 2100,
      "meals": [
        {
          "type": "Breakfast",
          "name": "Oatmeal with Berries",
          "description": "Description in $language here...",
          "calories": 400
        }
      ]
    }
  ]
}
''';
  }
}
