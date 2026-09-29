import 'dart:convert';

class WgerExercise {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final String categoryName;
  final int? mainMuscleId;
  final List<int> secondaryMuscleIds;
  final String? exerciseImageUrl;

  const WgerExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    this.mainMuscleId,
    this.secondaryMuscleIds = const [],
    this.exerciseImageUrl,
  });

  factory WgerExercise.fromJson(Map<String, dynamic> json, {int languageId = 2}) {
    int parsedCategoryId = 0;
    String parsedCategoryName = 'Unknown';

    if (json['category'] is Map) {
      final categoryMap = json['category'] as Map<String, dynamic>;
      parsedCategoryId = categoryMap['id'] as int? ?? 0;
      parsedCategoryName = categoryMap['name'] as String? ?? 'Unknown';
    } else if (json['category'] is int) {
      parsedCategoryId = json['category'] as int;
      parsedCategoryName = _mapCategoryName(parsedCategoryId);
    }

    String finalName = '';
    String finalDescription = '';
    final translations = (json['exercises'] as List?) ?? (json['translations'] as List?) ?? [];

    final targetDoc = translations.firstWhere(
          (t) => t is Map && t['language'] == languageId && (t['name']?.toString().trim().isNotEmpty ?? false),
      orElse: () => null,
    );

    if (targetDoc != null) {
      finalName = targetDoc['name'].toString().trim();
      finalDescription = targetDoc['description']?.toString() ?? '';
    } else {
      final fallbackDoc = translations.firstWhere(
            (t) => t is Map && t['language'] == 2 && (t['name']?.toString().trim().isNotEmpty ?? false),
        orElse: () => null,
      );

      if (fallbackDoc != null) {
        finalName = fallbackDoc['name'].toString().trim();
        finalDescription = fallbackDoc['description']?.toString() ?? '';
      } else {
        final anyDoc = translations.firstWhere(
              (t) => t is Map && (t['name']?.toString().trim().isNotEmpty ?? false),
          orElse: () => null,
        );
        if (anyDoc != null) {
          finalName = anyDoc['name'].toString().trim();
          finalDescription = anyDoc['description']?.toString() ?? '';
        }
      }
    }

    int? parsedMuscleId;
    if (json['muscles'] != null && (json['muscles'] as List).isNotEmpty) {
      final firstMuscle = (json['muscles'] as List).first;
      if (firstMuscle is Map<String, dynamic>) {
        parsedMuscleId = firstMuscle['id'] as int?;
      } else if (firstMuscle is int) {
        parsedMuscleId = firstMuscle;
      }
    }

    parsedMuscleId ??= _getFallbackMuscleId(parsedCategoryId);

    List<int> parsedSecondaryMuscles = [];
    if (json['muscles_secondary'] != null && (json['muscles_secondary'] as List).isNotEmpty) {
      for (var item in (json['muscles_secondary'] as List)) {
        if (item is Map && item['id'] != null) {
          parsedSecondaryMuscles.add(item['id'] as int);
        } else if (item is int) {
          parsedSecondaryMuscles.add(item);
        }
      }
    }

    String? parsedExerciseUrl;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final firstImage = (json['images'] as List).first as Map<String, dynamic>;
      parsedExerciseUrl = firstImage['image'] as String?;
      if (parsedExerciseUrl != null && parsedExerciseUrl.startsWith('/')) {
        parsedExerciseUrl = 'https://wger.de$parsedExerciseUrl';
      }
    }

    return WgerExercise(
      id: json['id'] as int? ?? 0,
      name: finalName.isEmpty ? 'Unnamed Exercise' : finalName,
      description: finalDescription.isEmpty ? 'No description available.' : finalDescription,
      categoryId: parsedCategoryId,
      categoryName: parsedCategoryName,
      mainMuscleId: parsedMuscleId,
      secondaryMuscleIds: parsedSecondaryMuscles,
      exerciseImageUrl: parsedExerciseUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'main_muscle_id': mainMuscleId,
      'secondary_muscle_ids': jsonEncode(secondaryMuscleIds),
      'exercise_image_url': exerciseImageUrl,
    };
  }

  factory WgerExercise.fromMap(Map<String, dynamic> map) {
    return WgerExercise(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String,
      mainMuscleId: map['main_muscle_id'] as int?,
      secondaryMuscleIds: map['secondary_muscle_ids'] != null
          ? List<int>.from(jsonDecode(map['secondary_muscle_ids'] as String))
          : [],
      exerciseImageUrl: map['exercise_image_url'] as String?,
    );
  }

  static String _mapCategoryName(int id) {
    switch (id) {
      case 8: return 'Arms';
      case 9: return 'Back';
      case 10: return 'Abs';
      case 11: return 'Chest';
      case 12: return 'Calves';
      case 13: return 'Shoulders';
      case 14: return 'Legs';
      default: return 'Other ($id)';
    }
  }

  static int _getFallbackMuscleId(int categoryId) {
    switch (categoryId) {
      case 8: return 1;
      case 9: return 12;
      case 10: return 6;
      case 11: return 4;
      case 12: return 7;
      case 13: return 2;
      case 14: return 10;
      default: return 0;
    }
  }
}