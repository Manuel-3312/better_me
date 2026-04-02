import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/features/training/domain/models/favorite_exercise.dart';

/// Repository handling persistent storage for user-favorited exercises via SQLite,
/// and toggle preferences via SharedPreferences.
class FavoriteExercisesRepository {
  static Database? _database;
  static const String tableName = 'favorite_exercises';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorite_exercises.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_profile INTEGER NOT NULL,
            training_objective TEXT NOT NULL,
            exercise_id INTEGER NOT NULL,
            exercise_data TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addFavorite(FavoriteExercise favorite) async {
    final db = await database;
    await db.insert(tableName, favorite.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(int idProfile, int exerciseId) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id_profile = ? AND exercise_id = ?',
      whereArgs: [idProfile, exerciseId],
    );
  }

  Future<bool> isFavorite(int idProfile, int exerciseId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id_profile = ? AND exercise_id = ?',
      whereArgs: [idProfile, exerciseId],
    );
    return result.isNotEmpty;
  }

  Future<List<FavoriteExercise>> getFavorites(int idProfile, {String? objective}) async {
    final db = await database;
    final whereClause = objective != null ? 'id_profile = ? AND training_objective = ?' : 'id_profile = ?';
    final whereArgs = objective != null ? [idProfile, objective] : [idProfile];

    final result = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
    );
    return result.map((map) => FavoriteExercise.fromMap(map)).toList();
  }

  Future<bool> getIncludeFavoritesPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('include_favorite_exercises') ?? true;
  }

  Future<void> setIncludeFavoritesPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('include_favorite_exercises', value);
  }
}