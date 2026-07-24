import 'script.dart';

/// Holds ALL AI-generated content for a single generation run.
class GenerationResult {
  final List<String> viralHooks;
  final List<String> videoIdeas;
  final List<Script> scripts;
  final String caption;
  final String cta;
  final List<String> hashtags;
  final String thumbnailText;
  final String editingSuggestions;
  final List<String> bRollIdeas;
  final String cameraAngles;
  final String lightingSuggestions;
  final String musicStyle;
  final String bestPostingTime;
  final List<String> seoKeywords;
  final List<String> repurposeIdeas;
  final String carouselVersion;
  final String instagramStoryVersion;
  final String facebookVersion;
  final String linkedinVersion;
  final String pinterestVersion;

  /// The user selections that produced this result.
  final String platform;
  final String niche;
  final String goal;
  final String tone;
  final String length;

  const GenerationResult({
    this.viralHooks = const [],
    this.videoIdeas = const [],
    this.scripts = const [],
    this.caption = '',
    this.cta = '',
    this.hashtags = const [],
    this.thumbnailText = '',
    this.editingSuggestions = '',
    this.bRollIdeas = const [],
    this.cameraAngles = '',
    this.lightingSuggestions = '',
    this.musicStyle = '',
    this.bestPostingTime = '',
    this.seoKeywords = const [],
    this.repurposeIdeas = const [],
    this.carouselVersion = '',
    this.instagramStoryVersion = '',
    this.facebookVersion = '',
    this.linkedinVersion = '',
    this.pinterestVersion = '',
    required this.platform,
    required this.niche,
    required this.goal,
    required this.tone,
    required this.length,
  });

  /// Returns true if this result contains no generated content yet.
  bool get isEmpty =>
      viralHooks.isEmpty &&
      videoIdeas.isEmpty &&
      scripts.isEmpty &&
      caption.isEmpty;

  /// Returns true if at least some content has been generated.
  bool get isNotEmpty => !isEmpty;

  /// Merges another result into this one.
  GenerationResult merge(GenerationResult other) {
    return GenerationResult(
      viralHooks: other.viralHooks.isNotEmpty ? other.viralHooks : viralHooks,
      videoIdeas: other.videoIdeas.isNotEmpty ? other.videoIdeas : videoIdeas,
      scripts: other.scripts.isNotEmpty ? other.scripts : scripts,
      caption: other.caption.isNotEmpty ? other.caption : caption,
      cta: other.cta.isNotEmpty ? other.cta : cta,
      hashtags: other.hashtags.isNotEmpty ? other.hashtags : hashtags,
      thumbnailText:
          other.thumbnailText.isNotEmpty ? other.thumbnailText : thumbnailText,
      editingSuggestions: other.editingSuggestions.isNotEmpty
          ? other.editingSuggestions
          : editingSuggestions,
      bRollIdeas:
          other.bRollIdeas.isNotEmpty ? other.bRollIdeas : bRollIdeas,
      cameraAngles:
          other.cameraAngles.isNotEmpty ? other.cameraAngles : cameraAngles,
      lightingSuggestions: other.lightingSuggestions.isNotEmpty
          ? other.lightingSuggestions
          : lightingSuggestions,
      musicStyle:
          other.musicStyle.isNotEmpty ? other.musicStyle : musicStyle,
      bestPostingTime: other.bestPostingTime.isNotEmpty
          ? other.bestPostingTime
          : bestPostingTime,
      seoKeywords:
          other.seoKeywords.isNotEmpty ? other.seoKeywords : seoKeywords,
      repurposeIdeas: other.repurposeIdeas.isNotEmpty
          ? other.repurposeIdeas
          : repurposeIdeas,
      carouselVersion: other.carouselVersion.isNotEmpty
          ? other.carouselVersion
          : carouselVersion,
      instagramStoryVersion: other.instagramStoryVersion.isNotEmpty
          ? other.instagramStoryVersion
          : instagramStoryVersion,
      facebookVersion: other.facebookVersion.isNotEmpty
          ? other.facebookVersion
          : facebookVersion,
      linkedinVersion: other.linkedinVersion.isNotEmpty
          ? other.linkedinVersion
          : linkedinVersion,
      pinterestVersion: other.pinterestVersion.isNotEmpty
          ? other.pinterestVersion
          : pinterestVersion,
      platform: platform,
      niche: niche,
      goal: goal,
      tone: tone,
      length: length,
    );
  }

  /// Creates a copy with the given fields replaced.
  GenerationResult copyWith({
    List<String>? viralHooks,
    List<String>? videoIdeas,
    List<Script>? scripts,
    String? caption,
    String? cta,
    List<String>? hashtags,
    String? thumbnailText,
    String? editingSuggestions,
    List<String>? bRollIdeas,
    String? cameraAngles,
    String? lightingSuggestions,
    String? musicStyle,
    String? bestPostingTime,
    List<String>? seoKeywords,
    List<String>? repurposeIdeas,
    String? carouselVersion,
    String? instagramStoryVersion,
    String? facebookVersion,
    String? linkedinVersion,
    String? pinterestVersion,
  }) {
    return GenerationResult(
      viralHooks: viralHooks ?? this.viralHooks,
      videoIdeas: videoIdeas ?? this.videoIdeas,
      scripts: scripts ?? this.scripts,
      caption: caption ?? this.caption,
      cta: cta ?? this.cta,
      hashtags: hashtags ?? this.hashtags,
      thumbnailText: thumbnailText ?? this.thumbnailText,
      editingSuggestions: editingSuggestions ?? this.editingSuggestions,
      bRollIdeas: bRollIdeas ?? this.bRollIdeas,
      cameraAngles: cameraAngles ?? this.cameraAngles,
      lightingSuggestions: lightingSuggestions ?? this.lightingSuggestions,
      musicStyle: musicStyle ?? this.musicStyle,
      bestPostingTime: bestPostingTime ?? this.bestPostingTime,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      repurposeIdeas: repurposeIdeas ?? this.repurposeIdeas,
      carouselVersion: carouselVersion ?? this.carouselVersion,
      instagramStoryVersion:
          instagramStoryVersion ?? this.instagramStoryVersion,
      facebookVersion: facebookVersion ?? this.facebookVersion,
      linkedinVersion: linkedinVersion ?? this.linkedinVersion,
      pinterestVersion: pinterestVersion ?? this.pinterestVersion,
      platform: platform,
      niche: niche,
      goal: goal,
      tone: tone,
      length: length,
    );
  }
}

/// Serialization helpers for GenerationResult.
extension GenerationResultJson on GenerationResult {
  Map<String, dynamic> toJson() => {
        'viralHooks': viralHooks,
        'videoIdeas': videoIdeas,
        'scripts': scripts.map((s) => s.toJson()).toList(),
        'caption': caption,
        'cta': cta,
        'hashtags': hashtags,
        'thumbnailText': thumbnailText,
        'editingSuggestions': editingSuggestions,
        'bRollIdeas': bRollIdeas,
        'cameraAngles': cameraAngles,
        'lightingSuggestions': lightingSuggestions,
        'musicStyle': musicStyle,
        'bestPostingTime': bestPostingTime,
        'seoKeywords': seoKeywords,
        'repurposeIdeas': repurposeIdeas,
        'carouselVersion': carouselVersion,
        'instagramStoryVersion': instagramStoryVersion,
        'facebookVersion': facebookVersion,
        'linkedinVersion': linkedinVersion,
        'pinterestVersion': pinterestVersion,
        'platform': platform,
        'niche': niche,
        'goal': goal,
        'tone': tone,
        'length': length,
        'savedAt': DateTime.now().toIso8601String(),
      };

  factory GenerationResult.fromJson(Map<String, dynamic> json) {
    return GenerationResult(
      viralHooks: List<String>.from(json['viralHooks'] ?? []),
      videoIdeas: List<String>.from(json['videoIdeas'] ?? []),
      scripts: (json['scripts'] as List<dynamic>?)
              ?.map((s) => Script.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      caption: json['caption'] as String? ?? '',
      cta: json['cta'] as String? ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      thumbnailText: json['thumbnailText'] as String? ?? '',
      editingSuggestions: json['editingSuggestions'] as String? ?? '',
      bRollIdeas: List<String>.from(json['bRollIdeas'] ?? []),
      cameraAngles: json['cameraAngles'] as String? ?? '',
      lightingSuggestions: json['lightingSuggestions'] as String? ?? '',
      musicStyle: json['musicStyle'] as String? ?? '',
      bestPostingTime: json['bestPostingTime'] as String? ?? '',
      seoKeywords: List<String>.from(json['seoKeywords'] ?? []),
      repurposeIdeas: List<String>.from(json['repurposeIdeas'] ?? []),
      carouselVersion: json['carouselVersion'] as String? ?? '',
      instagramStoryVersion: json['instagramStoryVersion'] as String? ?? '',
      facebookVersion: json['facebookVersion'] as String? ?? '',
      linkedinVersion: json['linkedinVersion'] as String? ?? '',
      pinterestVersion: json['pinterestVersion'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      niche: json['niche'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      tone: json['tone'] as String? ?? '',
      length: json['length'] as String? ?? '',
    );
  }
}
