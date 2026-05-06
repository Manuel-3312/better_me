import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/domain/models/weight_entry.dart';
import 'package:better_me/features/profile/data/weight_repository.dart';
import 'package:better_me/features/profile/data/cloud_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateProfileController extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();
  final WeightRepository _weightRepository = WeightRepository();

  bool _isSaving = false;
  String _selectedSex = 'M';
  DateTime? _selectedDate;

  bool get isSaving => _isSaving;
  String get selectedSex => _selectedSex;
  DateTime? get selectedDate => _selectedDate;

  void initialize(Profile? existingProfile) {
    if (existingProfile != null) {
      _selectedSex = existingProfile.sex;
      _selectedDate = existingProfile.birthDate;
    }
  }

  void setSex(String sex) {
    _selectedSex = sex;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<Profile?> saveProfile({
    required Profile? existingProfile,
    required String name,
    required double weight,
    required double height,
  }) async {
    if (_selectedDate == null) return null;
    _isSaving = true;
    notifyListeners();

    try {
      final isEditing = existingProfile != null;
      var profileToSave = Profile(
        idProfile: existingProfile?.idProfile,
        userId: existingProfile?.userId ?? '',
        name: name,
        sex: _selectedSex,
        weight: weight,
        height: height,
        birthDate: _selectedDate!,
        activeDietId: existingProfile?.activeDietId,
        activeTrainingId: existingProfile?.activeTrainingId,
      );

      if (isEditing) {
        await _profileRepository.updateProfile(profileToSave);
        if (existingProfile.name != name) {
          final supabase = Supabase.instance.client;
          final userId = existingProfile.userId;

          await supabase.from('profile')
              .update({'name': name})
              .eq('user_id', userId)
              .eq('name', existingProfile.name);

          await supabase.from('diet')
              .update({'profile_name': name})
              .eq('user_id', userId)
              .eq('profile_name', existingProfile.name);

          await supabase.from('training')
              .update({'profile_name': name})
              .eq('user_id', userId)
              .eq('profile_name', existingProfile.name);
        }
      } else {
        final newId = await _profileRepository.createProfile(profileToSave);
        profileToSave = profileToSave.copyWith(idProfile: newId);

        await _weightRepository.addWeightEntry(
          WeightEntry(
            idProfile: newId,
            weight: profileToSave.weight,
            date: DateTime.now(),
          ),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_profile_id', newId);
      }

      await CloudSyncService().backupProfilesToCloud();

      return profileToSave;
    } catch (e) {
      debugPrint('Error saving profile: $e');
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}