import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppTab {
  static const int home         = 0;
  static const int analytics    = 1;
  static const int transactions = 2;
  static const int calendar     = 3;
  static const int profile      = 4;
}

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _tabs = [
    (Icons.home_outlined,           Icons.home_rounded,          'Home'),
    (Icons.analytics_outlined,      Icons.analytics_rounded,     'Analytics'),
    (Icons.receipt_long_outlined,   Icons.receipt_long_rounded,  'Transactions'),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded,'Calendar'),
    (Icons.person_outline_rounded,  Icons.person_rounded,        'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = context.isDark;
    final bgColor = isDark
        ? const Color(0xEA0D2347)
        : Colors.white.withOpacity(0.92);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.13)
        : Colors.black.withOpacity(0.08);
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.42)
        : AppColors.primary.withOpacity(0.45);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, bottom > 0 ? bottom : Sp.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Rd.xl),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.12),
            blurRadius: 28, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_tabs.length, (i) {
          final tab    = _tabs[i];
          final active = currentIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
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
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(active ? tab.$2 : tab.$1,
                      color: active ? AppColors.accent : inactiveColor,
                      size: 22),
                  const SizedBox(height: 3),
                  Text(tab.$3, style: TextStyle(
                    fontSize: 9,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? AppColors.accent : inactiveColor,
                    letterSpacing: 0.2,
                  )),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}