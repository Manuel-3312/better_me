import '../../../core/database/database_helper.dart';
import '../domain/models/progress_entry.dart';

/// Handles SQLite database operations for the Progress tracking entity.
class ProgressRepository {
  static const String tableName = 'progress_entries';

  /// Retrieves all progress entries for a specific profile, ordered by date descending.
  Future<List<ProgressEntry>> getProgressEntries(int idProfile) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id_profile = ?',
      whereArgs: [idProfile],
      orderBy: 'entry_date DESC',
    );

    return List.generate(maps.length, (i) {
      return ProgressEntry.fromMap(maps[i]);
    });
  }

  /// Inserts a new progress entry into the local database.
  Future<int> createProgressEntry(ProgressEntry entry) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(tableName, entry.toMap());
  }

  /// Deletes a specific progress entry by its ID.
  Future<int> deleteProgressEntry(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}