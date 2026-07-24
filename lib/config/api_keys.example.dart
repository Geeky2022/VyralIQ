/// VyralIQ API Keys Configuration
///
/// INSTRUCTIONS:
/// 1. Copy this file to `api_keys.dart` in the same directory
/// 2. Replace the placeholder with your actual OpenAI API key
/// 3. NEVER commit `api_keys.dart` — it is gitignored
///
/// To get your API key:
/// - Go to https://platform.openai.com/api-keys
/// - Create a new secret key
/// - Copy it and paste below

class ApiKeys {
  /// Your OpenAI API key from https://platform.openai.com/api-keys
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';

  /// OpenAI model to use for content generation.
  /// Recommended: gpt-4o or gpt-4-turbo
  static const String openAiModel = 'gpt-4o';
}
