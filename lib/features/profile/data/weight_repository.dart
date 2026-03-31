import '../../../core/database/database_helper.dart';
import '../domain/models/weight_entry.dart';

class WeightRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Adds a new weight record to the history.
  Future<int> addWeightEntry(WeightEntry entry) async {
    final db = await _dbHelper.database;
    return await db.insert('weight_history', entry.toMap());
  }

  /// Retrieves the weight history for a specific profile, ordered by date.
  Future<List<WeightEntry>> getWeightHistory(int idProfile) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_history',
      where: 'id_profile = ?',
      whereArgs: [idProfile],
      orderBy: 'date DESC',
    );

    return maps.map((map) => WeightEntry.fromMap(map)).toList();
  }

  /// Deletes a specific weight entry.
  Future<int> deleteWeightEntry(int idWeight) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'weight_history',
      where: 'id_weight = ?',
      whereArgs: [idWeight],
    );
  }
}