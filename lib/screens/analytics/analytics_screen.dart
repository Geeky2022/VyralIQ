import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../services/memory_service.dart';
import '../planner/weekly_planner_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final StorageService _storage = StorageService();
  final MemoryService _memory = MemoryService();

  int _postsCreated = 0;
  int _ideasGenerated = 0;
  int _dailyStreak = 0;
  int _followersGoal = 10000;
  int _followersCurrent = 0;

  List<Map<String, dynamic>> _historyRaw = [];
  Map<String, int> _dayContentCount = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await _storage.getHistory();
    final raw = await _storage.getHistoryRaw();
    final streak = await _storage.getStreak();

    // Count ideas: hooks + video ideas + scripts
    int ideas = 0;
    for (final r in history) {
      ideas += r.viralHooks.length;
      ideas += r.videoIdeas.length;
      ideas += r.scripts.length;
    }

    // Compute day content counts for mini calendar
    final dayMap = <String, int>{};
    for (final entry in raw) {
      final savedAt = entry['savedAt'] as String?;
      if (savedAt != null) {
        try {
          final dt = DateTime.parse(savedAt);
          final dayKey = DateFormat('yyyy-MM-dd').format(dt);
          dayMap[dayKey] = (dayMap[dayKey] ?? 0) + 1;
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        _postsCreated = history.length;
        _ideasGenerated = ideas;
        _dailyStreak = streak;
        _historyRaw = raw;
        _dayContentCount = dayMap;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.gold),
            tooltip: 'Weekly Planner',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WeeklyPlannerScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stat Cards Row ──
                    _buildStatCards(),
                    const SizedBox(height: 24),

                    // ── Content Calendar Mini-View ──
                    _buildCalendarMiniView(),
                    const SizedBox(height: 24),

                    // ── Favorite Templates ──
                    _buildFavoriteTemplates(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stat Cards
  // ---------------------------------------------------------------------------

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.15,
      children: [
        _StatCard(
          icon: Icons.article_rounded,
          label: 'Posts Created',
          value: _postsCreated.toString(),
          gradientColors: const [AppTheme.primary, AppTheme.violet],
          iconColor: AppTheme.primary,
        ),
        _StatCard(
          icon: Icons.lightbulb_rounded,
          label: 'Ideas Generated',
          value: _ideasGenerated.toString(),
          gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          iconColor: AppTheme.gold,
        ),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Daily Streak',
          value: '$_dailyStreak',
          gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
          iconColor: const Color(0xFFEF4444),
          subtitle: 'days',
        ),
        _buildFollowersCard(),
      ],
    );
  }

  Widget _buildFollowersCard() {
    final progress = _followersGoal > 0
        ? (_followersCurrent / _followersGoal).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: _editFollowersGoal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withValues(alpha: 0.25),
              AppTheme.violet.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: AppTheme.surfaceLight.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.gold.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: AppTheme.gold,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NumberFormat.compact().format(_followersGoal),
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Followers Goal',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editFollowersGoal() {
    final controller = TextEditingController(text: _followersGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Set Followers Goal',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.white),
          decoration: const InputDecoration(
            hintText: 'Enter target followers',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => _followersGoal = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Calendar Mini-View
  // ---------------------------------------------------------------------------

  Widget _buildCalendarMiniView() {
    final now = DateTime.now();
    // Find Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(d);
      return {
        'date': d,
        'day': DateFormat('EEE').format(d),
        'dayNum': d.day,
        'hasContent': _dayContentCount.containsKey(dayKey),
        'isToday': DateFormat('yyyy-MM-dd').format(now) == dayKey,
      };
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'This Week',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WeeklyPlannerScreen(),
                  ),
                ).then((_) => _loadData());
              },
              child: const Row(
                children: [
                  Text(
                    'Full Planner',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primary, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppTheme.surface,
            border: Border.all(
              color: AppTheme.surfaceLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((d) {
              return _DayDot(
                day: d['day'] as String,
                dayNum: d['dayNum'] as int,
                hasContent: d['hasContent'] as bool,
                isToday: d['isToday'] as bool,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Favorite Templates
  // ---------------------------------------------------------------------------

  Widget _buildFavoriteTemplates() {
    // Extract unique platform+niche+tone combos from history
    final combos = <String, Map<String, String>>{};
    for (final r in _historyRaw) {
      final platform = r['platform'] as String? ?? '';
      final niche = r['niche'] as String? ?? '';
      final tone = r['tone'] as String? ?? '';
      if (platform.isEmpty) continue;
      final key = '$platform|$niche|$tone';
      if (!combos.containsKey(key)) {
        combos[key] = {
          'platform': platform,
          'niche': niche,
          'tone': tone,
        };
      }
    }

    final templates = combos.values.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorite Templates',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        if (templates.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppTheme.surface,
              border: Border.all(
                color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.star_outline_rounded, color: AppTheme.textSecondary, size: 40),
                SizedBox(height: 12),
                Text(
                  'No templates yet.\nGenerate content to see your favorites here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          )
        else
          ...templates.map((t) => _TemplateCard(
                platform: t['platform']!,
                niche: t['niche']!,
                tone: t['tone']!,
              )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;
  final Color iconColor;
  final String? subtitle;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
    required this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withValues(alpha: 0.25),
            gradientColors[1].withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppTheme.surfaceLight.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: iconColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String day;
  final int dayNum;
  final bool hasContent;
  final bool isToday;

  const _DayDot({
    required this.day,
    required this.dayNum,
    required this.hasContent,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: isToday ? AppTheme.gold : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday
                ? AppTheme.gold.withValues(alpha: 0.2)
                : hasContent
                    ? AppTheme.primary.withValues(alpha: 0.25)
                    : AppTheme.surfaceLight.withValues(alpha: 0.3),
            border: isToday
                ? Border.all(color: AppTheme.gold, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$dayNum',
              style: TextStyle(
                color: isToday
                    ? AppTheme.gold
                    : hasContent
                        ? AppTheme.white
                        : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
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
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String platform;
  final String niche;
  final String tone;

  const _TemplateCard({
    required this.platform,
    required this.niche,
    required this.tone,
  });

  String _platformIcon() {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return '📸';
      case 'tiktok':
        return '🎵';
      case 'youtube':
        return '▶️';
      case 'linkedin':
        return '💼';
      case 'twitter':
      case 'x':
        return '🐦';
      case 'facebook':
        return '👥';
      case 'pinterest':
        return '📌';
      default:
        return '📱';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.surface,
        border: Border.all(
          color: AppTheme.surfaceLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.violet],
              ),
            ),
            child: Center(
              child: Text(
                _platformIcon(),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$niche · $tone',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'Use Again',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
