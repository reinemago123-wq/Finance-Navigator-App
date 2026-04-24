import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../widgets/glass_nav_bar.dart';
import 'dashboard/home_page.dart';
import 'analytics/analytics_page.dart';
import 'transactions/transactions_page.dart';
import 'calendar/calendar_page.dart';
import 'profile/profile_page.dart';

// ── Global tab switcher — any page can call this ──────────────────────────────
// e.g. MainShell.switchTab(AppTab.calendar)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  // Static reference so child pages can switch tabs without context
  static _MainShellState? _instance;
  static void switchTab(int tab) => _instance?.switchTo(tab);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = AppTab.home;

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

  void switchTo(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}