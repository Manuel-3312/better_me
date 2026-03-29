import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/profile.dart';

class ProfileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createProfile(Profile profile) async {
    final db = await _dbHelper.database;
    return await db.insert('profile', profile.toMap());
  }

  Future<Profile?> getProfileById(int id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'profile',
      where: 'id_profile = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Profile>> getAllProfiles() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query('profile');

    return result.map((map) => Profile.fromMap(map)).toList();
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await _dbHelper.database;

    return await db.update(
      'profile',
      profile.toMap(),
      where: 'id_profile = ?',
      whereArgs: [profile.idProfile],
    );
  }

  Future<int> deleteProfile(int id) async {
    final db = await _dbHelper.database;

    return await db.delete('profile', where: 'id_profile = ?', whereArgs: [id]);
  }
}
