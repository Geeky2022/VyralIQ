import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../widgets/selection_card.dart';

class StepNiche extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const StepNiche({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<String> niches = [
    'Business',
    'Fitness',
    'Beauty',
    'Parenting',
    'Gaming',
    'Fashion',
    'Faith',
    'Motivation',
    'Finance',
    'Education',
    'Food',
    'Travel',
    'Lifestyle',
    'Real Estate',
    'Technology',
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
            'What\'s your niche?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the category that best fits your content.',
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
              itemCount: niches.length,
              itemBuilder: (context, index) {
                final niche = niches[index];
                return SelectionCard(
                  label: niche,
                  isSelected: selected == niche,
                  onTap: () => onSelect(niche),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
