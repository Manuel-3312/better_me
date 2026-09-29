import 'dart:convert';
import '../../../profile/domain/models/profile.dart';
import '../models/diet.dart';
import '../models/favorite_meal.dart';

/// Utility class responsible for generating highly structured prompts for the AI.
/// It ensures the AI receives strict constraints and user context to return safely parseable JSON.
class DietPromptBuilder {
  const DietPromptBuilder._();

  static int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Generates the system prompt by merging user biometrics, dietary preferences, and favorite meals.
  static String buildDietPrompt(
    Profile profile,
    Diet diet, {
    int days = 7,
    required String language,
    List<FavoriteMeal> favoriteMeals = const [],
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

    String favoritesContext = '';
    if (favoriteMeals.isNotEmpty) {
      final mealsJson = jsonEncode(
        favoriteMeals.map((f) => f.meal.toJson()).toList(),
      );
      favoritesContext =
          '''
The user has a personal Cookbook of favorite meals. You MUST try to include some of these EXACT meals in the plan if they fit the calorie and macro requirements for the daily objective.
Available Favorite Meals:
$mealsJson
''';
    }

    return '''
Act as an elite sports nutritionist and expert chef.
Create a personalized $days-day meal plan for a client with the following profile:
- Sex: ${profile.sex} - Age: $age years old - Weight: ${profile.weight} kg - Height: ${profile.height} cm
- Main Objective: ${diet.objective}

Strict Dietary Constraints:
1. $allergiesContext
2. $additionalContext
3. $favoritesContext
4. You MUST respond ONLY with a valid JSON object. Do NOT include markdown blocks.
5. IMPORTANT: The entire content inside the JSON (meal names, descriptions, ingredients, and preparationSteps) MUST be written entirely in $language.
6. Provide exact measurements (grams, milliliters, etc.) for each ingredient.
7. Provide a clear, step-by-step preparation guide for each meal.
8. The "type" field for each meal MUST be exactly one of the following: "Breakfast", "Lunch", "Snack", or "Dinner" (translating it to $language if necesary). If the meal is a mid-morning or mid-afternoon meal, ALWAYS classify it as "Snack".

The JSON structure must strictly follow this exact schema:
{
  "days": [
    {
      "day": 1,
      "totalCalories": 2100,
      "meals": [
        {
          "type": "Breakfast",
          "name": "Oatmeal with Berries",
          "description": "A high-energy breakfast... (in $language)",
          "calories": 400,
          "macros": {
            "protein": 15,
            "carbs": 60,
            "fats": 8
          },
          "ingredients": [
            "60g rolled oats",
            "150ml almond milk",
            "50g mixed berries"
          ],
          "preparationSteps": [
            "Boil the almond milk in a small pot.",
            "Add the rolled oats and reduce heat.",
            "Stir for 5 minutes until thick.",
            "Top with mixed berries before serving."
          ]
        }
      ]
    }
  ]
}
''';
  }
}
