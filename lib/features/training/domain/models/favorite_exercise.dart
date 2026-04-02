import 'dart:convert';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';

/// Represents a user-favorited exercise configuration, linking a [TrainingExercise]
/// to a specific profile and training objective for context-aware AI generation.
class FavoriteExercise {
  final int? id;
  final int idProfile;
  final String trainingObjective;
  final TrainingExercise exercise;

  const FavoriteExercise({
    this.id,
    required this.idProfile,
    required this.trainingObjective,
    required this.exercise,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_profile': idProfile,
      'training_objective': trainingObjective,
      'exercise_id': exercise.exerciseId,
      'exercise_data': jsonEncode(exercise.toJson()),
    };
  }

  factory FavoriteExercise.fromMap(Map<String, dynamic> map) {
    return FavoriteExercise(
      id: map['id'] as int?,
      idProfile: map['id_profile'] as int,
      trainingObjective: map['training_objective'] as String,
      exercise: TrainingExercise.fromJson(jsonDecode(map['exercise_data'] as String)),
    );
  }
}