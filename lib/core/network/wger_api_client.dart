import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client responsible for handling HTTP requests to the wger public API.
class WgerApiClient {
  static const String _baseUrl = 'https://wger.de/api/v2';
  final http.Client _client;

  WgerApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data from wger API: ${response.statusCode}');
    }
  }
}