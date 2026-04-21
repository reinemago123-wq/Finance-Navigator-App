import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_page.dart';
import 'features/main_shell.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FinanceNavigatorApp(),
    ),
  );
}

class FinanceNavigatorApp extends StatelessWidget {
  const FinanceNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Finance Navigator',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      themeMode: themeProvider.themeMode,
      theme:     AppTheme.light,
      darkTheme:  AppTheme.dark,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator(
                  color: AppColors.accent)),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const MainShell();
          }
          return SplashScreen(onComplete: _goToOnboarding);
        },
      ),
    );
  }
}

void _goToOnboarding() {
  navigatorKey.currentState?.pushReplacement(
      _fade(OnboardingScreen(onFinished: _goToLogin)));
}

void _goToLogin() {
  navigatorKey.currentState?.pushReplacement(_fade(const LoginPage()));
}

PageRouteBuilder<void> _fade(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) =>
      FadeTransition(opacity: anim, child: child),
  transitionDuration: const Duration(milliseconds: 400),
);