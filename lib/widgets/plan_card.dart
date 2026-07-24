import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/subscription_service.dart';

/// A premium pricing card for subscription tiers with glassmorphism styling.
class PlanCard extends StatelessWidget {
  final SubscriptionTier tier;
  final bool isCurrentPlan;
  final VoidCallback? onUpgrade;

  const PlanCard({
    super.key,
    required this.tier,
    this.isCurrentPlan = false,
    this.onUpgrade,
  });

  bool get _isPro => tier == SubscriptionTier.pro;
  bool get _isElite => tier == SubscriptionTier.elite;
  bool get _isFree => tier == SubscriptionTier.free;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _isPro ? AppTheme.surface : AppTheme.surface.withValues(alpha: 0.7),
        border: Border.all(
          color: _isPro
              ? AppTheme.gold.withValues(alpha: 0.4)
              : AppTheme.surfaceLight.withValues(alpha: 0.3),
          width: _isPro ? 1.5 : 1,
        ),
        boxShadow: _isPro
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.08),
                  blurRadius: 48,
                  offset: const Offset(0, 24),
                ),
              ]
            : [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          // Badge row (Recommended / Current Plan / Best Value)
          if (tier.badgeLabel.isNotEmpty || isCurrentPlan)
            _buildBadgeRow(),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Tier name
                Text(
                  tier.displayName,
                  style: TextStyle(
                    color: _isPro ? AppTheme.gold : AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Price
                _buildPrice(),
                const SizedBox(height: 20),

                // Divider
                Container(
                  height: 1,
                  color: AppTheme.surfaceLight.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 20),

                // Features
                ..._buildFeatures(),

                const SizedBox(height: 24),

                // CTA Button
                _buildCTA(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeRow() {
    final label = isCurrentPlan && _isFree ? 'Current Plan' : tier.badgeLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          colors: _isPro
              ? [AppTheme.gold.withValues(alpha: 0.15), AppTheme.primary.withValues(alpha: 0.1)]
              : _isElite
                  ? [AppTheme.violet.withValues(alpha: 0.15), AppTheme.primary.withValues(alpha: 0.08)]
                  : [AppTheme.surfaceLight.withValues(alpha: 0.3), AppTheme.surfaceLight.withValues(alpha: 0.1)],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isPro)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.star_rounded, color: AppTheme.gold, size: 16),
              ),
            Text(
              label,
              style: TextStyle(
                color: _isPro ? AppTheme.gold : _isElite ? AppTheme.violet : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrice() {
    if (_isFree) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$0',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          SizedBox(width: 4),
          Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              '/month',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${tier.monthlyPrice!.toStringAsFixed(2)}',
          style: TextStyle(
            color: _isPro ? AppTheme.gold : AppTheme.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 4),
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            '/month',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatures() {
    final features = _getFeatureList();
    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.success.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.success,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<String> _getFeatureList() {
    switch (tier) {
      case SubscriptionTier.free:
        return [
          '3 generations per day',
          'Basic hooks & captions',
          'Single brand profile',
          'Watermarked exports',
          'Basic analytics',
        ];
      case SubscriptionTier.pro:
        return [
          'Unlimited generations',
          'Unlimited scripts & hooks',
          'Weekly content planner',
          'Saved history & library',
          'Brand voice customization',
          'No watermark on exports',
          'Cross-platform adaptation',
          'SEO strategy & keywords',
        ];
      case SubscriptionTier.elite:
        return [
          'Everything in Creator Pro',
          'AI Image Prompt Builder',
          'AI Video Prompt Builder',
          'Advanced analytics dashboard',
          'Multiple brand profiles',
          'Priority AI processing',
          'Future team collaboration',
          'Early access to new features',
        ];
    }
  }

  Widget _buildCTA(BuildContext context) {
    if (isCurrentPlan && _isFree) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.surfaceLight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Current Plan',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (isCurrentPlan) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.success.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
              SizedBox(width: 8),
              Text(
                'Current Plan',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final label = _isPro ? 'Upgrade to Pro' : 'Go Elite';
    final color = _isPro ? AppTheme.gold : AppTheme.violet;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onUpgrade,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: _isPro ? AppTheme.background : AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _isPro ? 4 : 0,
          shadowColor: _isPro ? AppTheme.gold.withValues(alpha: 0.3) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _isPro ? AppTheme.background : AppTheme.white,
          ),
        ),
      ),
    );
  }
}

/// A compact usage progress bar showing generations used / limit.
class UsageProgressBar extends StatelessWidget {
  final int used;
  final int limit;

  const UsageProgressBar({
    super.key,
    required this.used,
    required this.limit,
  });

  double get _progress => limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

  bool get _isNearLimit => remaining <= 1 && remaining > 0;
  bool get _isExhausted => remaining <= 0;
  int get remaining => (limit - used).clamp(0, limit);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generations Today',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$used of $limit',
              style: TextStyle(
                color: _isExhausted
                    ? AppTheme.error
                    : _isNearLimit
                        ? AppTheme.gold
                        : AppTheme.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isExhausted
                    ? AppTheme.error
                    : _isNearLimit
                        ? AppTheme.gold
                        : AppTheme.primary,
              ),
            ),
          ),
        ),
        if (_isExhausted) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.error, size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Daily limit reached. Upgrade for unlimited generations.',
                  style: TextStyle(color: AppTheme.error, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
