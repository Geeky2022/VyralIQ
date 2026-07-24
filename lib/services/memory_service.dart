import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// AI Memory — learns user preferences across sessions.
class MemoryService {
  static const _profileKey = 'vyraliq_user_profile';

  /// Loads the user's memory profile from local storage.
  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return UserProfile();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (_) {
      return UserProfile();
    }
  }

  /// Saves the user's memory profile to local storage.
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  /// Records usage of a platform/niche/tone combo and updates preferences.
  Future<void> recordUsage({
    required String platform,
    required String niche,
    required String tone,
  }) async {
    final profile = await loadProfile();
    profile.recordUsage(platform: platform, niche: niche, tone: tone);
    if (profile.learnFromMe) {
      profile.applyLearning();
    }
    await saveProfile(profile);
  }

  /// Resets the entire memory profile.
  Future<void> resetMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  /// Updates specific profile fields.
  Future<void> updateProfile({
    String? businessName,
    String? targetAudience,
    List<String>? brandColors,
    String? writingStyle,
    bool? learnFromMe,
    bool? darkMode,
  }) async {
    final profile = await loadProfile();
    if (businessName != null) profile.businessName = businessName;
    if (targetAudience != null) profile.targetAudience = targetAudience;
    if (brandColors != null) profile.brandColors = brandColors;
    if (writingStyle != null) profile.writingStyle = writingStyle;
    if (learnFromMe != null) profile.learnFromMe = learnFromMe;
    if (darkMode != null) profile.darkMode = darkMode;
    await saveProfile(profile);
  }
}
