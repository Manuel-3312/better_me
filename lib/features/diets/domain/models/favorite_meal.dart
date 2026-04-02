import 'dart:convert';
import 'package:better_me/features/diets/domain/models/ai_diet_plan.dart';

/// Represents a user-favorited meal, linking a [DietMeal] to a specific profile
/// and diet objective to ensure context-aware AI generation.
class FavoriteMeal {
  final int? id;
  final int idProfile;
  final String dietObjective;
  final DietMeal meal;

  const FavoriteMeal({
    this.id,
    required this.idProfile,
    required this.dietObjective,
    required this.meal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_profile': idProfile,
      'diet_objective': dietObjective,
      'meal_name': meal.name,
      'meal_data': jsonEncode(meal.toJson()),
    };
  }

  factory FavoriteMeal.fromMap(Map<String, dynamic> map) {
    return FavoriteMeal(
      id: map['id'] as int?,
      idProfile: map['id_profile'] as int,
      dietObjective: map['diet_objective'] as String,
      meal: DietMeal.fromJson(jsonDecode(map['meal_data'] as String)),
    );
  }
}