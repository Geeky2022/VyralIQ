import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../widgets/selection_card.dart';

class StepPlatform extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const StepPlatform({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<Map<String, dynamic>> platforms = [
    {'label': 'TikTok', 'emoji': '🎵'},
    {'label': 'Instagram', 'emoji': '📸'},
    {'label': 'Facebook', 'emoji': '👍'},
    {'label': 'YouTube', 'emoji': '▶️'},
    {'label': 'LinkedIn', 'emoji': '💼'},
    {'label': 'Pinterest', 'emoji': '📌'},
    {'label': 'Threads', 'emoji': '🧵'},
    {'label': 'X', 'emoji': '🐦'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Where will you post?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the platform you\'re creating for.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.5,
              ),
              itemCount: platforms.length,
              itemBuilder: (context, index) {
                final p = platforms[index];
                return SelectionCard(
                  label: p['label'] as String,
                  emoji: p['emoji'] as String,
                  isSelected: selected == p['label'],
                  onTap: () => onSelect(p['label'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
