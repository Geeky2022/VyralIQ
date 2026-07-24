import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/create/create_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/bottom_nav.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase will be initialized here when firebase_options.dart is configured.
  // For now, we run without Firebase - the AuthService handles this gracefully.
  runApp(const VyralIQApp());
}

class VyralIQApp extends StatelessWidget {
  const VyralIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VyralIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
    );
  }
}

/// AuthGate listens to auth state and routes accordingly.
/// When Firebase is configured, this will use real auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // For now, we default to showing the auth flow.
    // When Firebase is wired up, uncomment the stream builder below
    // and remove the direct return of AuthNavigator.

    // TODO: Uncomment when firebase_options.dart is configured:
    //
    // return StreamBuilder<User?>(
    //   stream: authService.authStateChanges,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Scaffold(
    //         body: Center(
    //           child: CircularProgressIndicator(color: AppTheme.primary),
    //         ),
    //       );
    //     }
    //     if (snapshot.hasData) {
    //       return const MainShell();
    //     }
    //     return const AuthNavigator();
    //   },
    // );

    // Placeholder: always show auth for now.
    // Swap to MainShell() to see the main app without auth.
    return const AuthNavigator();
  }
}

/// Auth flow navigator - wraps Login, Sign Up, Forgot Password screens.
class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onNavigateToSignUp: () {
        Navigator.of(context).push(
          _createRoute(SignUpScreen(
            onNavigateToSignIn: () => Navigator.of(context).pop(),
          )),
        );
      },
      onNavigateToForgotPassword: () {
        Navigator.of(context).push(
          _createRoute(ForgotPasswordScreen(
            onNavigateToSignIn: () => Navigator.of(context).pop(),
          )),
        );
      },
    );
  }

  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Main app shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CreateScreen(),
    HistoryScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
