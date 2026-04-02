import '../../../core/database/database_helper.dart';
import '../domain/models/diet.dart';

/// Handles SQLite database operations for the Diet entity.
class DietRepository {

  /// Retrieves all diets associated with a specific profile ID.
  /// Returns an empty list if no diets are found.
  Future<List<Diet>> getDietsByProfile(int idProfile) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'diet',
      where: 'id_profile = ?',
      whereArgs: [idProfile],
    );

    return List.generate(maps.length, (i) {
      return Diet.fromMap(maps[i]);
    });
  }

  /// Inserts a new diet record into the local SQLite database.
  /// Returns the auto-generated ID of the newly inserted diet.
  Future<int> createDiet(Diet diet) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'diet',
      diet.toMap(),
    );
  }

  /// Deletes a diet record from the local SQLite database by its ID.
  /// Returns the number of rows affected.
  Future<int> deleteDiet(int idDiet) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'diet',
      where: 'id_diet = ?',
      whereArgs: [idDiet],
    );
  }
}