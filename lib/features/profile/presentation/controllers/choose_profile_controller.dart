import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';

/// Controller responsible for managing the state of the profile selection screen.
class ChooseProfileController extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  List<Profile> _profiles = [];
  bool _isLoading = false;
  String? _error;

  /// Gets the current list of available profiles.
  List<Profile> get profiles => _profiles;

  /// Indicates whether the profiles are currently being loaded.
  bool get isLoading => _isLoading;

  /// Contains the error message if the loading operation failed.
  String? get error => _error;

  /// Fetches all profiles from the local database.
  Future<void> loadProfiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profiles = await _repository.getAllProfiles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Temporarily removes a profile from the UI list for the "Undo" feature.
  void removeProfileLocally(int index) {
    _profiles.removeAt(index);
    notifyListeners();
  }

  /// Restores a previously removed profile to the UI list.
  void restoreProfileLocally(int index, Profile profile) {
    _profiles.insert(index, profile);
    notifyListeners();
  }

  /// Permanently deletes a profile record from the local database.
  Future<void> deleteProfilePermanently(int profileId) async {
    try {
      await _repository.deleteProfile(profileId);
    } catch (e) {
      debugPrint('Error deleting profile from database: $e');
    }
  }

  /// Saves the selected profile ID to SharedPreferences to persist the session.
  Future<void> saveActiveProfileSession(int profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_profile_id', profileId);
    } catch (e) {
      debugPrint('Error saving session to SharedPreferences: $e');
    }
  }
}