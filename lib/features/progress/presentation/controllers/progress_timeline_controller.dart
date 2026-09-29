import 'package:flutter/foundation.dart';
import 'package:better_me/features/progress/data/progress_repository.dart';
import 'package:better_me/features/progress/domain/models/progress_entry.dart';

/// Controller responsible for managing the state of the progress timeline.
class ProgressTimelineController extends ChangeNotifier {
  final ProgressRepository _repository = ProgressRepository();

  List<ProgressEntry> _entries = [];
  bool _isLoading = true;

  /// Gets the current list of progress entries.
  List<ProgressEntry> get entries => _entries;

  /// Indicates whether the entries are currently being loaded.
  bool get isLoading => _isLoading;

  /// Fetches all progress entries associated with the specified profile identifier.
  Future<void> loadEntries(int profileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _repository.getProgressEntries(profileId);
    } catch (e) {
      debugPrint('Error loading progress entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Temporarily removes an entry from the UI list for the "Undo" feature.
  void removeEntryLocally(int index) {
    _entries.removeAt(index);
    notifyListeners();
  }

  /// Restores a previously removed entry to the UI list.
  void restoreEntryLocally(int index, ProgressEntry entry) {
    _entries.insert(index, entry);
    notifyListeners();
  }

  /// Permanently deletes a progress entry record from the local database.
  Future<void> deleteEntryPermanently(int entryId) async {
    try {
      await _repository.deleteProgressEntry(entryId);
    } catch (e) {
      debugPrint('Error deleting entry from database: $e');
    }
  }
}
