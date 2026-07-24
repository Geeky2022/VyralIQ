/// User memory profile — preferences learned across sessions.
class UserProfile {
  String preferredNiche;
  String preferredTone;
  String favoritePlatform;
  List<String> brandColors;
  String targetAudience;
  String writingStyle;
  String businessName;
  bool learnFromMe;
  bool darkMode;

  /// Usage history counters for auto-detection.
  Map<String, int> platformUsage;
  Map<String, int> nicheUsage;
  Map<String, int> toneUsage;

  UserProfile({
    this.preferredNiche = '',
    this.preferredTone = '',
    this.favoritePlatform = '',
    this.brandColors = const ['#7C3AED', '#8B5CF6'],
    this.targetAudience = '',
    this.writingStyle = '',
    this.businessName = '',
    this.learnFromMe = true,
    this.darkMode = true,
    Map<String, int>? platformUsage,
    Map<String, int>? nicheUsage,
    Map<String, int>? toneUsage,
  })  : platformUsage = platformUsage ?? {},
        nicheUsage = nicheUsage ?? {},
        toneUsage = toneUsage ?? {};

  /// Record usage of a specific platform/niche/tone combo.
  void recordUsage({
    required String platform,
    required String niche,
    required String tone,
  }) {
    if (!learnFromMe) return;
    platformUsage[platform] = (platformUsage[platform] ?? 0) + 1;
    nicheUsage[niche] = (nicheUsage[niche] ?? 0) + 1;
    toneUsage[tone] = (toneUsage[tone] ?? 0) + 1;
  }

  /// Returns the most frequently used platform, or empty string.
  String get mostUsedPlatform {
    if (platformUsage.isEmpty) return '';
    return platformUsage.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Returns the most frequently used niche, or empty string.
  String get mostUsedNiche {
    if (nicheUsage.isEmpty) return '';
    return nicheUsage.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Returns the most frequently used tone, or empty string.
  String get mostUsedTone {
    if (toneUsage.isEmpty) return '';
    return toneUsage.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Auto-apply learned preferences.
  void applyLearning() {
    final p = mostUsedPlatform;
    final n = mostUsedNiche;
    final t = mostUsedTone;
    if (p.isNotEmpty) favoritePlatform = p;
    if (n.isNotEmpty) preferredNiche = n;
    if (t.isNotEmpty) preferredTone = t;
  }

  Map<String, dynamic> toJson() => {
        'preferredNiche': preferredNiche,
        'preferredTone': preferredTone,
        'favoritePlatform': favoritePlatform,
        'brandColors': brandColors,
        'targetAudience': targetAudience,
        'writingStyle': writingStyle,
        'businessName': businessName,
        'learnFromMe': learnFromMe,
        'darkMode': darkMode,
        'platformUsage': platformUsage,
        'nicheUsage': nicheUsage,
        'toneUsage': toneUsage,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      preferredNiche: json['preferredNiche'] as String? ?? '',
      preferredTone: json['preferredTone'] as String? ?? '',
      favoritePlatform: json['favoritePlatform'] as String? ?? '',
      brandColors: List<String>.from(json['brandColors'] ?? ['#7C3AED', '#8B5CF6']),
      targetAudience: json['targetAudience'] as String? ?? '',
      writingStyle: json['writingStyle'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      learnFromMe: json['learnFromMe'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? true,
      platformUsage: Map<String, int>.from(json['platformUsage'] ?? {}),
      nicheUsage: Map<String, int>.from(json['nicheUsage'] ?? {}),
      toneUsage: Map<String, int>.from(json['toneUsage'] ?? {}),
    );
  }
}
