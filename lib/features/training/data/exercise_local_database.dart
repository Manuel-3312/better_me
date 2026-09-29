import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/wger_exercise.dart';

class ExerciseLocalDatabase {
  static const String _tableName = 'local_exercises';

  Future<Database> get database async => await DatabaseHelper.instance.database;

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

  Future<List<WgerExercise>> getAllExercises() async {
    final db = await database;
    final maps = await db.query(_tableName);

    if (maps.isEmpty) return [];

    return maps.map((map) => WgerExercise.fromMap(map)).toList();
  }

  Future<bool> hasData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    return (count ?? 0) > 0;
  }

  Future<void> clearAllExercises() async {
    final db = await database;
    await db.delete(_tableName);
  }
}