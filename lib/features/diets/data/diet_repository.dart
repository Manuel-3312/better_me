import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/diet.dart';

class DietRepository {
  Future<List<Diet>> getDietsByProfile(int idProfile) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diet',
      where: 'id_profile = ?',
      whereArgs: [idProfile],
    );
    return List.generate(maps.length, (i) => Diet.fromMap(maps[i]));
  }

  Future<int> createDiet(Diet diet) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('diet', diet.toMap());
  }

  Future<int> saveFullAiDietPlan(Diet baseDiet) async {
    final db = await DatabaseHelper.instance.database;

    if (baseDiet.idDiet != null) {
      await db.update(
        'diet',
        baseDiet.toMap(),
        where: 'id_diet = ?',
        whereArgs: [baseDiet.idDiet],
      );
      return baseDiet.idDiet!;
    } else {
      return await db.insert(
        'diet',
        baseDiet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> deleteDiet(int idDiet) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'diet',
      where: 'id_diet = ?',
      whereArgs: [idDiet],
    );
  }
}