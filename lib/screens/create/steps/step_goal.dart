import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../widgets/selection_card.dart';

class StepGoal extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const StepGoal({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<Map<String, dynamic>> goals = [
    {'label': 'Gain Followers', 'icon': Icons.person_add_rounded},
    {'label': 'Increase Sales', 'icon': Icons.trending_up_rounded},
    {'label': 'Educate', 'icon': Icons.school_rounded},
    {'label': 'Inspire', 'icon': Icons.emoji_objects_rounded},
    {'label': 'Entertain', 'icon': Icons.theater_comedy_rounded},
    {'label': 'Go Viral', 'icon': Icons.rocket_launch_rounded},
    {'label': 'Generate Leads', 'icon': Icons.people_alt_rounded},
    {'label': 'Increase Engagement', 'icon': Icons.favorite_rounded},
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
            'What\'s your goal?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'What do you want this content to achieve?',
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
                childAspectRatio: 1.6,
              ),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final g = goals[index];
                return SelectionCard(
                  label: g['label'] as String,
                  icon: g['icon'] as IconData,
                  isSelected: selected == g['label'],
                  onTap: () => onSelect(g['label'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
