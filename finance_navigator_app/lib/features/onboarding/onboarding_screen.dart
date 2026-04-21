import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

// ─────────────────────────────────────────────
//  Onboarding data model
// ─────────────────────────────────────────────

class _OnboardPage {
  final String tag;
  final String title;
  final String description;
  final Color orbColor; 
  final Widget illustration;

  const _OnboardPage({
    required this.tag,
    required this.title,
    required this.description,
    required this.orbColor,
    required this.illustration,
  });
}

// ─────────────────────────────────────────────
//  OnboardingScreen
// ─────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late AnimationController _illustCtrl;
  late Animation<double> _illustFade;
  late Animation<Offset> _illustSlide;

  @override
  void initState() {
    super.initState();
    _illustCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _illustFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _illustCtrl, curve: Curves.easeOut),
    );
    _illustSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _illustCtrl, curve: Curves.easeOut));
    _illustCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _illustCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _illustCtrl.reverse().then((_) {
        _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic,
        );
        _illustCtrl.forward();
      });
    } else {
      widget.onFinished();
    }
  }

  List<_OnboardPage> get _pages => [
        _OnboardPage(
          tag: 'TRACK',
          title: 'Every penny,\nperfectly tracked',
          description:
              'Log income and expenses in seconds. See where your money goes with beautiful charts and instant insights.',
          orbColor: AppColors.accent.withOpacity(0.12),
          illustration: const _TrackIllustration(),
        ),
        _OnboardPage(
          tag: 'BILLS',
          title: 'Never miss a\npayment again',
          description:
              'See all your bills on a visual calendar. Get smart reminders before due dates and track payment history.',
          orbColor: AppColors.expense.withOpacity(0.12),
          illustration: const _BillsIllustration(),
        ),
        _OnboardPage(
          tag: 'GOALS',
          title: 'Save smarter,\nreach goals faster',
          description:
              'Set savings goals for anything — vacation, emergency fund, new car. Watch your progress grow every day.',
          orbColor: AppColors.income.withOpacity(0.10),
          illustration: const _GoalsIllustration(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // ── Background orb (changes per page) ───────
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _pages[_currentPage].orbColor,
                  Colors.transparent,
                ],
                center: const Alignment(0, -0.5),
                radius: 0.8,
              ),
            ),
          ),

          // ── Page content ─────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar: logo + skip
                Padding(
                  padding: const EdgeInsets.only(
                      left: Sp.md, right: Sp.md, top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mini logo
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 28,
                            height: 28,
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Finance ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Navigator',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Skip button
                      TextButton(
                        onPressed: widget.onFinished,
                        child: Text(
                          'Skip',
                          style: AppText.body.copyWith(
                            color: AppColors.onDark.withOpacity(0.45),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Illustration area
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) {
                      setState(() => _currentPage = i);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _illustFade,
                        child: SlideTransition(
                          position: _illustSlide,
                          child: Center(
                            child: _pages[index].illustration,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Bottom content panel ─────────────────
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.30),
                            ),
                            borderRadius: Rd.chip,
                          ),
                          child: Text(
                            _pages[_currentPage].tag,
                            style: AppText.label,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title — animated
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _pages[_currentPage].title,
                            key: ValueKey(_currentPage),
                            style: AppText.h2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Description
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _pages[_currentPage].description,
                            key: ValueKey('d$_currentPage'),
                            style: AppText.bodyMuted,
                          ),
                        ),

                        const Spacer(),

                        // Dots + CTA button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dot indicators
                            Row(
                              children: List.generate(3, (i) {
                                final isActive = i == _currentPage;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.only(right: 6),
                                  width: isActive ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.accent
                                        : AppColors.onDark.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),

                            // Next / Get Started button
                            GestureDetector(
                              onTap: _nextPage,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 13),
                                decoration: BoxDecoration(
                                  gradient: _currentPage == 2
                                      ? AppGradients.income
                                      : AppGradients.accent,
                                  borderRadius: Rd.button,
                                  boxShadow: _currentPage == 2
                                      ? [
                                          BoxShadow(
                                            color: AppColors.income
                                                .withOpacity(0.35),
                                            blurRadius: 20,
                                            offset: const Offset(0, 6),
                                          )
                                        ]
                                      : AppShadows.goldGlow,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentPage == 2
                                          ? 'Get Started'
                                          : 'Next',
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    if (_currentPage < 2) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: AppColors.primaryDark,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Sp.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Illustration 1 — Track Everything
// ─────────────────────────────────────────────

class _TrackIllustration extends StatelessWidget {
  const _TrackIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 240,
      child: Stack(
        children: [
          // Balance card
          Positioned(
            top: 0,
            left: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 185,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL BALANCE',
                        style: AppText.caption
                            .copyWith(letterSpacing: 0.8, fontSize: 9)),
                    const SizedBox(height: 4),
                    const Text('\$12,480.50', style: AppText.money),
                    const SizedBox(height: 2),
                    Text('↑ +12% this month',
                        style: AppText.caption
                            .copyWith(color: AppColors.accent)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _MiniStat(
                            label: 'Income',
                            value: '\$6,200',
                            color: AppColors.income),
                        const SizedBox(width: 8),
                        _MiniStat(
                            label: 'Expense',
                            value: '\$2,140',
                            color: AppColors.expense),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Transactions card
          Positioned(
            top: 120,
            right: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 172,
                child: Column(
                  children: [
                    _TxnRow(
                        icon: '🛒',
                        color: AppColors.expense.withOpacity(0.2),
                        name: 'Grocery Store',
                        cat: 'Food',
                        amount: '-\$84',
                        isNeg: true),
                    const Divider(
                        color: Colors.white12, height: 10, thickness: 0.5),
                    _TxnRow(
                        icon: '💼',
                        color: AppColors.income.withOpacity(0.2),
                        name: 'Salary',
                        cat: 'Income',
                        amount: '+\$3,000',
                        isNeg: false),
                    const Divider(
                        color: Colors.white12, height: 10, thickness: 0.5),
                    _TxnRow(
                        icon: '🚌',
                        color: const Color(0x334ECDC4),
                        name: 'Transport',
                        cat: 'Commute',
                        amount: '-\$45',
                        isNeg: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    AppText.caption.copyWith(fontSize: 9)),
            const SizedBox(height: 2),
            Text(value,
                style: AppText.body.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  final String icon;
  final Color color;
  final String name;
  final String cat;
  final String amount;
  final bool isNeg;
  const _TxnRow(
      {required this.icon,
      required this.color,
      required this.name,
      required this.cat,
      required this.amount,
      required this.isNeg});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 12))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppText.body.copyWith(
                      fontSize: 10,
                      color: AppColors.onDark.withOpacity(0.85))),
              Text(cat,
                  style: AppText.caption.copyWith(fontSize: 9)),
            ],
          ),
        ),
        Text(
          amount,
          style: AppText.body.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isNeg ? AppColors.expense : AppColors.income,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Illustration 2 — Bills & Calendar
// ─────────────────────────────────────────────

class _BillsIllustration extends StatelessWidget {
  const _BillsIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 240,
      child: Stack(
        children: [
          // Mini calendar
          Positioned(
            top: 0,
            left: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: 185,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('April 2026',
                            style: AppText.body.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        Text('◀ ▶',
                            style: AppText.caption.copyWith(fontSize: 9)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _MiniCalendar(),
                  ],
                ),
              ),
            ),
          ),
          // Bills list
          Positioned(
            top: 115,
            right: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 178,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UPCOMING BILLS',
                        style: AppText.caption.copyWith(
                            fontSize: 9, letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    _BillRow(
                        icon: '📡',
                        iconBg: const Color(0x334ECDC4),
                        name: 'Internet',
                        sub: 'Due Apr 25',
                        badge: _Badge(text: '3d', isAlert: true)),
                    const Divider(
                        color: Colors.white12, height: 10, thickness: 0.5),
                    _BillRow(
                        icon: '⚡',
                        iconBg: AppColors.expense.withOpacity(0.2),
                        name: 'Electricity',
                        sub: 'Due Apr 10',
                        badge: _Badge(text: 'Due', isAlert: true)),
                    const Divider(
                        color: Colors.white12, height: 10, thickness: 0.5),
                    _BillRow(
                        icon: '📺',
                        iconBg: const Color(0x33A29BFE),
                        name: 'Netflix',
                        sub: 'Apr 1',
                        badge: _Badge(text: 'Paid', isAlert: false)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  const _MiniCalendar();

  @override
  Widget build(BuildContext context) {
    // Day labels
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    // Apr 2026 starts on Wednesday (index 3), 30 days
    // Cells: 3 empty + days 1-30 = 33 cells → 5 weeks
    const hasBill = {1, 10, 15, 25};
    const paid = {1, 15};
    const today = 20;

    return Column(
      children: [
        // Header row
        Row(
          children: dayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: AppText.caption.copyWith(fontSize: 8)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Grid
        Builder(builder: (_) {
          const offset = 3; // April starts Wednesday
          const totalDays = 30;
          final cells = offset + totalDays;
          final rows = (cells / 7).ceil();

          return Column(
            children: List.generate(rows, (row) {
              return Row(
                children: List.generate(7, (col) {
                  final idx = row * 7 + col;
                  final day = idx - offset + 1;
                  if (day < 1 || day > totalDays) {
                    return const Expanded(child: SizedBox(height: 18));
                  }
                  final isToday = day == today;
                  final bill = hasBill.contains(day);
                  final isPaid = paid.contains(day);
                  return Expanded(
                    child: Container(
                      height: 20,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$day',
                            style: AppText.caption.copyWith(
                              fontSize: 8,
                              color: isToday
                                  ? AppColors.primaryDark
                                  : AppColors.onDark.withOpacity(0.5),
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          if (bill && !isToday)
                            Positioned(
                              bottom: 1,
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? AppColors.income
                                      : AppColors.expense,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
          );
        }),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final String name;
  final String sub;
  final Widget badge;
  const _BillRow(
      {required this.icon,
      required this.iconBg,
      required this.name,
      required this.sub,
      required this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration:
              BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(7)),
          child:
              Center(child: Text(icon, style: const TextStyle(fontSize: 12))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppText.body.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onDark.withOpacity(0.85))),
              Text(sub, style: AppText.caption.copyWith(fontSize: 9)),
            ],
          ),
        ),
        badge,
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final bool isAlert;
  const _Badge({required this.text, required this.isAlert});

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? AppColors.expense : AppColors.income;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: AppText.caption.copyWith(
              color: color, fontSize: 8, fontWeight: FontWeight.w700)),
    );
  }
}

// ─────────────────────────────────────────────
//  Illustration 3 — Savings Goals
// ─────────────────────────────────────────────

class _GoalsIllustration extends StatelessWidget {
  const _GoalsIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 240,
      child: Stack(
        children: [
          // Total saved header
          Positioned(
            top: 0,
            left: 10,
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: 190,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Saved',
                        style: AppText.caption.copyWith(fontSize: 10)),
                    const SizedBox(height: 4),
                    const Text('\$8,550', style: AppText.moneyLarge),
                    const SizedBox(height: 2),
                    Text('3 goals in progress',
                        style:
                            AppText.caption.copyWith(color: AppColors.accent)),
                  ],
                ),
              ),
            ),
          ),
          // Vacation goal
          Positioned(
            top: 100,
            left: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 178,
                child: _GoalCard(
                  icon: '✈️',
                  iconBg: AppColors.accent.withOpacity(0.18),
                  name: 'Vacation',
                  sub: 'Jul 2026',
                  current: 1200,
                  target: 3000,
                  progressColor: AppColors.accent,
                ),
              ),
            ),
          ),
          // Emergency fund
          Positioned(
            top: 170,
            right: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 178,
                child: _GoalCard(
                  icon: '🔒',
                  iconBg: AppColors.expense.withOpacity(0.18),
                  name: 'Emergency Fund',
                  sub: 'Dec 2026',
                  current: 6500,
                  target: 10000,
                  progressColor: AppColors.income,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final String name;
  final String sub;
  final double current;
  final double target;
  final Color progressColor;

  const _GoalCard({
    required this.icon,
    required this.iconBg,
    required this.name,
    required this.sub,
    required this.current,
    required this.target,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration:
                  BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 15))),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppText.body.copyWith(
                        fontSize: 11, fontWeight: FontWeight.w600)),
                Text(sub, style: AppText.caption.copyWith(fontSize: 9)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${current.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: AppText.body.copyWith(
                    fontSize: 11, fontWeight: FontWeight.w700)),
            Text(
                '/ \$${target.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: AppText.caption.copyWith(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor: Colors.white.withOpacity(0.10),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}