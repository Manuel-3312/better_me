import 'package:flutter/foundation.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';

/// Controller responsible for managing the state of the user's profile view.
class ProfileController extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  late Profile _currentProfile;

  /// Gets the currently active profile.
  Profile get currentProfile => _currentProfile;

  /// Initializes the controller with the provided profile.
  void initialize(Profile profile) {
    _currentProfile = profile;
  }

  /// Fetches the latest profile data from the local database to ensure UI is up-to-date.
  Future<void> refreshProfileData() async {
    if (_currentProfile.idProfile == null) return;

    try {
      final updated = await _repository.getProfileById(_currentProfile.idProfile!);
      if (updated != null) {
        _currentProfile = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing profile data: $e');
    }
  }
}