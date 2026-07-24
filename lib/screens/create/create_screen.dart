import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/subscription_service.dart';
import '../subscription/subscription_screen.dart';
import 'widgets/step_indicator.dart';
import 'steps/step_platform.dart';
import 'steps/step_niche.dart';
import 'steps/step_goal.dart';
import 'steps/step_tone.dart';
import 'steps/step_length.dart';
import 'create_result_screen.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  String? _platform;
  String? _niche;
  String? _goal;
  String? _tone;
  String? _length;

  bool get _canProceed {
    return switch (_currentStep) {
      0 => _platform != null,
      1 => _niche != null,
      2 => _goal != null,
      3 => _tone != null,
      4 => _length != null,
      _ => false,
    };
  }

  void _goNext() {
    if (!_canProceed) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _generateContent();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _generateContent() async {
    final sub = SubscriptionService();
    final canGenerate = await sub.canGenerate();

    if (!canGenerate) {
      if (!mounted) return;
      _showUpsellModal();
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateResultScreen(
          platform: _platform!,
          niche: _niche!,
          goal: _goal!,
          tone: _tone!,
          length: _length!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showUpsellModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppTheme.surface,
            border: Border.all(
              color: AppTheme.gold.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.2),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, AppTheme.primary],
                  ),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppTheme.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Daily Limit Reached',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'ve used all 3 free generations today.\nUpgrade to Creator Pro for unlimited\ncontent creation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SubscriptionScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        transitionDuration:
                            const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Upgrade to Pro — \$14.99/mo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Dismiss
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: StepIndicator(
          currentStep: _currentStep,
          totalSteps: _totalSteps,
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _goBack,
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                StepPlatform(
                  selected: _platform,
                  onSelect: (value) {
                    setState(() => _platform = value);
                  },
                ),
                StepNiche(
                  selected: _niche,
                  onSelect: (value) {
                    setState(() => _niche = value);
                  },
                ),
                StepGoal(
                  selected: _goal,
                  onSelect: (value) {
                    setState(() => _goal = value);
                  },
                ),
                StepTone(
                  selected: _tone,
                  onSelect: (value) {
                    setState(() => _tone = value);
                  },
                ),
                StepLength(
                  selected: _length,
                  onSelect: (value) {
                    setState(() => _length = value);
                  },
                ),
              ],
            ),
          ),
          // Bottom nav bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(
            color: AppTheme.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.white,
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed ? _goNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLastStep ? AppTheme.gold : AppTheme.primary,
                  foregroundColor:
                      isLastStep ? AppTheme.background : AppTheme.white,
                  disabledBackgroundColor: AppTheme.surfaceLight,
                  disabledForegroundColor:
                      AppTheme.white.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isLastStep ? 'Generate Content' : 'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _canProceed
                        ? (isLastStep ? AppTheme.background : AppTheme.white)
                        : AppTheme.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
