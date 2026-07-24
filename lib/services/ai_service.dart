import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

/// Wraps OpenAI chat completions API calls.
/// Handles errors gracefully — network failures, rate limits, invalid API key.
class AiService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  final String _apiKey;
  final String _model;

  AiService({
    String? apiKey,
    String? model,
  })  : _apiKey = apiKey ?? ApiKeys.openAiApiKey,
        _model = model ?? ApiKeys.openAiModel;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Sends a chat completion request with a system prompt and user prompt.
  /// Returns the assistant's text response.
  ///
  /// Throws [AiServiceException] on failure.
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.9,
    int maxTokens = 2000,
  }) async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          throw AiServiceException('No response from AI — please try again.');
        }
        final message = choices[0]['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        if (content == null || content.isEmpty) {
          throw AiServiceException('Empty response from AI — please try again.');
        }
        return content.trim();
      } else if (response.statusCode == 401) {
        throw AiServiceException(
          'Invalid API key. Please check your OpenAI API key in '
          'lib/config/api_keys.dart',
          code: 401,
        );
      } else if (response.statusCode == 429) {
        throw AiServiceException(
          'Rate limit reached. Please wait a moment and try again.',
          code: 429,
        );
      } else if (response.statusCode == 500) {
        throw AiServiceException(
          'OpenAI server error. Please try again later.',
          code: 500,
        );
      } else {
        final body = response.body;
        String detail = 'Status ${response.statusCode}';
        try {
          final err = jsonDecode(body) as Map<String, dynamic>;
          if (err.containsKey('error')) {
            final e = err['error'] as Map<String, dynamic>;
            detail = e['message'] as String? ?? detail;
          }
        } catch (_) {}
        throw AiServiceException(detail, code: response.statusCode);
      }
    } on AiServiceException {
      rethrow;
    } on http.ClientException catch (e) {
      throw AiServiceException(
        'Network error: unable to reach OpenAI. Check your internet connection.',
        code: 0,
        original: e,
      );
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw AiServiceException(
          'Request timed out. The AI is taking too long — please try again.',
          code: 408,
        );
      }
      throw AiServiceException(
        'Unexpected error: ${e.toString()}',
        code: -1,
        original: e,
      );
    }
  }

  /// Sends multiple completion requests in parallel and returns results.
  /// Useful for generating independent content sections simultaneously.
  Future<List<String>> completeMultiple(
    List<({String systemPrompt, String userPrompt})> prompts, {
    double temperature = 0.9,
    int maxTokens = 2000,
  }) async {
    final futures = prompts.map((p) => complete(
          systemPrompt: p.systemPrompt,
          userPrompt: p.userPrompt,
          temperature: temperature,
          maxTokens: maxTokens,
        ));
    return Future.wait(futures);
  }
}

/// Structured exception for AI service errors.
class AiServiceException implements Exception {
  final String message;
  final int code;
  final Object? original;

  const AiServiceException(
    this.message, {
    this.code = -1,
    this.original,
  });

  @override
  String toString() => 'AiServiceException($code): $message';
}
