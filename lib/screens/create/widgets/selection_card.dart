import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// A tappable selection card used across all create-flow steps.
/// Shows an icon, label, and optional emoji with selected/unselected styling.
class SelectionCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.6)
                : AppTheme.surfaceLight.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Text(
                emoji!,
                style: const TextStyle(fontSize: 28),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 28,
                color: isSelected ? AppTheme.white : AppTheme.textSecondary,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
