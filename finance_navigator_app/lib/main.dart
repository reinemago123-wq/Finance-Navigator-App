import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_page.dart';
import 'features/main_shell.dart';
import 'core/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Init Firebase ────────────────────────────────────────────────────────
  await Firebase.initializeApp();

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
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.primaryDark,
      ),
      // ── Auth gate: show MainShell if logged in, otherwise onboarding ──────
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Still checking
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.primaryDark,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }
          // Already logged in — go straight to app
          if (snapshot.hasData && snapshot.data != null) {
            return const MainShell();
          }
          // Not logged in — show splash → onboarding → login
          return SplashScreen(onComplete: _goToOnboarding);
        },
      ),
    );
  }
}

void _goToOnboarding() {
  navigatorKey.currentState?.pushReplacement(
    _fadeRoute(OnboardingScreen(onFinished: _goToLogin)),
  );
}

void _goToLogin() {
  navigatorKey.currentState?.pushReplacement(
    _fadeRoute(const LoginPage()),
  );
}

PageRouteBuilder<void> _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );
}