import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Horizontal step progress indicator showing 5 dots with labels.
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;

        Color dotColor;
        if (isActive) {
          dotColor = AppTheme.primary;
        } else if (isCompleted) {
          dotColor = AppTheme.success;
        } else {
          dotColor = AppTheme.white.withValues(alpha: 0.2);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: isActive ? 32 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          ),
        );
      }),
    );
  }
}
