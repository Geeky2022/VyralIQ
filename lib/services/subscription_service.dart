import 'package:shared_preferences/shared_preferences.dart';

/// Subscription tier enum for feature gating.
enum SubscriptionTier {
  free,
  pro,
  elite;

  String get displayName => switch (this) {
        free => 'Free',
        pro => 'Creator Pro',
        elite => 'Creator Elite',
      };

  String get badgeLabel => switch (this) {
        free => 'Current Plan',
        pro => 'Recommended',
        elite => 'Best Value',
      };

  /// Monthly price in USD, null for free.
  double? get monthlyPrice => switch (this) {
        free => null,
        pro => 14.99,
        elite => 29.99,
      };

  int get dailyGenerationLimit => switch (this) {
        free => 3,
        pro => 999999, // effectively unlimited
        elite => 999999,
      };

  bool get hasWatermark => switch (this) {
        free => true,
        pro => false,
        elite => false,
      };

  bool get hasAdvancedAnalytics => switch (this) {
        free => false,
        pro => false,
        elite => true,
      };

  bool get hasMultipleBrands => switch (this) {
        free => false,
        pro => false,
        elite => true,
      };

  bool get hasAIImageVideo => switch (this) {
        free => false,
        pro => false,
        elite => true,
      };

  bool get hasPriorityAI => switch (this) {
        free => false,
        pro => false,
        elite => true,
      };
}

/// Manages subscription tier state, usage tracking, and daily limits.
/// Persists data in shared_preferences.
class SubscriptionService {
  static const _tierKey = 'vyraliq_sub_tier';
  static const _genCountKey = 'vyraliq_gen_count';
  static const _genDateKey = 'vyraliq_gen_date';

  static SubscriptionService? _instance;

  /// Returns the singleton instance.
  factory SubscriptionService() {
    _instance ??= SubscriptionService._();
    return _instance!;
  }

  SubscriptionService._();

  // ---------------------------------------------------------------------------
  // Tier Management
  // ---------------------------------------------------------------------------

  /// Returns the current subscription tier (defaults to free).
  Future<SubscriptionTier> getTier() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_tierKey) ?? 0;
    return SubscriptionTier.values[index.clamp(0, SubscriptionTier.values.length - 1)];
  }

  /// Sets the subscription tier (used after Stripe payment confirmation).
  Future<void> setTier(SubscriptionTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tierKey, tier.index);
  }

  /// Returns true if the user is on a paid tier.
  Future<bool> get isPaid async {
    final tier = await getTier();
    return tier != SubscriptionTier.free;
  }

  /// Returns true if the user is on the elite tier.
  Future<bool> get isElite async {
    final tier = await getTier();
    return tier == SubscriptionTier.elite;
  }

  // ---------------------------------------------------------------------------
  // Usage Tracking
  // ---------------------------------------------------------------------------

  /// Returns the number of generations used today.
  Future<int> getGenerationsUsedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_genDateKey);
    final today = _todayString();

    if (lastDate != today) {
      // New day — reset counter
      await prefs.setInt(_genCountKey, 0);
      await prefs.setString(_genDateKey, today);
      return 0;
    }

    return prefs.getInt(_genCountKey) ?? 0;
  }

  /// Returns the number of remaining generations for today.
  Future<int> getGenerationsRemaining() async {
    final tier = await getTier();
    final used = await getGenerationsUsedToday();
    final limit = tier.dailyGenerationLimit;
    final remaining = limit - used;
    return remaining < 0 ? 0 : remaining;
  }

  /// Records a generation event and increments the daily counter.
  /// Returns the number of remaining generations after recording.
  Future<int> recordGeneration() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final lastDate = prefs.getString(_genDateKey);

    int count;
    if (lastDate != today) {
      count = 1;
    } else {
      count = (prefs.getInt(_genCountKey) ?? 0) + 1;
    }

    await prefs.setInt(_genCountKey, count);
    await prefs.setString(_genDateKey, today);

    final tier = await getTier();
    final remaining = tier.dailyGenerationLimit - count;
    return remaining < 0 ? 0 : remaining;
  }

  /// Checks whether the user can generate more content today.
  Future<bool> canGenerate() async {
    final remaining = await getGenerationsRemaining();
    return remaining > 0;
  }

  // ---------------------------------------------------------------------------
  // Feature Gates
  // ---------------------------------------------------------------------------

  /// Returns true if the watermark should be shown on exports.
  Future<bool> get hasWatermark async {
    final tier = await getTier();
    return tier.hasWatermark;
  }

  /// Returns true if advanced analytics are unlocked.
  Future<bool> get hasAdvancedAnalytics async {
    final tier = await getTier();
    return tier.hasAdvancedAnalytics;
  }

  /// Returns true if multiple brands are unlocked.
  Future<bool> get hasMultipleBrands async {
    final tier = await getTier();
    return tier.hasMultipleBrands;
  }

  /// Returns true if AI image/video prompt builders are unlocked.
  Future<bool> get hasAIImageVideo async {
    final tier = await getTier();
    return tier.hasAIImageVideo;
  }

  /// Returns true if priority AI processing is enabled.
  Future<bool> get hasPriorityAI async {
    final tier = await getTier();
    return tier.hasPriorityAI;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Resets all subscription data (for testing).
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tierKey);
    await prefs.remove(_genCountKey);
    await prefs.remove(_genDateKey);
  }
}
