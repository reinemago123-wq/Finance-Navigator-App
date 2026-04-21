import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_page.dart';
import 'core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Root navigator key — gives us a stable handle to the navigator that never
//  becomes stale, even after animations rebuild the widget tree.
// ─────────────────────────────────────────────────────────────────────────────
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FinanceNavigatorApp());
}

class FinanceNavigatorApp extends StatelessWidget {
  const FinanceNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Navigator',
      debugShowCheckedModeBanner: false,
      // ── Attach the stable navigator key ──────────────────────────────────
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.primaryDark,
      ),
      home: SplashScreen(
        // onComplete fires after the splash animation — by then the original
        // BuildContext from build() is deactivated. We use navigatorKey instead.
        onComplete: _goToOnboarding,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Navigation helpers — all use navigatorKey.currentState so they are
//  completely decoupled from any BuildContext lifecycle.
// ─────────────────────────────────────────────────────────────────────────────

void _goToOnboarding() {
  navigatorKey.currentState?.pushReplacement(
    _fadeRoute(
      OnboardingScreen(onFinished: _goToLogin),
    ),
  );
}

void _goToLogin() {
  navigatorKey.currentState?.pushReplacement(
    _fadeRoute(const LoginPage()),
  );
}

/// Reusable smooth fade page transition
PageRouteBuilder<void> _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );
}