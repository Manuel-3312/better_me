import '../../../core/database/database_helper.dart';
import '../domain/models/diet.dart';

/// Handles SQLite database operations for the Diet entity.
class DietRepository {

  /// Retrieves all diets associated with a specific profile ID.
  /// Returns an empty list if no diets are found.
  Future<List<Diet>> getDietsByProfile(int idProfile) async {
    final db = await DatabaseHelper.instance.database;

    // Query the diet table filtering by the foreign key (id_profile)
    final List<Map<String, dynamic>> maps = await db.query(
      'diet',
      where: 'id_profile = ?',
      whereArgs: [idProfile],
    );

    // Convert the List of Maps into a List of Diet objects
    return List.generate(maps.length, (i) {
      return Diet.fromMap(maps[i]);
    });
  }
}