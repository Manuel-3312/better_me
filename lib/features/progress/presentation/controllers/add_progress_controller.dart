import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:better_me/features/progress/data/progress_repository.dart';
import 'package:better_me/features/progress/domain/models/progress_entry.dart';

/// Controller responsible for handling image selection and progress persistence.
class AddProgressController extends ChangeNotifier {
  final ProgressRepository _repository = ProgressRepository();
  final ImagePicker _picker = ImagePicker();

  final List<File> _selectedImages = [];
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  /// Gets the current list of selected images.
  List<File> get selectedImages => _selectedImages;

  /// Gets the currently selected date for the progress entry.
  DateTime get selectedDate => _selectedDate;

  /// Indicates whether the progress entry is currently being saved.
  bool get isSaving => _isSaving;

  /// Updates the selected date for the progress entry.
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Opens the image picker and adds selected images to the state.
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  /// Removes an image from the selection at the specified index.
  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  /// Copies selected images to the application documents directory.
  Future<List<String>> _saveImagesLocally() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<String> savedPaths = [];

    for (var image in _selectedImages) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final savedImage = await image.copy('${directory.path}/$fileName');
      savedPaths.add(savedImage.path);
    }
    return savedPaths;
  }

  /// Persists the complete progress entry and its associated images.
  Future<bool> saveProgress({
    required int profileId,
    required double weight,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final savedPhotoPaths = await _saveImagesLocally();

      final entry = ProgressEntry(
        idProfile: profileId,
        date: _selectedDate,
        weight: weight,
        photoPaths: savedPhotoPaths,
      );

      await _repository.createProgressEntry(entry);
      return true;
    } catch (e) {
      debugPrint('Error saving progress: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
