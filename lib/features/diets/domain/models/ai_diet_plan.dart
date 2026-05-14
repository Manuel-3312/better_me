/// Represents an AI-generated diet plan containing multiple days.
class AiDietPlan {
  final List<DietDay> days;

  const AiDietPlan({
    required this.days,
  });

  /// Creates an [AiDietPlan] instance from a JSON map.
  factory AiDietPlan.fromJson(Map<String, dynamic> json) {
    var daysList = json['days'] as List? ?? [];
    return AiDietPlan(
      days: daysList.map((dayJson) => DietDay.fromJson(dayJson)).toList(),
    );
  }

  /// Converts the [AiDietPlan] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}

/// Represents a single day within a diet plan, including its meals and calories.
class DietDay {
  final int day;
  final int totalCalories;
  final List<DietMeal> meals;

  const DietDay({
    required this.day,
    required this.totalCalories,
    required this.meals,
  });

  /// Creates a [DietDay] instance from a JSON map.
  factory DietDay.fromJson(Map<String, dynamic> json) {
    var mealsList = json['meals'] as List? ?? [];
    return DietDay(
      day: json['day'] ?? json['dayNumber'] ?? 1,
      totalCalories: json['totalCalories'] ?? 0,
      meals: mealsList.map((mealJson) => DietMeal.fromJson(mealJson)).toList(),
    );
  }

  /// Converts the [DietDay] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'totalCalories': totalCalories,
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }
}

/// Represents a specific meal with its nutritional info, ingredients, and steps.
class DietMeal {
  final String type;
  final String name;
  final String description;
  final int calories;
  final DietMacros macros;
  final List<String> ingredients;
  final List<String> preparationSteps;

  const DietMeal({
    required this.type,
    required this.name,
    required this.description,
    required this.calories,
    required this.macros,
    required this.ingredients,
    required this.preparationSteps,
  });

  /// Creates a [DietMeal] instance from a JSON map.
  factory DietMeal.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List? ?? [];
    var preparationList = json['preparationSteps'] as List? ?? [];

    return DietMeal(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      calories: json['calories'] ?? 0,
      macros: DietMacros.fromJson(json['macros'] ?? {}),
      ingredients: ingredientsList.map((e) => e.toString()).toList(),
      preparationSteps: preparationList.map((e) => e.toString()).toList(),
    );
  }

  /// Converts the [DietMeal] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'calories': calories,
      'macros': macros.toJson(),
      'ingredients': ingredients,
      'preparationSteps': preparationSteps,
    };
  }
}

/// Represents the macronutrient breakdown of a meal (protein, carbs, and fats).
class DietMacros {
  final int protein;
  final int carbs;
  final int fats;

  const DietMacros({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  /// Creates a [DietMacros] instance from a JSON map.
  factory DietMacros.fromJson(Map<String, dynamic> json) {
    return DietMacros(
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
    );
  }

  /// Converts the [DietMacros] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }
}