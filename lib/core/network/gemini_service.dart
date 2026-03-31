import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service responsible for communicating with the Google Gemini API.
/// It utilizes strict generation configurations to ensure robust JSON responses.
class GeminiService {
  /// The core generative model instance from the Google AI SDK.
  late final GenerativeModel _model;

  /// Initializes the generative model using the secure API key.
  /// Enforces a strict JSON response MIME type to prevent parsing errors.
  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not defined in the .env file.');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      // This is a crucial configuration for production. It forces the AI
      // to return a valid JSON structure natively, ignoring conversational text.
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Sends a tailored prompt to the AI model and returns the generated text response.
  Future<String?> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text;
    } catch (e) {
      debugPrint('ERROR GENERATING AI CONTENT');
      debugPrint(e.toString());
      return null;
    }
  }
}