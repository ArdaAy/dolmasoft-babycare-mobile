import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient({required this.baseUrl, HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final String baseUrl;
  final HttpClient _httpClient;

  Future<ApiResponse> postJson(
    String path, {
    required Map<String, Object?> body,
  }) async {
    final request = await _httpClient.postUrl(_buildUri(path));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final jsonBody = responseBody.isEmpty
        ? null
        : jsonDecode(responseBody) as Map<String, dynamic>;

    return ApiResponse(statusCode: response.statusCode, body: jsonBody);
  }

  Uri _buildUri(String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBaseUrl$normalizedPath');
  }
}

class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic>? body;
}
