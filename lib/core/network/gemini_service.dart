import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeminiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> generateContent(String prompt) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-plan',
        body: {'prompt': prompt},
      );

      final data = response.data;

      debugPrint('=== AI RESPONSE ===');
      debugPrint(data.toString());
      debugPrint('================================');

      if (data != null && data['candidates'] != null && (data['candidates'] as List).isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
      }

      return null;
    } catch (e) {
      debugPrint('ERROR GENERATING AI CONTENT');
      debugPrint(e.toString());
      return null;
    }
  }
}