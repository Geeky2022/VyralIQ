import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final StorageService _storage = StorageService();

  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _historyRaw = [];
  Map<String, List<Map<String, dynamic>>> _contentByDay = {};
  bool _loading = true;

  String? _plannedPlatform;
  String? _plannedNiche;
  String? _plannedGoal;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _platforms = ['Instagram', 'TikTok', 'YouTube', 'LinkedIn', 'Twitter/X', 'Facebook', 'Pinterest'];
  static const _niches = ['Fashion', 'Fitness', 'Food', 'Tech', 'Business', 'Beauty', 'Travel', 'Finance', 'Education', 'Gaming'];
  static const _goals = ['Awareness', 'Engagement', 'Sales', 'Followers', 'Traffic', 'Education', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final raw = await _storage.getHistoryRaw();

    // Group content by day
    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final entry in raw) {
      final savedAt = entry['savedAt'] as String?;
      if (savedAt != null) {
        try {
          final dt = DateTime.parse(savedAt);
          final dayKey = DateFormat('yyyy-MM-dd').format(dt);
          byDay.putIfAbsent(dayKey, () => []).add(entry);
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        _historyRaw = raw;
        _contentByDay = byDay;
        _loading = false;
      });
    }
  }

  DateTime get _weekStart {
    return _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
  }

  String _dayKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  String _getPlatformIcon(String? platform) {
    switch ((platform ?? '').toLowerCase()) {
      case 'instagram': return '📸';
      case 'tiktok': return '🎵';
      case 'youtube': return '▶️';
      case 'linkedin': return '💼';
      case 'twitter': case 'x': return '🐦';
      case 'facebook': return '👥';
      case 'pinterest': return '📌';
      default: return '📱';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = _dayKey(_selectedDay);
    final dayContent = _contentByDay[selectedKey] ?? [];
    final selectedDayName = DateFormat('EEEE, MMMM d').format(_selectedDay);
    final isToday = _dayKey(DateTime.now()) == selectedKey;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Weekly Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.gold),
            tooltip: 'Generate Week',
            onPressed: () {
              // Navigate to weekly generation in create flow
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                // Horizontal week scroller
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final day = _weekStart.add(Duration(days: index));
                      final key = _dayKey(day);
                      final hasContent = _contentByDay.containsKey(key) && _contentByDay[key]!.isNotEmpty;
                      final isSelected = key == selectedKey;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? AppTheme.primary.withValues(alpha: 0.3)
                                : AppTheme.surfaceLight.withValues(alpha: 0.3),
                            border: isSelected
                                ? Border.all(color: AppTheme.primary, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _days[index],
                                style: TextStyle(
                                  color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: isSelected ? AppTheme.white : AppTheme.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (hasContent) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.gold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Day detail header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        selectedDayName,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.gold.withValues(alpha: 0.2),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${dayContent.length} items',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Planning section (if no content)
                if (dayContent.isEmpty)
                  _buildPlanningSection()
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: dayContent.length,
                      itemBuilder: (context, index) {
                        final entry = dayContent[index];
                        return _DayContentCard(entry: entry);
                      },
                    ),
                  ),
              ],
            ),
      ),
    );
  }

  Widget _buildPlanningSection() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.surface,
                border: Border.all(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.event_note_rounded, color: AppTheme.textSecondary, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'No content planned for this day',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Generate Content'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 44),
                      backgroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick plan
            const Text(
              'Quick Plan',
              style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),

            // Platform picker
            _QuickPlanSection(
              title: 'Platform',
              icon: Icons.phone_iphone_rounded,
              selected: _plannedPlatform,
              options: _platforms,
              onSelected: (v) => setState(() => _plannedPlatform = v),
            ),
            const SizedBox(height: 12),

            // Niche picker
            _QuickPlanSection(
              title: 'Niche',
              icon: Icons.category_rounded,
              selected: _plannedNiche,
              options: _niches,
              onSelected: (v) => setState(() => _plannedNiche = v),
            ),
            const SizedBox(height: 12),

            // Goal picker
            _QuickPlanSection(
              title: 'Goal',
              icon: Icons.flag_rounded,
              selected: _plannedGoal,
              options: _goals,
              onSelected: (v) => setState(() => _plannedGoal = v),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (_plannedPlatform != null && _plannedNiche != null && _plannedGoal != null)
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Day planned! Go to Create to generate.'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Save Plan'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day Content Card
// ---------------------------------------------------------------------------

class _DayContentCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _DayContentCard({required this.entry});

  String _getPlatformIcon() {
    final p = (entry['platform'] as String? ?? '').toLowerCase();
    switch (p) {
      case 'instagram': return '📸';
      case 'tiktok': return '🎵';
      case 'youtube': return '▶️';
      case 'linkedin': return '💼';
      case 'twitter': case 'x': return '🐦';
      case 'facebook': return '👥';
      case 'pinterest': return '📌';
      default: return '📱';
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = entry['platform'] as String? ?? '';
    final niche = entry['niche'] as String? ?? '';
    final caption = entry['caption'] as String? ?? '';
    final hooks = (entry['viralHooks'] as List<dynamic>?) ?? [];
    final hashtags = (entry['hashtags'] as List<dynamic>?) ?? [];

    final preview = caption.isNotEmpty
        ? (caption.length > 60 ? '${caption.substring(0, 60)}...' : caption)
        : (hooks.isNotEmpty ? hooks.first.toString() : 'Generated content');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.surface,
        border: Border.all(
          color: AppTheme.surfaceLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getPlatformIcon(), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.primary.withValues(alpha: 0.15),
                ),
                child: Text(
                  platform,
                  style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              if (niche.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.gold.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    niche,
                    style: const TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(preview, style: const TextStyle(color: AppTheme.white, fontSize: 14, height: 1.5)),
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: hashtags.take(4).map<Widget>((h) {
                final tag = h.toString().startsWith('#') ? h.toString() : '#${h.toString()}';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppTheme.primary.withValues(alpha: 0.08),
                  ),
                  child: Text(tag, style: const TextStyle(color: AppTheme.violet, fontSize: 11)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Plan Section
// ---------------------------------------------------------------------------

class _QuickPlanSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? selected;
  final List<String> options;
  final void Function(String) onSelected;

  const _QuickPlanSection({
    required this.title,
    required this.icon,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.surface,
        border: Border.all(
          color: AppTheme.surfaceLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((o) {
              final isSelected = selected == o;
              return GestureDetector(
                onTap: () => onSelected(o),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.25)
                        : AppTheme.surfaceLight.withValues(alpha: 0.3),
                    border: isSelected
                        ? Border.all(color: AppTheme.primary, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    o,
                    style: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
