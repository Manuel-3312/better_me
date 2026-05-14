import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client responsible for handling HTTP GET requests to the public Wger API.
class WgerApiClient {
  static const String _baseUrl = 'https://wger.de/api/v2';
  final http.Client _client;

  /// Allows injecting a custom HTTP client (useful for testing),
  /// or defaults to a standard [http.Client].
  WgerApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Performs a GET request to the specified [endpoint] and returns the decoded JSON data.
  /// Throws an [Exception] if the request fails or returns a non-200 status code.
  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    // Execute the GET request specifically requesting a JSON response
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    // Validate the response status and decode the JSON payload
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to load data from wger API: ${response.statusCode}',
      );
    }
  }
}
