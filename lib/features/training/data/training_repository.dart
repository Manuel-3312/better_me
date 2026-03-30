import '../../../core/database/database_helper.dart';
import '../domain/models/training.dart';

/// Handles SQLite database operations for the Training entity.
class TrainingRepository {

  /// Retrieves all training plans associated with a specific profile ID.
  /// Returns an empty list if no plans are found.
  Future<List<Training>> getTrainingsByProfile(int idProfile) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'training',
      where: 'id_profile = ?',
      whereArgs: [idProfile],
    );

    return List.generate(maps.length, (i) {
      return Training.fromMap(maps[i]);
    });
  }

  /// Inserts a new training record into the local SQLite database.
  /// Returns the auto-generated ID of the newly inserted training.
  Future<int> createTraining(Training training) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'training',
      training.toMap(),
    );
  }
}