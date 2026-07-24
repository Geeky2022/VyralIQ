import 'dart:async';
import '../models/generation_result.dart';
import '../models/script.dart';
import 'ai_service.dart';

typedef ProgressCallback = void Function(String status);

/// Orchestrates AI content generation via the VyralIQ Cloud Function.
/// The Cloud Function securely makes all OpenAI calls server-side.
class GenerationService {
  final AiService _ai;

  GenerationService({AiService? aiService}) : _ai = aiService ?? AiService();

  // ---------------------------------------------------------------------------
  // Full Generation
  // ---------------------------------------------------------------------------

  /// Generates ALL content types via the Cloud Function.
  /// Reports progress via [onProgress] with human-readable status messages.
  Future<GenerationResult> generateAll({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
    ProgressCallback? onProgress,
  }) async {
    onProgress?.call('Crafting your content with VyralIQ AI...');

    final result = await _ai.generateContent(
      platform: platform,
      niche: niche,
      goal: goal,
      tone: tone,
      length: length,
    );

    onProgress?.call('Polishing your content...');

    return result;
  }

  // ---------------------------------------------------------------------------
  // Weekly Calendar (Generate My Entire Week)
  // ---------------------------------------------------------------------------

  /// Generates 7 days of content (Mon–Sun) with day-specific variations.
  /// Each day calls the Cloud Function with a dayOfWeek hint.
  Future<List<DailyContent>> generateWeek({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
    ProgressCallback? onProgress,
  }) async {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final List<DailyContent> week = [];

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      onProgress?.call('Generating $day content...');

      final result = await _ai.generateContent(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
        dayOfWeek: day,
      );

      week.add(DailyContent(
        dayOfWeek: day,
        hooks: result.viralHooks,
        script: result.scripts.isNotEmpty ? result.scripts.first : null,
        caption: result.caption,
        hashtags: result.hashtags,
      ));
    }

    return week;
  }

  // ---------------------------------------------------------------------------
  // Individual Section Generators
  // ---------------------------------------------------------------------------

  /// Generates just viral hooks (calls full generation, extracts hooks).
  Future<List<String>> generateHooks({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) async {
    final result = await _ai.generateContent(
      platform: platform,
      niche: niche,
      goal: goal,
      tone: tone,
      length: length,
    );
    return result.viralHooks;
  }

  /// Generates just scripts (calls full generation, extracts scripts).
  Future<List<Script>> generateScripts({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) async {
    final result = await _ai.generateContent(
      platform: platform,
      niche: niche,
      goal: goal,
      tone: tone,
      length: length,
    );
    return result.scripts;
  }
}

/// A single day's content for the weekly calendar.
class DailyContent {
  final String dayOfWeek;
  final List<String> hooks;
  final Script? script;
  final String caption;
  final List<String> hashtags;

  const DailyContent({
    required this.dayOfWeek,
    required this.hooks,
    this.script,
    required this.caption,
    required this.hashtags,
  });
}
