import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/generation_service.dart';

class WeeklyCalendarScreen extends StatefulWidget {
  final String platform;
  final String niche;
  final String goal;
  final String tone;
  final String length;

  const WeeklyCalendarScreen({
    super.key,
    required this.platform,
    required this.niche,
    required this.goal,
    required this.tone,
    required this.length,
  });

  @override
  State<WeeklyCalendarScreen> createState() => _WeeklyCalendarScreenState();
}

class _WeeklyCalendarScreenState extends State<WeeklyCalendarScreen> {
  final GenerationService _service = GenerationService();

  bool _loading = true;
  String _status = 'Preparing your weekly calendar...';
  String? _error;
  List<DailyContent>? _week;
  int _selectedDay = 0;

  static const List<String> _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _fullDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final week = await _service.generateWeek(
        platform: widget.platform,
        niche: widget.niche,
        goal: widget.goal,
        tone: widget.tone,
        length: widget.length,
        onProgress: (status) {
          if (mounted) setState(() => _status = status);
        },
      );

      if (mounted) {
        setState(() {
          _loading = false;
          _week = week;
          _selectedDay = DateTime.now().weekday - 1; // Default to today
          if (_selectedDay < 0 || _selectedDay > 6) _selectedDay = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Weekly Calendar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            tooltip: 'Today',
            onPressed: () {
              final today = DateTime.now().weekday - 1;
              if (today >= 0 && today <= 6) {
                setState(() => _selectedDay = today);
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_week == null || _week!.isEmpty) return _buildEmpty();

    return Column(
      children: [
        // Day tabs
        _buildDayTabs(),
        // Day content
        Expanded(
          child: _buildDayContent(_week![_selectedDay]),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------
  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.gold),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Building your 7-day content calendar',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.error.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppTheme.error, size: 36),
            ),
            const SizedBox(height: 24),
            const Text(
              'Calendar Generation Failed',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _generate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.background,
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty
  // ---------------------------------------------------------------------------
  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No weekly content generated.',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Day Tabs
  // ---------------------------------------------------------------------------
  Widget _buildDayTabs() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final isSelected = _selectedDay == index;
          final isToday = DateTime.now().weekday - 1 == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.violet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isToday
                            ? AppTheme.gold.withValues(alpha: 0.4)
                            : AppTheme.surfaceLight.withValues(alpha: 0.3),
                      ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _days[index],
                    style: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isToday)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Day Content
  // ---------------------------------------------------------------------------
  Widget _buildDayContent(DailyContent day) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.gold.withValues(alpha: 0.1),
                  AppTheme.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.gold, Color(0xFFB8960F)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.background,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.dayOfWeek,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.platform} • ${widget.niche}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hooks section
          if (day.hooks.isNotEmpty) ...[
            _daySectionTitle('🎯 Viral Hooks'),
            const SizedBox(height: 10),
            ...day.hooks.map((hook) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('🔥',
                            style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hook,
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
          ],

          // Script section
          if (day.script != null) ...[
            _daySectionTitle('📝 Script Idea'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.violet.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dayScriptLabel('HOOK', AppTheme.primary),
                  const SizedBox(height: 4),
                  Text(day.script!.hook,
                      style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 14,
                          height: 1.5)),
                  const SizedBox(height: 12),
                  _dayScriptLabel('BODY', AppTheme.violet),
                  const SizedBox(height: 4),
                  Text(day.script!.body,
                      style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 14,
                          height: 1.5)),
                  const SizedBox(height: 12),
                  _dayScriptLabel('CTA', AppTheme.success),
                  const SizedBox(height: 4),
                  Text(day.script!.cta,
                      style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 14,
                          height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Caption section
          if (day.caption.isNotEmpty) ...[
            _daySectionTitle('✍️ Caption'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                ),
              ),
              child: SelectableText(
                day.caption,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Hashtags
          if (day.hashtags.isNotEmpty) ...[
            _daySectionTitle('#️⃣ Hashtags'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: day.hashtags.map((tag) {
                final cleanTag = tag.startsWith('#') ? tag : '#$tag';
                return GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: cleanTag));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.12),
                          AppTheme.violet.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      cleanTag,
                      style: const TextStyle(
                        color: AppTheme.violet,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Copy entire day button
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                final content = _dayToString(day);
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied ${day.dayOfWeek} content'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text('Copy ${day.dayOfWeek} Content'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.white,
                side: BorderSide(
                  color: AppTheme.gold.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _dayToString(DailyContent day) {
    final buffer = StringBuffer();
    buffer.writeln('=== ${day.dayOfWeek} Content ===');
    buffer.writeln('Platform: ${widget.platform} | Niche: ${widget.niche}');
    buffer.writeln();

    if (day.hooks.isNotEmpty) {
      buffer.writeln('🎯 HOOKS:');
      for (final h in day.hooks) {
        buffer.writeln('• $h');
      }
      buffer.writeln();
    }

    if (day.script != null) {
      buffer.writeln('📝 SCRIPT:');
      buffer.writeln('HOOK: ${day.script!.hook}');
      buffer.writeln('BODY: ${day.script!.body}');
      buffer.writeln('CTA: ${day.script!.cta}');
      buffer.writeln();
    }

    if (day.caption.isNotEmpty) {
      buffer.writeln('✍️ CAPTION:');
      buffer.writeln(day.caption);
      buffer.writeln();
    }

    if (day.hashtags.isNotEmpty) {
      buffer.writeln('#️⃣ HASHTAGS:');
      buffer.writeln(day.hashtags.join(' '));
    }

    return buffer.toString();
  }

  Widget _daySectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _dayScriptLabel(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
