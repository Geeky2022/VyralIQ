import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../widgets/selection_card.dart';

class StepTone extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const StepTone({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<String> tones = [
    'Luxury',
    'Funny',
    'Storytelling',
    'Educational',
    'Professional',
    'Motivational',
    'Emotional',
    'Bold',
    'Calm',
    'Friendly',
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
            'Pick your tone',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'How should the AI sound in your content?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: tones.length,
              itemBuilder: (context, index) {
                final tone = tones[index];
                return SelectionCard(
                  label: tone,
                  isSelected: selected == tone,
                  onTap: () => onSelect(tone),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
