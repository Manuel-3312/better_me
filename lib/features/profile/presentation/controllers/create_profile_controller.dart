import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/domain/models/weight_entry.dart';
import 'package:better_me/features/profile/data/weight_repository.dart';

/// Controller responsible for managing the creation and updating of user profiles.
class CreateProfileController extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();
  final WeightRepository _weightRepository = WeightRepository();

  bool _isSaving = false;
  String _selectedSex = 'M';
  DateTime? _selectedDate;

  bool get isSaving => _isSaving;

  String get selectedSex => _selectedSex;

  DateTime? get selectedDate => _selectedDate;

  /// Initializes the controller state based on an existing profile, if provided.
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

  /// Validates and persists the profile data, handling both creation and updates.
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
