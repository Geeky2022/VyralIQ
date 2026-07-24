import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../models/generation_result.dart';
import '../../models/script.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allEntries = [];
  List<Map<String, dynamic>> _filteredEntries = [];
  String _activeTab = 'All';
  String _searchQuery = '';
  bool _loading = true;

  static const _tabs = ['All', 'Hooks', 'Captions', 'Scripts', 'Templates'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabs[_tabController.index]);
        _applyFilters();
      }
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
      _applyFilters();
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final raw = await _storage.getHistoryRaw();
    if (mounted) {
      setState(() {
        _allEntries = raw;
        _loading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    var entries = _allEntries.toList();

    // Apply tab filter
    if (_activeTab == 'Hooks') {
      entries = entries.where((e) {
        final hooks = (e['viralHooks'] as List<dynamic>?) ?? [];
        return hooks.isNotEmpty;
      }).toList();
    } else if (_activeTab == 'Captions') {
      entries = entries.where((e) {
        final caption = e['caption'] as String? ?? '';
        return caption.isNotEmpty;
      }).toList();
    } else if (_activeTab == 'Scripts') {
      entries = entries.where((e) {
        final scripts = (e['scripts'] as List<dynamic>?) ?? [];
        return scripts.isNotEmpty;
      }).toList();
    } else if (_activeTab == 'Templates') {
      // Templates = entries with platform/niche/tone combos
      entries = entries.where((e) {
        final platform = e['platform'] as String? ?? '';
        return platform.isNotEmpty;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      entries = entries.where((e) {
        final caption = (e['caption'] as String? ?? '').toLowerCase();
        final platform = (e['platform'] as String? ?? '').toLowerCase();
        final niche = (e['niche'] as String? ?? '').toLowerCase();
        final tone = (e['tone'] as String? ?? '').toLowerCase();
        final hooks = (e['viralHooks'] as List<dynamic>?)
                ?.map((h) => h.toString().toLowerCase())
                .join(' ') ??
            '';
        final scripts = (e['scripts'] as List<dynamic>?)
                ?.map((s) {
                  final m = s as Map<String, dynamic>;
                  return '${m['hook']} ${m['body']} ${m['cta']}';
                })
                .join(' ')
                .toLowerCase() ??
            '';
        final allText = '$caption $platform $niche $tone $hooks $scripts';
        return allText.contains(_searchQuery);
      }).toList();
    }

    setState(() => _filteredEntries = entries);
  }

  Future<void> _deleteEntry(String id) async {
    await _storage.deleteResult(id);
    _loadData();
  }

  void _copyContent(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Saved Library'),
        actions: [
          if (_filteredEntries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error),
              tooltip: 'Clear All',
              onPressed: () => _confirmClearAll(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search saved content...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary, size: 20),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Tabs
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppTheme.white,
              unselectedLabelColor: AppTheme.textSecondary,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.primary.withValues(alpha: 0.25),
              ),
              dividerColor: Colors.transparent,
              tabs: _tabs
                  .map((t) => Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _filteredEntries.isEmpty
                    ? _buildEmptyState()
                    : _buildContentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final String message;
    if (_allEntries.isEmpty) {
      message = 'No saved content yet.\nGenerate your first viral post!';
    } else if (_searchQuery.isNotEmpty) {
      message = 'No results for "$_searchQuery".';
    } else {
      message = 'No $_activeTab content saved yet.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.2),
                    AppTheme.violet.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppTheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        return _ContentListItem(
          entry: entry,
          activeTab: _activeTab,
          onDelete: () => _deleteEntry(entry['id'] as String? ?? ''),
          onCopy: _copyContent,
        );
      },
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Clear All History?',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'This will permanently delete all saved content.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await _storage.clearHistory();
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content List Item
// ---------------------------------------------------------------------------

class _ContentListItem extends StatefulWidget {
  final Map<String, dynamic> entry;
  final String activeTab;
  final VoidCallback onDelete;
  final void Function(String) onCopy;

  const _ContentListItem({
    required this.entry,
    required this.activeTab,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  State<_ContentListItem> createState() => _ContentListItemState();
}

class _ContentListItemState extends State<_ContentListItem> {
  bool _expanded = false;

  String _getPlatformIcon() {
    final p = (widget.entry['platform'] as String? ?? '').toLowerCase();
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

  String _getDateLabel() {
    final savedAt = widget.entry['savedAt'] as String?;
    if (savedAt == null) return '';
    try {
      final dt = DateTime.parse(savedAt);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _getPreview() {
    final caption = widget.entry['caption'] as String? ?? '';
    if (caption.isNotEmpty) {
      return caption.length > 80 ? '${caption.substring(0, 80)}...' : caption;
    }
    final hooks = (widget.entry['viralHooks'] as List<dynamic>?) ?? [];
    if (hooks.isNotEmpty) return hooks.first.toString();
    final scripts = (widget.entry['scripts'] as List<dynamic>?) ?? [];
    if (scripts.isNotEmpty) {
      final s = scripts.first as Map<String, dynamic>;
      return s['hook']?.toString() ?? '';
    }
    return 'Generated content';
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.entry['platform'] as String? ?? '';
    final niche = widget.entry['niche'] as String? ?? '';
    final tone = widget.entry['tone'] as String? ?? '';

    return Dismissible(
      key: Key(widget.entry['id']?.toString() ?? DateTime.now().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.error.withValues(alpha: 0.2),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: AppTheme.error),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.surface,
            border: Border.all(
              color: AppTheme.surfaceLight.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: _expanded
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Text(_getPlatformIcon(), style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  if (platform.isNotEmpty)
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
                  const Spacer(),
                  Text(
                    _getDateLabel(),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _expanded ? 0.5 : 0,
                    child: const Icon(Icons.expand_more_rounded, color: AppTheme.textSecondary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Preview text
              Text(
                _getPreview(),
                style: const TextStyle(color: AppTheme.white, fontSize: 14, height: 1.5),
                maxLines: _expanded ? 20 : 2,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),

              // Niche / Tone tag
              if (niche.isNotEmpty || tone.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (niche.isNotEmpty)
                      _TagChip(label: niche),
                    if (tone.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _TagChip(label: tone, color: AppTheme.gold),
                    ],
                  ],
                ),
              ],

              // Expanded content
              if (_expanded) ...[
                const SizedBox(height: 14),
                const Divider(color: AppTheme.surfaceLight, height: 1),
                const SizedBox(height: 12),
                _buildExpandedContent(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onTap: () => widget.onCopy(_getFullContent()),
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      color: AppTheme.error,
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    final hooks = (widget.entry['viralHooks'] as List<dynamic>?) ?? [];
    final scripts = (widget.entry['scripts'] as List<dynamic>?) ?? [];
    final caption = widget.entry['caption'] as String? ?? '';
    final cta = widget.entry['cta'] as String? ?? '';
    final hashtags = (widget.entry['hashtags'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hooks.isNotEmpty) ...[
          const Text('🔥 Viral Hooks', style: TextStyle(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...hooks.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${h.toString()}', style: const TextStyle(color: AppTheme.white, fontSize: 13, height: 1.4)),
              )),
          const SizedBox(height: 14),
        ],
        if (scripts.isNotEmpty) ...[
          const Text('📝 Scripts', style: TextStyle(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...scripts.asMap().entries.map((e) {
            final s = e.value as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Script ${e.key + 1}', style: const TextStyle(color: AppTheme.violet, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if ((s['hook'] as String?)?.isNotEmpty == true)
                    _ScriptSection(label: 'HOOK', text: s['hook'] as String),
                  if ((s['body'] as String?)?.isNotEmpty == true)
                    _ScriptSection(label: 'BODY', text: s['body'] as String),
                  if ((s['cta'] as String?)?.isNotEmpty == true)
                    _ScriptSection(label: 'CTA', text: s['cta'] as String),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
        ],
        if (caption.isNotEmpty) ...[
          const Text('✍️ Caption', style: TextStyle(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(caption, style: const TextStyle(color: AppTheme.white, fontSize: 13, height: 1.5)),
          const SizedBox(height: 14),
        ],
        if (cta.isNotEmpty) ...[
          const Text('📢 Call to Action', style: TextStyle(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(cta, style: const TextStyle(color: AppTheme.white, fontSize: 13, height: 1.5)),
          const SizedBox(height: 14),
        ],
        if (hashtags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: hashtags.map((h) {
              final tag = h.toString().startsWith('#') ? h.toString() : '#${h.toString()}';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.primary.withValues(alpha: 0.1),
                ),
                child: Text(tag, style: const TextStyle(color: AppTheme.violet, fontSize: 12)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  String _getFullContent() {
    final parts = <String>[];
    final hooks = (widget.entry['viralHooks'] as List<dynamic>?) ?? [];
    final caption = widget.entry['caption'] as String? ?? '';
    final cta = widget.entry['cta'] as String? ?? '';
    final hashtags = (widget.entry['hashtags'] as List<dynamic>?) ?? [];

    if (hooks.isNotEmpty) parts.add('HOOKS:\n${hooks.join('\n')}');
    if (caption.isNotEmpty) parts.add('CAPTION:\n$caption');
    if (cta.isNotEmpty) parts.add('CTA:\n$cta');
    if (hashtags.isNotEmpty) parts.add('HASHTAGS:\n${hashtags.join(' ')}');

    return parts.join('\n\n');
  }
}

class _ScriptSection extends StatelessWidget {
  final String label;
  final String text;

  const _ScriptSection({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppTheme.violet, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: text,
              style: const TextStyle(color: AppTheme.white, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _TagChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: c.withValues(alpha: 0.1),
      ),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
