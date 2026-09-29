import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for communicating with the AI model (Gemini)
/// via a Supabase Edge Function.
class GeminiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sends a text prompt to the AI and returns the generated text response.
  /// Returns [null] if the request fails or the response format is unexpected.
  Future<String?> generateContent(String prompt) async {
    try {
      // Invoke the Supabase Edge Function named 'generate-plan'
      final response = await _supabase.functions.invoke(
        'generate-plan',
        body: {'prompt': prompt},
      );

      final data = response.data;

      // Parse the response assuming a standard Gemini API JSON structure
      if (data != null &&
          data['candidates'] != null &&
          (data['candidates'] as List).isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
      }

      return null;
    } catch (e) {
      // Log the error if the AI content generation fails
      debugPrint('Error generating AI content: $e');
      return null;
    }
  }
}
