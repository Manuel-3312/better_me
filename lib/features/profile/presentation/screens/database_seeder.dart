import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';

class DatabaseSeeder {
  static Future<void> populateSupabaseFromWger() async {
    final supabase = Supabase.instance.client;

    try {
      debugPrint('=== INICIANDO MIGRACIÓN (SOLO EJERCICIOS CON TRADUCCIÓN COMPLETA) ===');

      String? nextUrl = 'https://wger.de/api/v2/exerciseinfo/?language=2&limit=100';
      int totalUploaded = 0;

      while (nextUrl != null) {
        final response = await http.get(Uri.parse(nextUrl));
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));

          String? rawNext = data['next'];
          nextUrl = (rawNext != null && rawNext.startsWith('http://'))
              ? rawNext.replaceFirst('http://', 'https://')
              : rawNext;

          final List results = data['results'];
          List<Map<String, dynamic>> exercisesToUpload = [];

          for (var item in results) {
            // REGLA 1: Debe tener imagen
            if (item['images'] == null || (item['images'] as List).isEmpty) continue;

            // REGLA 2: DEBE existir una traducción oficial al español (ID 4)
            final translations = (item['exercises'] as List?) ?? (item['translations'] as List?) ?? [];
            bool hasSpanishTranslation = translations.any(
                    (t) => t['language'] == 4 || (t['language'] is Map && t['language']['id'] == 4)
            );

            // Si no está traducido al español por la comunidad de Wger, LO DESCARTAMOS para ambos.
            if (!hasSpanishTranslation) continue;

            final enExercise = WgerExercise.fromJson(item as Map<String, dynamic>, languageId: 2);
            final esExercise = WgerExercise.fromJson(item as Map<String, dynamic>, languageId: 4);

            // Verificación final
            if (enExercise.name.isNotEmpty && enExercise.name != 'Unnamed Exercise' &&
                esExercise.name.isNotEmpty && esExercise.name != 'Unnamed Exercise') {

              String cleanEnDesc = enExercise.description.replaceAll(RegExp(r'<[^>]*>'), '').trim();
              String cleanEsDesc = esExercise.description.replaceAll(RegExp(r'<[^>]*>'), '').trim();

              // 1. FILA EN INGLÉS
              exercisesToUpload.add({
                'id': enExercise.id,
                'name': enExercise.name,
                'description': cleanEnDesc,
                'category_id': enExercise.categoryId,
                'category_name': enExercise.categoryName,
                'main_muscle_id': enExercise.mainMuscleId,
                'secondary_muscle_ids': jsonEncode(enExercise.secondaryMuscleIds),
                'exercise_image_url': enExercise.exerciseImageUrl,
                'language': 'en',
              });

              // 2. FILA EN ESPAÑOL (Traducción 100% real garantizada)
              exercisesToUpload.add({
                'id': esExercise.id,
                'name': esExercise.name,
                'description': cleanEsDesc,
                'category_id': esExercise.categoryId,
                'category_name': esExercise.categoryName,
                'main_muscle_id': esExercise.mainMuscleId,
                'secondary_muscle_ids': jsonEncode(esExercise.secondaryMuscleIds),
                'exercise_image_url': esExercise.exerciseImageUrl,
                'language': 'es',
              });
            }
          }

          if (exercisesToUpload.isNotEmpty) {
            await supabase.from('exercise_catalog').insert(exercisesToUpload);
            totalUploaded += (exercisesToUpload.length ~/ 2);
            debugPrint('✅ Procesados ${exercisesToUpload.length ~/ 2} ejercicios perfectos.');
          }
        } else {
          debugPrint('❌ Error de conexión con Wger');
          break;
        }
      }
      debugPrint('🚀 ¡MIGRACIÓN COMPLETADA! Total ejercicios de altísima calidad: $totalUploaded');
    } catch (e) {
      debugPrint('❌ Error crítico: $e');
    }
  }
}