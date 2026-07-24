import 'dart:async';
import '../models/generation_result.dart';
import '../models/script.dart';
import 'ai_service.dart';
import 'prompt_templates.dart';

typedef ProgressCallback = void Function(String status);

/// Orchestrates multiple OpenAI calls to generate all content types.
/// Supports individual section generation and "Generate All".
class GenerationService {
  final AiService _ai;

  GenerationService({AiService? aiService}) : _ai = aiService ?? AiService();

  // ---------------------------------------------------------------------------
  // Full Generation
  // ---------------------------------------------------------------------------

  /// Generates ALL content types and returns a complete [GenerationResult].
  /// Reports progress via [onProgress] with human-readable status messages.
  Future<GenerationResult> generateAll({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
    ProgressCallback? onProgress,
  }) async {
    final base = GenerationResult(
      platform: platform,
      niche: niche,
      goal: goal,
      tone: tone,
      length: length,
    );

    final sys = PromptTemplates.systemPrompt(
      platform: platform,
      tone: tone,
      niche: niche,
    );

    // Phase 1: Run independent calls in parallel
    onProgress?.call('Crafting viral hooks...');
    final hooksFuture = _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.viralHooksPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
      ),
      maxTokens: 1500,
    );

    onProgress?.call('Brainstorming video ideas...');
    final ideasFuture = _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.videoIdeasPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
      ),
      maxTokens: 1200,
    );

    onProgress?.call('Writing your scripts...');
    final scriptsFuture = _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.scriptsPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
      ),
      maxTokens: 2500,
    );

    onProgress?.call('Optimizing captions...');
    final captionFuture = _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.captionPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
      ),
      maxTokens: 1200,
    );

    onProgress?.call('Designing visuals...');
    final visualFuture = _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.visualPrompt(
        platform: platform,
        niche: niche,
        tone: tone,
      ),
      maxTokens: 1000,
    );

    onProgress?.call('Building SEO strategy...');
    final strategyFuture = _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.strategyPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
      ),
      maxTokens: 1000,
    );

    onProgress?.call('Adapting for cross-platform...');
    final crossPlatformFuture = _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.crossPlatformPrompt(
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
      ),
      maxTokens: 2000,
    );

    // Phase 2: Wait for all and parse
    final results = await Future.wait([
      hooksFuture,
      ideasFuture,
      scriptsFuture,
      captionFuture,
      visualFuture,
      strategyFuture,
      crossPlatformFuture,
    ]);

    onProgress?.call('Polishing your content...');

    final hooks = _parseNumberedList(results[0]);
    final ideas = _parseNumberedList(results[1]);
    final scripts = _parseScripts(results[2]);
    final captionData = _parseCaption(results[3]);
    final visualData = _parseVisual(results[4]);
    final strategyData = _parseStrategy(results[5]);
    final crossData = _parseCrossPlatform(results[6]);

    return base.copyWith(
      viralHooks: hooks,
      videoIdeas: ideas,
      scripts: scripts,
      caption: captionData['caption'] ?? '',
      cta: _extractCta(results[2]),
      hashtags: captionData['hashtags'] ?? [],
      thumbnailText: visualData['thumbnailText'] ?? '',
      editingSuggestions: visualData['editingSuggestions'] ?? '',
      bRollIdeas: visualData['bRollIdeas'] ?? [],
      cameraAngles: visualData['cameraAngles'] ?? '',
      lightingSuggestions: visualData['lightingSuggestions'] ?? '',
      musicStyle: visualData['musicStyle'] ?? '',
      bestPostingTime: strategyData['bestPostingTime'] ?? '',
      seoKeywords: strategyData['seoKeywords'] ?? [],
      repurposeIdeas: strategyData['repurposeIdeas'] ?? [],
      carouselVersion: crossData['carouselVersion'] ?? '',
      instagramStoryVersion: crossData['instagramStoryVersion'] ?? '',
      facebookVersion: crossData['facebookVersion'] ?? '',
      linkedinVersion: crossData['linkedinVersion'] ?? '',
      pinterestVersion: crossData['pinterestVersion'] ?? '',
    );
  }

  // ---------------------------------------------------------------------------
  // Weekly Calendar (Generate My Entire Week)
  // ---------------------------------------------------------------------------

  /// Generates 7 days of content (Mon–Sun) with day-specific variations.
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

      final daily = await _generateDay(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
        dayOfWeek: day,
      );
      week.add(daily);
    }

    return week;
  }

  // ---------------------------------------------------------------------------
  // Individual Section Generators
  // ---------------------------------------------------------------------------

  Future<List<String>> generateHooks({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) async {
    final sys = PromptTemplates.systemPrompt(
      platform: platform,
      tone: tone,
      niche: niche,
    );
    final result = await _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.viralHooksPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
      ),
      maxTokens: 1500,
    );
    return _parseNumberedList(result);
  }

  Future<List<Script>> generateScripts({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) async {
    final sys = PromptTemplates.systemPrompt(
      platform: platform,
      tone: tone,
      niche: niche,
    );
    final result = await _ai.complete(
      systemPrompt: sys,
      userPrompt: PromptTemplates.scriptsPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
      ),
      maxTokens: 2500,
    );
    return _parseScripts(result);
  }

  // ---------------------------------------------------------------------------
  // Private: Daily Generation
  // ---------------------------------------------------------------------------

  Future<DailyContent> _generateDay({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
    required String dayOfWeek,
  }) async {
    final hooksSys = PromptTemplates.dailyVariantSystemPrompt(
      platform: platform,
      tone: tone,
      niche: niche,
      dayOfWeek: dayOfWeek,
    );

    final hooksFuture = _ai.complete(
      systemPrompt: hooksSys,
      userPrompt: PromptTemplates.dailyViralHooksPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        length: length,
        dayOfWeek: dayOfWeek,
      ),
      maxTokens: 600,
    );

    final scriptFuture = _ai.complete(
      systemPrompt: hooksSys,
      userPrompt: PromptTemplates.dailyScriptIdeaPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        dayOfWeek: dayOfWeek,
      ),
      maxTokens: 800,
    );

    final captionFuture = _ai.complete(
      systemPrompt: hooksSys,
      userPrompt: PromptTemplates.dailyCaptionPrompt(
        platform: platform,
        niche: niche,
        goal: goal,
        tone: tone,
        dayOfWeek: dayOfWeek,
      ),
      maxTokens: 800,
    );

    final results = await Future.wait([hooksFuture, scriptFuture, captionFuture]);

    final hooks = _parseNumberedList(results[0]);
    final scripts = _parseScripts(results[1]);
    final captionData = _parseCaption(results[2]);

    return DailyContent(
      dayOfWeek: dayOfWeek,
      hooks: hooks,
      script: scripts.isNotEmpty ? scripts.first : null,
      caption: captionData['caption'] ?? '',
      hashtags: captionData['hashtags'] ?? [],
    );
  }

  // ---------------------------------------------------------------------------
  // Parsers
  // ---------------------------------------------------------------------------

  /// Parses a numbered list from AI output. Handles various formats:
  /// "1. text", "1) text", "1 - text", "1: text"
  List<String> _parseNumberedList(String raw) {
    final lines = raw.split('\n');
    final List<String> items = [];
    final regex = RegExp(r'^\s*\d+[\.\)\-\:]\s*(.+)');

    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final text = match.group(1)?.trim() ?? '';
        if (text.isNotEmpty) {
          items.add(text);
        }
      }
    }

    return items;
  }

  /// Parses the 5-script format from AI output.
  List<Script> _parseScripts(String raw) {
    final List<Script> scripts = [];

    // Split by SCRIPT markers
    final parts = raw.split(RegExp(r'SCRIPT\s*\d+', caseSensitive: false));
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      final hookMatch = RegExp(r'HOOK\s*:\s*(.+?)(?=\n\s*(?:BODY|CTA)\s*:)', dotAll: true).firstMatch(trimmed);
      final bodyMatch = RegExp(r'BODY\s*:\s*(.+?)(?=\n\s*CTA\s*:)', dotAll: true).firstMatch(trimmed);
      final ctaMatch = RegExp(r'CTA\s*:\s*(.+?)$', dotAll: true).firstMatch(trimmed);

      if (hookMatch != null || bodyMatch != null || ctaMatch != null) {
        scripts.add(Script(
          hook: hookMatch?.group(1)?.trim() ?? '',
          body: bodyMatch?.group(1)?.trim() ?? '',
          cta: ctaMatch?.group(1)?.trim() ?? '',
        ));
      }
    }

    // Fallback: try to find at least one script even without SCRIPT markers
    if (scripts.isEmpty) {
      final hookMatch = RegExp(r'HOOK\s*:\s*(.+?)(?=\n\s*(?:BODY|CTA)\s*:)', dotAll: true).firstMatch(raw);
      final bodyMatch = RegExp(r'BODY\s*:\s*(.+?)(?=\n\s*CTA\s*:)', dotAll: true).firstMatch(raw);
      final ctaMatch = RegExp(r'CTA\s*:\s*(.+?)$', dotAll: true).firstMatch(raw);
      if (hookMatch != null || bodyMatch != null || ctaMatch != null) {
        scripts.add(Script(
          hook: hookMatch?.group(1)?.trim() ?? '',
          body: bodyMatch?.group(1)?.trim() ?? '',
          cta: ctaMatch?.group(1)?.trim() ?? '',
        ));
      }
    }

    return scripts;
  }

  /// Parses caption + hashtags output.
  Map<String, dynamic> _parseCaption(String raw) {
    final captionMatch =
        RegExp(r'CAPTION\s*:\s*(.+?)(?=\n\s*HASHTAGS)', dotAll: true)
            .firstMatch(raw);
    final hashtagsMatch =
        RegExp(r'HASHTAGS\s*:\s*(.+)', dotAll: true).firstMatch(raw);

    final caption = captionMatch?.group(1)?.trim() ?? '';
    final hashtagsRaw = hashtagsMatch?.group(1)?.trim() ?? '';

    final hashtags = hashtagsRaw
        .split(RegExp(r'[\s,]+'))
        .where((t) => t.trim().isNotEmpty)
        .toList();

    return {'caption': caption, 'hashtags': hashtags};
  }

  /// Extracts a CTA from the scripts output.
  String _extractCta(String raw) {
    // Find the first CTA across all scripts
    final ctaMatches = RegExp(r'CTA\s*:\s*(.+)', dotAll: false)
        .allMatches(raw);
    if (ctaMatches.isNotEmpty) {
      return ctaMatches.first.group(1)?.trim() ?? '';
    }
    return '';
  }

  /// Parses visual production guidance.
  Map<String, dynamic> _parseVisual(String raw) {
    return {
      'thumbnailText':
          _extractSection(raw, 'THUMBNAIL TEXT'),
      'editingSuggestions':
          _extractSection(raw, 'EDITING SUGGESTIONS'),
      'bRollIdeas':
          _parseNumberedList(_extractSection(raw, 'B-ROLL IDEAS')),
      'cameraAngles':
          _extractSection(raw, 'CAMERA ANGLES'),
      'lightingSuggestions':
          _extractSection(raw, 'LIGHTING SUGGESTIONS'),
      'musicStyle':
          _extractSection(raw, 'MUSIC STYLE'),
    };
  }

  /// Parses strategy output.
  Map<String, dynamic> _parseStrategy(String raw) {
    final keywords =
        _extractSection(raw, 'SEO KEYWORDS').split(RegExp(r'[,\n]'));
    return {
      'bestPostingTime': _extractSection(raw, 'BEST POSTING TIME'),
      'seoKeywords':
          keywords.map((k) => k.trim()).where((k) => k.isNotEmpty).toList(),
      'repurposeIdeas':
          _parseNumberedList(_extractSection(raw, 'REPURPOSE IDEAS')),
    };
  }

  /// Parses cross-platform versions.
  Map<String, dynamic> _parseCrossPlatform(String raw) {
    return {
      'carouselVersion': _extractSection(raw, 'CAROUSEL VERSION'),
      'instagramStoryVersion':
          _extractSection(raw, 'INSTAGRAM STORY VERSION'),
      'facebookVersion': _extractSection(raw, 'FACEBOOK VERSION'),
      'linkedinVersion': _extractSection(raw, 'LINKEDIN VERSION'),
      'pinterestVersion': _extractSection(raw, 'PINTEREST VERSION'),
    };
  }

  /// Extracts a labeled section from raw AI output.
  String _extractSection(String raw, String label) {
    // Match from label: to next uppercase label or end
    final pattern = '$label\\s*:\\s*(.+?)(?=\\n\\s*[A-Z][A-Z ]+:|\$)';
    final match = RegExp(pattern, dotAll: true, caseSensitive: false)
        .firstMatch(raw);
    return match?.group(1)?.trim() ?? '';
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
