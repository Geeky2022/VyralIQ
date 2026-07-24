import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/subscription_service.dart';
import '../../widgets/plan_card.dart';

/// Full subscription paywall / pricing screen with luxury design.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _sub = SubscriptionService();

  SubscriptionTier? _currentTier;
  int _usedToday = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tier = await _sub.getTier();
    final used = await _sub.getGenerationsUsedToday();
    setState(() {
      _currentTier = tier;
      _usedToday = used;
      _loading = false;
    });
  }

  // Stripe payment links for each tier
  static const _paymentLinks = {
    SubscriptionTier.pro: 'https://buy.stripe.com/bJe9AVfKL8jL98A8FP6wE00',
    SubscriptionTier.elite: 'https://buy.stripe.com/aFabJ3gOPbvXdoQ1dn6wE01',
  };

  Future<void> _onUpgrade(SubscriptionTier tier) async {
    final url = _paymentLinks[tier];
    if (url == null) return;

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open checkout. Please try again.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final freeLimit = SubscriptionTier.free.dailyGenerationLimit;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        children: [
          // Hero header
          _buildHeroHeader(),
          const SizedBox(height: 32),

          // Current usage (if on free)
          if (_currentTier == SubscriptionTier.free) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.surface,
                border: Border.all(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                ),
              ),
              child: UsageProgressBar(used: _usedToday, limit: freeLimit),
            ),
            const SizedBox(height: 24),
          ],

          // Plan cards
          PlanCard(
            tier: SubscriptionTier.free,
            isCurrentPlan: _currentTier == SubscriptionTier.free,
            onUpgrade: _currentTier != SubscriptionTier.free
                ? () => _onUpgrade(SubscriptionTier.free)
                : null,
          ),

          PlanCard(
            tier: SubscriptionTier.pro,
            isCurrentPlan: _currentTier == SubscriptionTier.pro,
            onUpgrade: _currentTier != SubscriptionTier.pro
                ? () => _onUpgrade(SubscriptionTier.pro)
                : null,
          ),

          PlanCard(
            tier: SubscriptionTier.elite,
            isCurrentPlan: _currentTier == SubscriptionTier.elite,
            onUpgrade: _currentTier != SubscriptionTier.elite
                ? () => _onUpgrade(SubscriptionTier.elite)
                : null,
          ),

          const SizedBox(height: 32),

          // Features comparison link
          _buildComparisonLink(),

          const SizedBox(height: 24),

          // Footer
          const Text(
            'All plans include a 7-day free trial of Creator Pro.\n'
            'Cancel anytime. No questions asked.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Gold accent line
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppTheme.gold, AppTheme.primary],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Title with gold accent
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Choose Your ',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Plan',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: AppTheme.gold.withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Unlock your full creative potential.\nNo contracts. Cancel anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        // Payment security note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppTheme.success.withValues(alpha: 0.08),
            border: Border.all(
              color: AppTheme.success.withValues(alpha: 0.15),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, color: AppTheme.success, size: 16),
              SizedBox(width: 8),
              Text(
                'Secure payment powered by Stripe',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonLink() {
    return GestureDetector(
      onTap: () {
        // Simple feature comparison as a bottom sheet
        _showFeatureComparison();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows_rounded, color: AppTheme.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'Compare all features',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureComparison() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FeatureComparisonSheet(),
    );
  }
}

/// A bottom sheet showing a detailed feature comparison across tiers.
class _FeatureComparisonSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: AppTheme.surfaceLight,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Feature Comparison',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: _ComparisonTable(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.0),
        1: FlexColumnWidth(1.0),
        2: FlexColumnWidth(1.0),
        3: FlexColumnWidth(1.0),
      },
      children: [
        _comparisonHeader(),
        _comparisonRow('Daily Generations', '3', 'Unlimited', 'Unlimited'),
        _comparisonRow('Viral Hooks', 'Basic', 'Unlimited', 'Unlimited'),
        _comparisonRow('Script Writer', 'Basic', 'Unlimited', 'Unlimited'),
        _comparisonRow('Caption Generator', '✓', '✓', '✓'),
        _comparisonRow('Weekly Planner', '—', '✓', '✓'),
        _comparisonRow('Saved History', '—', '✓', '✓'),
        _comparisonRow('Brand Voice', '—', '✓', '✓'),
        _comparisonRow('Watermark-Free', '—', '✓', '✓'),
        _comparisonRow('AI Image Prompts', '—', '—', '✓'),
        _comparisonRow('AI Video Prompts', '—', '—', '✓'),
        _comparisonRow('Advanced Analytics', '—', '—', '✓'),
        _comparisonRow('Multiple Brands', '—', '—', '✓'),
        _comparisonRow('Priority AI', '—', '—', '✓'),
        _comparisonRow('Team Collab', '—', '—', 'Coming Soon'),
      ],
    );
  }

  TableRow _comparisonHeader() {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.surfaceLight.withValues(alpha: 0.5)),
        ),
      ),
      children: const [
        _HeaderCell(''),
        _HeaderCell('Free'),
        _HeaderCell('Pro'),
        _HeaderCell('Elite'),
      ],
    );
  }

  TableRow _comparisonRow(String feature, String free, String pro, String elite) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.surfaceLight.withValues(alpha: 0.2)),
        ),
      ),
      children: [
        _FeatureCell(feature),
        _ValueCell(free),
        _ValueCell(pro, highlighted: true),
        _ValueCell(elite),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: text.isEmpty ? Colors.transparent : AppTheme.gold,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _FeatureCell extends StatelessWidget {
  final String text;
  const _FeatureCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String text;
  final bool highlighted;
  const _ValueCell(this.text, {this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final isCheck = text == '✓';
    final isDash = text == '—';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isCheck
              ? AppTheme.success
              : isDash
                  ? AppTheme.textSecondary.withValues(alpha: 0.4)
                  : highlighted
                      ? AppTheme.gold
                      : AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
