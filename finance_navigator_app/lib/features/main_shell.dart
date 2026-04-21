import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../widgets/glass_nav_bar.dart';
import 'dashboard/home_page.dart';
import 'analytics/analytics_page.dart';
import 'transactions/transactions_page.dart';
import 'calendar/calendar_page.dart';
import 'profile/profile_page.dart';

// ─────────────────────────────────────────────
//  MainShell
//
//  Single Scaffold that owns:
//    • The page content via IndexedStack
//    • The nav bar via Scaffold.bottomNavigationBar
//
//  Using bottomNavigationBar is the ONLY Flutter-
//  guaranteed way to show a bar regardless of what
//  child widgets do. Child pages each have their own
//  Scaffold but Flutter renders the outermost one's
//  bottomNavigationBar on top of everything.
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = AppTab.home;

  @override
  Widget build(BuildContext context) {
    // Make the status bar icons light (white) on dark background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── Pages ─────────────────────────────────────────
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

      // ── Nav bar — ALWAYS renders here ────────────────
      // Flutter draws bottomNavigationBar outside the body,
      // so it is immune to anything child Scaffolds do.
      bottomNavigationBar: GlassNavBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}