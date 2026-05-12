import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../widgets/glass_nav_bar.dart';
import 'dashboard/home_page.dart';
import 'analytics/analytics_page.dart';
import 'transactions/transactions_page.dart';
import 'calendar/calendar_page.dart';
import 'profile/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static _MainShellState? _instance;

  // Persists the active tab across full rebuilds (e.g. theme toggle)
  static int _persistedTab = AppTab.home;

  static void switchTab(int tab) {
    _persistedTab = tab;
    _instance?.switchTo(tab);
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Restore from persisted tab so theme toggle doesn't reset to home
  late int _tab = MainShell._persistedTab;

  @override
  void initState() {
    super.initState();
    MainShell._instance = this;
  }

  @override
  void dispose() {
    if (MainShell._instance == this) MainShell._instance = null;
    super.dispose();
  }

  void switchTo(int tab) {
    MainShell._persistedTab = tab;
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    // Keep status bar icons visible in both modes
    SystemChrome.setSystemUIOverlayStyle(
      context.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _tab,
        children: const [
          HomePage(),
          AnalyticsPage(),
          TransactionsPage(),
          CalendarPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _tab,
        onTap: (i) {
          MainShell._persistedTab = i;
          setState(() => _tab = i);
        },
      ),
    );
  }
}