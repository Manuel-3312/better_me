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

  /// Updates an existing profile in the database.
  /// Uses the profile's unique ID to target the correct record.
  Future<int> updateProfile(Profile profile) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'profile',
      {
        'name': profile.name,
        'sex': profile.sex,
        'weight': profile.weight,
        'height': profile.height,
        // Assuming birthDate is stored as an ISO 8601 string in the database
        'birth_date': profile.birthDate.toIso8601String(),
      },
      where: 'id_profile = ?',
      whereArgs: [profile.idProfile],
    );
  }

  /// Deletes a profile from the database using its unique identifier.
  Future<int> deleteProfile(int idProfile) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'profile',
      where: 'id_profile = ?',
      whereArgs: [idProfile],
    );
  }
}
