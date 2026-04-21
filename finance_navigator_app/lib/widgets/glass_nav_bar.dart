import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppTab {
  static const int home         = 0;
  static const int analytics    = 1;
  static const int transactions = 2;
  static const int calendar     = 3;
  static const int profile      = 4;
}

// ─────────────────────────────────────────────
//  GlassNavBar
//
//  Used as Scaffold.bottomNavigationBar in MainShell.
//  NO BackdropFilter — that requires a Stack ancestor
//  with a defined size, which bottomNavigationBar is not.
//
//  Looks identical: dark-primary pill, gold accent,
//  rounded corners, subtle border + shadow.
// ─────────────────────────────────────────────
class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    (Icons.home_outlined,           Icons.home_rounded,          'Home'),
    (Icons.analytics_outlined,      Icons.analytics_rounded,     'Analytics'),
    (Icons.receipt_long_outlined,   Icons.receipt_long_rounded,  'Transactions'),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded,'Calendar'),
    (Icons.person_outline_rounded,  Icons.person_rounded,        'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      // Pill shape with margin on all sides
      margin: EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, bottom > 0 ? bottom : Sp.md),
      decoration: BoxDecoration(
        // Deep navy — matches AppColors.primary with slight transparency
        color: const Color(0xEA0D2347),
        borderRadius: BorderRadius.circular(Rd.xl),
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_tabs.length, (i) {
          final tab    = _tabs[i];
          final active = currentIndex == i;
          return _NavItem(
            iconOff: tab.$1,
            iconOn:  tab.$2,
            label:   tab.$3,
            active:  active,
            onTap:   () => onTap(i),
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData iconOff, iconOn;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconOff,
    required this.iconOn,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: active
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
              : EdgeInsets.zero,
          decoration: active
              ? BoxDecoration(
                  color: AppColors.accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(Rd.md),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? iconOn : iconOff,
                color: active
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.42),
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active
                      ? AppColors.accent
                      : Colors.white.withOpacity(0.42),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}