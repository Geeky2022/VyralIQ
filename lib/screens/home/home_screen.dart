import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName(context);
    final greeting = _getGreeting();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      '$greeting, $displayName 👋',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome back to VyralIQ. Today we\'re creating content that grows your audience.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Section header
                    Row(
                      children: [
                        const Text(
                          'AI Tools',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.violet],
                            ),
                          ),
                          child: const Text(
                            '6 tools',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Everything you need to go from idea to viral content.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Feature cards grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  FeatureCard(
                    emoji: '🎥',
                    title: 'Viral Video\nIdeas',
                    onTap: () => _navigateToPlaceholder(context, 'Viral Video Ideas'),
                  ),
                  FeatureCard(
                    emoji: '✍️',
                    title: 'Script\nWriter',
                    onTap: () => _navigateToPlaceholder(context, 'Script Writer'),
                  ),
                  FeatureCard(
                    emoji: '🎯',
                    title: 'Hook\nGenerator',
                    onTap: () => _navigateToPlaceholder(context, 'Hook Generator'),
                  ),
                  FeatureCard(
                    emoji: '📸',
                    title: 'Caption\nGenerator',
                    onTap: () => _navigateToPlaceholder(context, 'Caption Generator'),
                  ),
                  FeatureCard(
                    emoji: '🎬',
                    title: 'AI Video\nPrompt Builder',
                    onTap: () => _navigateToPlaceholder(context, 'AI Video Prompt Builder'),
                  ),
                  FeatureCard(
                    emoji: '🖼️',
                    title: 'AI Image\nPrompt Builder',
                    onTap: () => _navigateToPlaceholder(context, 'AI Image Prompt Builder'),
                  ),
                ]),
              ),
            ),

            // Bottom padding
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 32),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(BuildContext context) {
    // In a real app, get this from auth state or user provider.
    // For now, return a friendly default.
    try {
      // Attempt to get from inherited auth state
      final name = 'Creator';
      return name;
    } catch (_) {
      return 'Creator';
    }
  }

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PlaceholderScreen(title: title),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
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
                Icons.construction_rounded,
                color: AppTheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Coming Soon',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The $title feature is under development.\nStay tuned for something amazing!',
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
}
