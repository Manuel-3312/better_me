import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/profile.dart';

class ProfileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> createProfile(Profile profile) async {
    final db = await _dbHelper.database;
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) throw Exception('Not user logged');

    final profileWithUser = profile.copyWith(userId: currentUser.id);

    return await db.insert('profile', profileWithUser.toMap());
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
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) return [];

    final List<Map<String, dynamic>> result = await db.query(
      'profile',
      where: 'user_id = ?',
      whereArgs: [currentUser.id],
    );

    return result.map((map) => Profile.fromMap(map)).toList();
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await _dbHelper.database;

    return await db.update(
      'profile',
      {
        'name': profile.name,
        'sex': profile.sex,
        'weight': profile.weight,
        'height': profile.height,
        'birth_date': profile.birthDate.toIso8601String(),
      },
      where: 'id_profile = ?',
      whereArgs: [profile.idProfile],
    );
  }

  Future<int> deleteProfile(int idProfile) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'profile',
      where: 'id_profile = ?',
      whereArgs: [idProfile],
    );
  }

  Future<void> updateActivePlans(
      int profileId,
      int? dietId,
      int? trainingId,
      ) async {
    final db = await _dbHelper.database;
    await db.update(
      'profile',
      {'active_diet_id': dietId, 'active_training_id': trainingId},
      where: 'id_profile = ?',
      whereArgs: [profileId],
    );
  }
}