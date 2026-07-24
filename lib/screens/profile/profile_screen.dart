import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/memory_service.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MemoryService _memory = MemoryService();
  final AuthService _auth = AuthService();

  UserProfile _profile = UserProfile();
  bool _loading = true;

  late TextEditingController _businessNameController;
  late TextEditingController _targetAudienceController;
  late TextEditingController _writingStyleController;
  late TextEditingController _brandColor1Controller;
  late TextEditingController _brandColor2Controller;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _targetAudienceController = TextEditingController();
    _writingStyleController = TextEditingController();
    _brandColor1Controller = TextEditingController();
    _brandColor2Controller = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _targetAudienceController.dispose();
    _writingStyleController.dispose();
    _brandColor1Controller.dispose();
    _brandColor2Controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _memory.loadProfile();
    setState(() {
      _profile = profile;
      _loading = false;
      _businessNameController.text = profile.businessName;
      _targetAudienceController.text = profile.targetAudience;
      _writingStyleController.text = profile.writingStyle;
      _brandColor1Controller.text =
          profile.brandColors.isNotEmpty ? profile.brandColors[0] : '#7C3AED';
      _brandColor2Controller.text =
          profile.brandColors.length > 1 ? profile.brandColors[1] : '#8B5CF6';
    });
  }

  Future<void> _saveProfile() async {
    final brandColors = [
      _brandColor1Controller.text.trim(),
      _brandColor2Controller.text.trim(),
    ];
    await _memory.updateProfile(
      businessName: _businessNameController.text.trim(),
      targetAudience: _targetAudienceController.text.trim(),
      writingStyle: _writingStyleController.text.trim(),
      brandColors: brandColors,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _resetMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Reset Memory?',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'This will clear all learned preferences, usage history, and brand settings.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _memory.resetMemory();
      _loadProfile();
    }
  }

  Color? _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar & Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppTheme.primary, AppTheme.violet],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (user?.displayName ?? 'C')[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName ?? 'Creator',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'user@vyraliq.com',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Brand Settings Section ──
                  _SectionHeader(title: 'Brand Settings'),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _SettingsField(
                      label: 'Business Name',
                      icon: Icons.business_rounded,
                      controller: _businessNameController,
                      hint: 'Your brand or business name',
                    ),
                    const SizedBox(height: 14),
                    _SettingsField(
                      label: 'Target Audience',
                      icon: Icons.people_rounded,
                      controller: _targetAudienceController,
                      hint: 'e.g. Millennial entrepreneurs',
                    ),
                    const SizedBox(height: 14),
                    _SettingsField(
                      label: 'Writing Style',
                      icon: Icons.edit_note_rounded,
                      controller: _writingStyleController,
                      hint: 'e.g. Casual, professional, witty',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SettingsField(
                            label: 'Brand Color 1',
                            icon: Icons.palette_rounded,
                            controller: _brandColor1Controller,
                            hint: '#7C3AED',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SettingsField(
                            label: 'Brand Color 2',
                            icon: Icons.palette_rounded,
                            controller: _brandColor2Controller,
                            hint: '#8B5CF6',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Color preview
                    Row(
                      children: [
                        const Text('Preview: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _parseColor(_brandColor1Controller.text) ?? AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _parseColor(_brandColor2Controller.text) ?? AppTheme.violet,
                          ),
                        ),
                      ],
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── AI Memory Section ──
                  _SectionHeader(title: 'AI Memory'),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _SwitchTile(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Learn from me',
                      subtitle: 'Auto-detect preferences from your usage',
                      value: _profile.learnFromMe,
                      onChanged: (v) async {
                        await _memory.updateProfile(learnFromMe: v);
                        setState(() => _profile.learnFromMe = v);
                      },
                    ),
                    if (_profile.learnFromMe) ...[
                      const Divider(color: AppTheme.surfaceLight, height: 24),
                      // Show learned preferences
                      if (_profile.mostUsedPlatform.isNotEmpty) ...[
                        _MemoryStat(
                          label: 'Favorite Platform',
                          value: _profile.mostUsedPlatform,
                          icon: Icons.phone_iphone_rounded,
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (_profile.mostUsedNiche.isNotEmpty) ...[
                        _MemoryStat(
                          label: 'Preferred Niche',
                          value: _profile.mostUsedNiche,
                          icon: Icons.category_rounded,
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (_profile.mostUsedTone.isNotEmpty) ...[
                        _MemoryStat(
                          label: 'Preferred Tone',
                          value: _profile.mostUsedTone,
                          icon: Icons.mic_rounded,
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (_profile.platformUsage.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Usage History',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ..._buildUsageStats(),
                      ],
                    ],
                    const Divider(color: AppTheme.surfaceLight, height: 24),
                    Center(
                      child: TextButton.icon(
                        onPressed: _resetMemory,
                        icon: const Icon(Icons.restart_alt_rounded, color: AppTheme.error, size: 18),
                        label: const Text(
                          'Reset Memory',
                          style: TextStyle(color: AppTheme.error, fontSize: 14),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Notifications Section ──
                  _SectionHeader(title: 'Preferences'),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _SwitchTile(
                      icon: Icons.dark_mode_rounded,
                      label: 'Dark Mode',
                      subtitle: 'Luxury dark theme (default)',
                      value: _profile.darkMode,
                      onChanged: (v) async {
                        await _memory.updateProfile(darkMode: v);
                        setState(() => _profile.darkMode = v);
                      },
                    ),
                    const Divider(color: AppTheme.surfaceLight, height: 1),
                    _SwitchTile(
                      icon: Icons.notifications_rounded,
                      label: 'Push Notifications',
                      subtitle: 'Get notified about content ideas',
                      value: false,
                      onChanged: (_) {},
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Sign Out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _auth.signOut();
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(color: AppTheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'VyralIQ v1.0.0',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildUsageStats() {
    final entries = _profile.platformUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final nicheEntries = _profile.nicheUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final widgets = <Widget>[];
    if (entries.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entries.take(5).map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.primary.withValues(alpha: 0.15),
                ),
                child: Text(
                  '${e.key} (${e.value})',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    if (nicheEntries.isNotEmpty) {
      widgets.add(
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: nicheEntries.take(5).map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.gold.withValues(alpha: 0.1),
              ),
              child: Text(
                '${e.key} (${e.value})',
                style: const TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
      );
    }
    return widgets;
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.surface,
        border: Border.all(
          color: AppTheme.surfaceLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _SettingsField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.gold, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _MemoryStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MemoryStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.violet, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppTheme.violet.withValues(alpha: 0.15),
          ),
          child: Text(
            value,
            style: const TextStyle(color: AppTheme.violet, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
