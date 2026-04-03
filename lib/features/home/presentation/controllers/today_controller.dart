import 'package:flutter/foundation.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/training/domain/models/training.dart';

/// Controller responsible for managing the active dashboard state.
class TodayController extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();

  Profile? _profile;
  int? _savedDietId;
  int? _savedTrainingId;

  Diet? _activeDiet;
  Training? _activeTraining;

  bool _isConfiguring = false;
  bool _isLoading = false;

  Diet? get activeDiet => _activeDiet;

  Training? get activeTraining => _activeTraining;

  bool get isConfiguring => _isConfiguring;

  bool get isLoading => _isLoading;

  /// Initializes the controller and fetches the latest profile from local storage.
  void initialize(Profile profile, List<Diet> diets, List<Training> trainings) {
    _profile = profile;
    _savedDietId = profile.activeDietId;
    _savedTrainingId = profile.activeTrainingId;

    _applySavedConfiguration(diets, trainings);
    _fetchLatestProfile(diets, trainings);
  }

  /// Updates the controller state when parent widget dependencies change.
  void updateData(Profile profile, List<Diet> diets, List<Training> trainings) {
    _profile = profile;
    _applySavedConfiguration(diets, trainings);
  }

  /// Ensures the active plans are always in sync with the absolute latest profile state.
  Future<void> _fetchLatestProfile(
    List<Diet> diets,
    List<Training> trainings,
  ) async {
    if (_profile?.idProfile == null) return;

    try {
      final updatedProfile = await _profileRepository.getProfileById(
        _profile!.idProfile!,
      );
      if (updatedProfile != null) {
        _profile = updatedProfile;
        _savedDietId = updatedProfile.activeDietId;
        _savedTrainingId = updatedProfile.activeTrainingId;
        _applySavedConfiguration(diets, trainings);
      }
    } catch (e) {
      debugPrint('Error fetching latest profile: $e');
    }
  }

  /// Synchronizes the current UI state with the internally tracked active IDs.
  void _applySavedConfiguration(List<Diet> diets, List<Training> trainings) {
    try {
      _activeDiet = diets.firstWhere((d) => d.idDiet == _savedDietId);
    } catch (_) {
      _activeDiet = null;
    }

    try {
      _activeTraining = trainings.firstWhere(
        (t) => t.idTraining == _savedTrainingId,
      );
    } catch (_) {
      _activeTraining = null;
    }

    _isConfiguring = (_activeDiet == null || _activeTraining == null);
    notifyListeners();
  }

  /// Updates the currently selected diet in the configuration view.
  void setActiveDiet(Diet? diet) {
    _activeDiet = diet;
    notifyListeners();
  }

  /// Updates the currently selected training in the configuration view.
  void setActiveTraining(Training? training) {
    _activeTraining = training;
    notifyListeners();
  }

  /// Toggles the configuration view mode.
  void setConfiguring(bool value) {
    _isConfiguring = value;
    notifyListeners();
  }

  /// Persists the user's active configuration to the local database.
  Future<void> saveConfiguration() async {
    if (_activeDiet == null ||
        _activeTraining == null ||
        _profile?.idProfile == null) {
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      await _profileRepository.updateActivePlans(
        _profile!.idProfile!,
        _activeDiet!.idDiet,
        _activeTraining!.idTraining,
      );

      _savedDietId = _activeDiet!.idDiet;
      _savedTrainingId = _activeTraining!.idTraining;
      _isConfiguring = false;
    } catch (e) {
      debugPrint('Error saving configuration: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
