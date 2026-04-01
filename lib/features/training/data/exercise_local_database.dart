import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/wger_exercise.dart';

/// Service responsible for managing the local cache of Wger exercises
/// within the centralized application database.
class ExerciseLocalDatabase {
  static const String _tableName = 'local_exercises';

  /// Provides access to the centralized database instance.
  Future<Database> get database async => await DatabaseHelper.instance.database;

  /// Persists a list of exercises into the local cache using a high-performance batch operation.
  Future<void> insertExercises(List<WgerExercise> exercises) async {
    final db = await database;
    final batch = db.batch();

    for (final exercise in exercises) {
      batch.insert(
        _tableName,
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Retrieves all synchronized exercises from the local storage.
  Future<List<WgerExercise>> getAllExercises() async {
    final db = await database;
    final maps = await db.query(_tableName);

    if (maps.isEmpty) return [];

    return maps.map((map) => WgerExercise.fromMap(map)).toList();
  }

  /// Verifies if the local exercise cache contains data.
  Future<bool> hasData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    return (count ?? 0) > 0;
  }
}