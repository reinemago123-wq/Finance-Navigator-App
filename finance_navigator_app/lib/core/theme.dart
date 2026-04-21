import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────

class AppColors {
  // Brand
  static const Color primary        = Color(0xFF0D2347);
  static const Color primaryLight   = Color(0xFF1A4080);
  static const Color primaryDark    = Color(0xFF091525);
  static const Color accent         = Color(0xFFF4B942);
  static const Color accentLight    = Color(0xFFFFD07A);
  static const Color accentDark     = Color(0xFFE8A830);

  // Semantic
  static const Color income         = Color(0xFF2ECC71);
  static const Color expense        = Color(0xFFE74C3C);
  static const Color warning        = Color(0xFFF39C12);

  // Neutrals
  static const Color surface        = Color(0xFFF8F9FD);
  static const Color card           = Color(0xFFFFFFFF);
  static const Color divider        = Color(0xFFE8EBF0);
  static const Color textPrimary    = Color(0xFF0D1B2A);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color textHint       = Color(0xFFADB5BD);
  static const Color onDark         = Color(0xFFFFFFFF);

  // Glassmorphism
  static const Color glassWhite     = Color(0x0FFFFFFF);   // 6% white
  static const Color glassBorder    = Color(0x1FFFFFFF);   // 12% white
  static const Color glassGold      = Color(0x1AF4B942);   // 10% gold
  static const Color glassGoldBorder= Color(0x40F4B942);   // 25% gold
}

// ─── Text Styles ──────────────────────────────────────────────────────────────

class AppText {
  static const TextStyle display = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: AppColors.onDark, letterSpacing: -1.0,
  );
  static const TextStyle h1 = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: AppColors.onDark, letterSpacing: -0.5,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.onDark, letterSpacing: -0.3,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.onDark,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.onDark,
  );
  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: Color(0x80FFFFFF),  // 50% white
    height: 1.6,
  );
  static const TextStyle label = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600,
    color: AppColors.accent, letterSpacing: 1.2,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: Color(0x60FFFFFF),
  );
  static const TextStyle money = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.onDark, letterSpacing: -0.5,
  );
  static const TextStyle moneyLarge = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.onDark, letterSpacing: -1.0,
  );
}

// ─── Spacing & Radius ─────────────────────────────────────────────────────────

class Sp {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

class Rd {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 28;
  static const double full = 100;

  static const BorderRadius card   = BorderRadius.all(Radius.circular(20));
  static const BorderRadius button = BorderRadius.all(Radius.circular(14));
  static const BorderRadius chip   = BorderRadius.all(Radius.circular(20));
  static const BorderRadius input  = BorderRadius.all(Radius.circular(14));
  static const BorderRadius nav    = BorderRadius.all(Radius.circular(28));
}

// ─── Gradients ────────────────────────────────────────────────────────────────

class AppGradients {
  static const LinearGradient primaryBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2347), Color(0xFF091525)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, AppColors.accentDark],
  );

  static const LinearGradient income = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
  );
}

// ─── Shadows ──────────────────────────────────────────────────────────────────

class AppShadows {
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: AppColors.accent.withOpacity(0.30),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withOpacity(0.20),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
}

// ─── ThemeData ─────────────────────────────────────────────────────────────────

class AppTheme {
  // ── Dark ────────────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.accent,
      secondary: AppColors.accent,
      surface:   AppColors.primary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    textTheme: _textTheme(AppColors.onDark),
    inputDecorationTheme: _inputTheme(AppColors.onDark),
    dividerColor: AppColors.glassBorder,
  );

  // ── Light ───────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF0F4FF),
    colorScheme: const ColorScheme.light(
      primary:   AppColors.accent,
      secondary: AppColors.accent,
      surface:   Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    textTheme: _textTheme(AppColors.primary),
    inputDecorationTheme: _inputTheme(AppColors.primary),
    dividerColor: Color(0xFFE0E7F0),
  );

  static TextTheme _textTheme(Color base) => TextTheme(
    displayLarge: TextStyle(color: base),
    bodyLarge:    TextStyle(color: base),
    bodyMedium:   TextStyle(color: base),
  );

  static InputDecorationTheme _inputTheme(Color base) =>
      InputDecorationTheme(
        hintStyle: TextStyle(color: base.withOpacity(0.40)),
        border: InputBorder.none,
      );
}

// ─── Context helpers ───────────────────────────────────────────────────────────
// Use these in widgets instead of hardcoded AppColors.onDark / AppColors.primaryDark

extension AppThemeContext on BuildContext {
  bool   get isDark        => Theme.of(this).brightness == Brightness.dark;

  // Text colour — white in dark, navy in light
  Color  get textColor     => isDark ? AppColors.onDark  : AppColors.primary;

  // Subtle text
  Color  get textMuted     => textColor.withOpacity(0.55);

  // Card / glass fill
  Color  get glassFill     => isDark
      ? const Color(0x0FFFFFFF)   // 6% white
      : const Color(0x99FFFFFF);  // 60% white

  // Card border
  Color  get glassBorderColor => isDark
      ? const Color(0x1FFFFFFF)   // 12% white
      : const Color(0xFFDDE5F0);  // light blue-grey

  // Page background
  Color  get bgColor       => isDark
      ? AppColors.primaryDark
      : const Color(0xFFF0F4FF);

  // Orb / glow tint
  Color  get orbTint       => isDark
      ? AppColors.accent.withOpacity(0.15)
      : AppColors.accent.withOpacity(0.08);
}