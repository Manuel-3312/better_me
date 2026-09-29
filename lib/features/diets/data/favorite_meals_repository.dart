import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/features/diets/domain/models/favorite_meal.dart';

/// Repository handling persistent storage for user-favorited meals via SQLite,
/// and toggle preferences via SharedPreferences.
class FavoriteMealsRepository {
  static Database? _database;
  static const String tableName = 'favorite_meals';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
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
            diet_objective TEXT NOT NULL,
            meal_name TEXT NOT NULL,
            meal_data TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addFavorite(FavoriteMeal favorite) async {
    final db = await database;
    await db.insert(tableName, favorite.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(int idProfile, String mealName) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id_profile = ? AND meal_name = ?',
      whereArgs: [idProfile, mealName],
    );
  }

  Future<bool> isFavorite(int idProfile, String mealName) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id_profile = ? AND meal_name = ?',
      whereArgs: [idProfile, mealName],
    );
    return result.isNotEmpty;
  }

  Future<List<FavoriteMeal>> getFavorites(int idProfile, {String? objective}) async {
    final db = await database;
    final whereClause = objective != null ? 'id_profile = ? AND diet_objective = ?' : 'id_profile = ?';
    final whereArgs = objective != null ? [idProfile, objective] : [idProfile];

    final result = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
    );
    return result.map((map) => FavoriteMeal.fromMap(map)).toList();
  }

  Future<bool> getIncludeFavoritesPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('include_favorite_meals') ?? true;
  }

  Future<void> setIncludeFavoritesPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('include_favorite_meals', value);
  }
}