import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/generation_result.dart';
import '../../models/script.dart';
import '../../services/generation_service.dart';
import '../../services/subscription_service.dart';
import 'weekly_calendar_screen.dart';

class CreateResultScreen extends StatefulWidget {
  final String platform;
  final String niche;
  final String goal;
  final String tone;
  final String length;

  const CreateResultScreen({
    super.key,
    required this.platform,
    required this.niche,
    required this.goal,
    required this.tone,
    required this.length,
  });

  @override
  State<CreateResultScreen> createState() => _CreateResultScreenState();
}

class _CreateResultScreenState extends State<CreateResultScreen> {
  final GenerationService _service = GenerationService();

  bool _loading = true;
  String _status = 'Preparing your brief...';
  String? _error;
  GenerationResult? _result;
  int _expandedSection = -1; // -1 = all collapsed, track single expansion

  static const List<String> _statusMessages = [
    'Preparing your brief...',
    'Crafting viral hooks...',
    'Brainstorming video ideas...',
    'Writing your scripts...',
    'Optimizing captions...',
    'Designing visuals...',
    'Building SEO strategy...',
    'Adapting for cross-platform...',
    'Polishing your content...',
    'Almost done...',
  ];

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    int msgIndex = 0;
    final timer = Timer.periodic(const Duration(milliseconds: 1800), (t) {
      if (mounted) {
        setState(() {
          msgIndex = (msgIndex + 1) % _statusMessages.length;
          _status = _statusMessages[msgIndex];
        });
      }
    });

    try {
      final result = await _service.generateAll(
        platform: widget.platform,
        niche: widget.niche,
        goal: widget.goal,
        tone: widget.tone,
        length: widget.length,
        onProgress: (status) {
          if (mounted) {
            setState(() => _status = status);
          }
        },
      );

      timer.cancel();
      if (mounted) {
        // Record the generation for usage tracking
        SubscriptionService().recordGeneration();

        setState(() {
          _loading = false;
          _result = result;
          _status = 'Content ready!';
        });
      }
    } catch (e) {
      timer.cancel();
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _openWeeklyCalendar() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WeeklyCalendarScreen(
          platform: widget.platform,
          niche: widget.niche,
          goal: widget.goal,
          tone: widget.tone,
          length: widget.length,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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
        title: Text(
          _loading ? 'Generating...' : 'Your Content',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_loading && _result != null)
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: 'Generate My Entire Week',
              onPressed: _openWeeklyCalendar,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return _buildLoadingScreen();
    }
    if (_error != null) {
      return _buildErrorScreen();
    }
    if (_result == null || _result!.isEmpty) {
      return _buildEmptyScreen();
    }
    return _buildDashboard();
  }

  // ---------------------------------------------------------------------------
  // Loading Screen
  // ---------------------------------------------------------------------------
  Widget _buildLoadingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated gradient ring
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 36),
            // Status message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _status,
                key: ValueKey(_status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Powered by GPT-4o',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error Screen
  // ---------------------------------------------------------------------------
  Widget _buildErrorScreen() {
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
              'Generation Failed',
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
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty Screen
  // ---------------------------------------------------------------------------
  Widget _buildEmptyScreen() {
    return const Center(
      child: Text(
        'No content generated.',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------
  Widget _buildDashboard() {
    final r = _result!;

    return Column(
      children: [
        // Generate My Entire Week button
        _buildWeekButton(),
        // Scrollable sections
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (r.viralHooks.isNotEmpty)
                _buildSection(
                  index: 0,
                  title: '🎯 Viral Hooks',
                  subtitle: '${r.viralHooks.length} scroll-stopping hooks',
                  child: _buildHooksList(r.viralHooks),
                ),
              if (r.videoIdeas.isNotEmpty)
                _buildSection(
                  index: 1,
                  title: '💡 Video Ideas',
                  subtitle: '${r.videoIdeas.length} original concepts',
                  child: _buildNumberedList(r.videoIdeas),
                ),
              if (r.scripts.isNotEmpty)
                _buildSection(
                  index: 2,
                  title: '📝 Scripts',
                  subtitle: '${r.scripts.length} complete scripts',
                  child: _buildScriptsList(r.scripts),
                ),
              if (r.caption.isNotEmpty)
                _buildSection(
                  index: 3,
                  title: '✍️ Caption',
                  subtitle: 'Optimized for ${r.platform}',
                  child: _buildCaptionBlock(r),
                ),
              if (r.hashtags.isNotEmpty)
                _buildSection(
                  index: 4,
                  title: '#️⃣ Hashtags',
                  subtitle: '${r.hashtags.length} high-performing tags',
                  child: _buildHashtagChips(r.hashtags),
                ),
              if (r.thumbnailText.isNotEmpty)
                _buildSection(
                  index: 5,
                  title: '🖼️ Visual Direction',
                  subtitle: 'Thumbnail, b-roll, lighting & more',
                  child: _buildVisualBlock(r),
                ),
              if (r.bestPostingTime.isNotEmpty)
                _buildSection(
                  index: 6,
                  title: '📊 Strategy',
                  subtitle: 'Timing, SEO & repurposing',
                  child: _buildStrategyBlock(r),
                ),
              if (r.carouselVersion.isNotEmpty)
                _buildSection(
                  index: 7,
                  title: '🔄 Cross-Platform Versions',
                  subtitle: 'Adapted for every platform',
                  child: _buildCrossPlatformBlock(r),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _openWeeklyCalendar,
          icon: const Icon(Icons.auto_awesome_rounded, size: 22),
          label: const Text(
            'Generate My Entire Week',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.gold,
            foregroundColor: AppTheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Builder
  // ---------------------------------------------------------------------------
  Widget _buildSection({
    required int index,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isExpanded = _expandedSection == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.surfaceLight.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                setState(() {
                  _expandedSection = isExpanded ? -1 : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Copy button
                    _CopyButton(content: _sectionToString(index)),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content (conditionally shown)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: child,
              ),
              crossFadeState:
                  isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts a section's content to a string for the copy button.
  String _sectionToString(int index) {
    final r = _result!;
    switch (index) {
      case 0:
        return r.viralHooks.map((h) => '• $h').join('\n');
      case 1:
        return r.videoIdeas.asMap().map((i, v) => MapEntry(i, '${i + 1}. $v')).values.join('\n');
      case 2:
        return r.scripts
            .asMap()
            .map((i, s) => MapEntry(
                i,
                'SCRIPT ${i + 1}\n'
                'HOOK: ${s.hook}\n'
                'BODY: ${s.body}\n'
                'CTA: ${s.cta}'))
            .values
            .join('\n\n');
      case 3:
        return '${r.caption}\n\n${r.hashtags.join(' ')}';
      case 4:
        return r.hashtags.join(' ');
      case 5:
        return 'THUMBNAIL: ${r.thumbnailText}\n\n'
            'EDITING: ${r.editingSuggestions}\n\n'
            'B-ROLL: ${r.bRollIdeas.map((b) => '• $b').join('\n')}\n\n'
            'CAMERA: ${r.cameraAngles}\n\n'
            'LIGHTING: ${r.lightingSuggestions}\n\n'
            'MUSIC: ${r.musicStyle}';
      case 6:
        return 'BEST TIME: ${r.bestPostingTime}\n\n'
            'KEYWORDS: ${r.seoKeywords.join(', ')}\n\n'
            'REPURPOSE:\n${r.repurposeIdeas.map((ri) => '• $ri').join('\n')}';
      case 7:
        return 'CAROUSEL:\n${r.carouselVersion}\n\n'
            'INSTAGRAM STORY:\n${r.instagramStoryVersion}\n\n'
            'FACEBOOK:\n${r.facebookVersion}\n\n'
            'LINKEDIN:\n${r.linkedinVersion}\n\n'
            'PINTEREST:\n${r.pinterestVersion}';
      default:
        return '';
    }
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets for each section type
  // ---------------------------------------------------------------------------

  Widget _buildHooksList(List<String> hooks) {
    return Column(
      children: hooks
          .asMap()
          .map((i, hook) => MapEntry(
                i,
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.violet],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hook,
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .values
          .toList(),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      children: items
          .asMap()
          .map((i, item) => MapEntry(
                i,
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}.',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .values
          .toList(),
    );
  }

  Widget _buildScriptsList(List<Script> scripts) {
    return Column(
      children: scripts.asMap().map((i, script) {
        return MapEntry(
          i,
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCRIPT ${i + 1}',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _scriptLabel('HOOK', AppTheme.primary),
                const SizedBox(height: 4),
                Text(script.hook,
                    style: const TextStyle(
                        color: AppTheme.white, fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                _scriptLabel('BODY', AppTheme.violet),
                const SizedBox(height: 4),
                Text(script.body,
                    style: const TextStyle(
                        color: AppTheme.white, fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                _scriptLabel('CTA', AppTheme.success),
                const SizedBox(height: 4),
                Text(script.cta,
                    style: const TextStyle(
                        color: AppTheme.white, fontSize: 14, height: 1.5)),
              ],
            ),
          ),
        );
      }).values.toList(),
    );
  }

  Widget _scriptLabel(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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

  Widget _buildCaptionBlock(GenerationResult r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SelectableText(
            r.caption,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHashtagChips(List<String> hashtags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hashtags.map((tag) {
        final cleanTag = tag.startsWith('#') ? tag : '#$tag';
        return GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: cleanTag));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied $cleanTag'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.15),
                  AppTheme.violet.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              cleanTag,
              style: const TextStyle(
                color: AppTheme.violet,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisualBlock(GenerationResult r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _visualItem('🖼️ Thumbnail Text', r.thumbnailText),
        _visualItem('✂️ Editing Suggestions', r.editingSuggestions),
        if (r.bRollIdeas.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('🎬 B-Roll Ideas',
              style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...r.bRollIdeas.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: AppTheme.gold, fontSize: 14)),
                    Expanded(
                        child: Text(b,
                            style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 13,
                                height: 1.5))),
                  ],
                ),
              )),
        ],
        _visualItem('📐 Camera Angles', r.cameraAngles),
        _visualItem('💡 Lighting', r.lightingSuggestions),
        _visualItem('🎵 Music Style', r.musicStyle),
      ],
    );
  }

  Widget _visualItem(String label, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildStrategyBlock(GenerationResult r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _strategyItem('⏰ Best Posting Time', r.bestPostingTime),
        if (r.seoKeywords.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('🔑 SEO Keywords',
              style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: r.seoKeywords.map((k) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(k,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              );
            }).toList(),
          ),
        ],
        if (r.repurposeIdeas.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('♻️ Repurpose Ideas',
              style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...r.repurposeIdeas.map((ri) => Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: AppTheme.gold, fontSize: 14)),
                    Expanded(
                        child: Text(ri,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.5))),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _strategyItem(String label, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCrossPlatformBlock(GenerationResult r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _crossPlatformItem('🎠 Carousel Version', r.carouselVersion),
        _crossPlatformItem('📱 Instagram Story', r.instagramStoryVersion),
        _crossPlatformItem('👍 Facebook Version', r.facebookVersion),
        _crossPlatformItem('💼 LinkedIn Version', r.linkedinVersion),
        _crossPlatformItem('📌 Pinterest Version', r.pinterestVersion),
      ],
    );
  }

  Widget _crossPlatformItem(String label, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(content,
              style: const TextStyle(
                  color: AppTheme.white, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Copy Button Widget
// ---------------------------------------------------------------------------
class _CopyButton extends StatelessWidget {
  final String content;

  const _CopyButton({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: content));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy_rounded,
                color: AppTheme.primary, size: 16),
            SizedBox(width: 6),
            Text(
              'Copy',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
