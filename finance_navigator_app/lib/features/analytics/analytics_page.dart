import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedPeriod = 1; // 0=Week, 1=Month, 2=Year
  final List<String> _periods = ['Week', 'Month', 'Year'];

  // Monthly spending data for the bar chart (last 6 months)
  final List<_MonthBar> _bars = [
    _MonthBar('Nov', 1820, 3200),
    _MonthBar('Dec', 2650, 3800),
    _MonthBar('Jan', 1920, 3100),
    _MonthBar('Feb', 2380, 3500),
    _MonthBar('Mar', 1740, 4100),
    _MonthBar('Apr', 2150, 4500),
  ];

  final List<_CategorySpend> _categories = [
    _CategorySpend(Icons.restaurant_outlined,  'Food & Dining',    640, 800,  AppColors.accent),
    _CategorySpend(Icons.directions_car_outlined, 'Transport',     180, 300,  AppColors.income),
    _CategorySpend(Icons.movie_outlined,        'Entertainment',   150, 200,  const Color(0xFFA29BFE)),
    _CategorySpend(Icons.flash_on_outlined,     'Bills',           360, 400,  AppColors.warning),
    _CategorySpend(Icons.shopping_bag_outlined, 'Shopping',         95, 250,  const Color(0xFF4ECDC4)),
    _CategorySpend(Icons.fitness_center_outlined,'Health',          50, 100,  const Color(0xFFFF7675)),
  ];

  @override
  Widget build(BuildContext context) {
    final maxSpend = _categories.fold(0.0, (m, c) => c.spent > m ? c.spent : m);

    return Stack(children: [
        Positioned(
          top: -80, right: -40,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.income.withOpacity(0.12), Colors.transparent]),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Analytics', style: AppText.h2.copyWith(color: AppColors.onDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        border: Border.all(color: AppColors.glassBorder),
                        borderRadius: BorderRadius.circular(Rd.full),
                      ),
                      child: Text('April 2026',
                          style: AppText.caption.copyWith(
                              color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.lg),

                // ── Period selector ──────────────────────
                Row(
                  children: List.generate(_periods.length, (i) {
                    final active = _selectedPeriod == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : AppColors.glassWhite,
                          border: Border.all(
                              color: active ? AppColors.accent : AppColors.glassBorder),
                          borderRadius: BorderRadius.circular(Rd.full),
                        ),
                        child: Text(_periods[i], style: TextStyle(
                          color: active ? AppColors.primaryDark : AppColors.onDark.withOpacity(0.60),
                          fontSize: 12, fontWeight: FontWeight.w600,
                        )),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: Sp.xl),

                // ── Summary row ──────────────────────────
                Row(children: [
                  Expanded(child: _summaryTile(
                    label: 'Total Spent', value: '\$2,150',
                    sub: '-8% vs last month', subColor: AppColors.income,
                    icon: Icons.trending_down_rounded, iconColor: AppColors.income,
                  )),
                  const SizedBox(width: Sp.md),
                  Expanded(child: _summaryTile(
                    label: 'Total Income', value: '\$4,500',
                    sub: '+12% vs last month', subColor: AppColors.income,
                    icon: Icons.trending_up_rounded, iconColor: AppColors.income,
                  )),
                ]),
                const SizedBox(height: Sp.md),
                GlassCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Net Savings This Month',
                            style: AppText.caption.copyWith(
                                color: AppColors.onDark.withOpacity(0.60))),
                        const SizedBox(height: Sp.xs),
                        const Text('\$2,350',
                            style: TextStyle(color: AppColors.income,
                                fontSize: 26, fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                      ],
                    )),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.income.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(Rd.md),
                      ),
                      child: const Icon(Icons.account_balance_wallet_outlined,
                          color: AppColors.income, size: 22),
                    ),
                  ]),
                ),
                const SizedBox(height: Sp.xl),

                // ── Bar chart ────────────────────────────
                Text('Income vs Expenses',
                    style: AppText.h3.copyWith(color: AppColors.onDark)),
                const SizedBox(height: Sp.md),
                GlassCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(children: [
                    // Legend
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      _legend(AppColors.income, 'Income'),
                      const SizedBox(width: 16),
                      _legend(AppColors.expense, 'Expense'),
                    ]),
                    const SizedBox(height: Sp.md),
                    SizedBox(
                      height: 160,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _bars.map((b) {
                          final maxVal = 5000.0;
                          return _BarGroup(bar: b, maxVal: maxVal);
                        }).toList(),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: Sp.xl),

                // ── Spending donut ───────────────────────
                Text('Spending by Category',
                    style: AppText.h3.copyWith(color: AppColors.onDark)),
                const SizedBox(height: Sp.md),
                GlassCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Row(children: [
                    // Simple pie placeholder (custom paint)
                    SizedBox(
                      width: 110, height: 110,
                      child: CustomPaint(
                        painter: _DonutPainter(_categories),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$2,150', style: AppText.body.copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 12)),
                              Text('spent', style: AppText.caption.copyWith(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Sp.lg),
                    Expanded(
                      child: Column(
                        children: _categories.take(4).map((c) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Container(width: 8, height: 8,
                                  decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(c.name,
                                  style: AppText.caption.copyWith(fontSize: 11),
                                  overflow: TextOverflow.ellipsis)),
                              Text('\$${c.spent.toInt()}',
                                  style: AppText.caption.copyWith(
                                      color: AppColors.onDark.withOpacity(0.70),
                                      fontWeight: FontWeight.w600, fontSize: 11)),
                            ]),
                          ),
                        ).toList(),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: Sp.xl),

                // ── Category breakdown ───────────────────
                Text('Category Breakdown',
                    style: AppText.h3.copyWith(color: AppColors.onDark)),
                const SizedBox(height: Sp.md),
                ..._categories.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: Sp.md),
                  child: _CategoryRow(category: c, maxSpend: maxSpend),
                )),
              ],
            ),
          ),
        ),
      ]);
  }

  Widget _summaryTile({required String label, required String value,
      required String sub, required Color subColor,
      required IconData icon, required Color iconColor}) {
    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(label, style: AppText.caption.copyWith(
              color: AppColors.onDark.withOpacity(0.60), fontSize: 10)),
        ]),
        const SizedBox(height: Sp.sm),
        Text(value, style: AppText.h3),
        const SizedBox(height: Sp.xs),
        Text(sub, style: AppText.caption.copyWith(color: subColor, fontSize: 10)),
      ]),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: AppText.caption.copyWith(fontSize: 11)),
    ]);
  }
}

// ── Bar chart group ──────────────────────────────────────────────────────────
class _MonthBar { final String month; final double spent, income;
  const _MonthBar(this.month, this.spent, this.income); }

class _BarGroup extends StatelessWidget {
  final _MonthBar bar;
  final double maxVal;
  const _BarGroup({required this.bar, required this.maxVal});

  @override
  Widget build(BuildContext context) {
    final spentH = (bar.spent / maxVal) * 130;
    final incomeH = (bar.income / maxVal) * 130;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 14, height: incomeH,
              decoration: BoxDecoration(
                color: AppColors.income,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 3),
            Container(
              width: 14, height: spentH,
              decoration: BoxDecoration(
                color: AppColors.expense.withOpacity(0.75),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(bar.month, style: AppText.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

// ── Donut painter ────────────────────────────────────────────────────────────
class _CategorySpend {
  final IconData icon; final String name;
  final double spent, budget; final Color color;
  const _CategorySpend(this.icon, this.name, this.spent, this.budget, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_CategorySpend> categories;
  const _DonutPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold(0.0, (s, c) => s + c.spent);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final paint = Paint()..style = PaintingStyle.stroke
      ..strokeWidth = 16 ..strokeCap = StrokeCap.butt;

    double startAngle = -1.5708; // -pi/2
    for (final c in categories) {
      final sweep = (c.spent / total) * 6.2832;
      paint.color = c.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep - 0.04, false, paint,
      );
      startAngle += sweep;
    }
  }

  @override bool shouldRepaint(_) => false;
}

// ── Category row ──────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final _CategorySpend category;
  final double maxSpend;
  const _CategoryRow({required this.category, required this.maxSpend});

  @override
  Widget build(BuildContext context) {
    final pct = category.spent / category.budget;
    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(Rd.md),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const SizedBox(width: Sp.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(category.name, style: AppText.body.copyWith(
                color: AppColors.onDark, fontWeight: FontWeight.w500)),
            const SizedBox(height: Sp.xs),
            Text('\$${category.spent.toInt()} of \$${category.budget.toInt()}',
                style: AppText.caption.copyWith(color: AppColors.onDark.withOpacity(0.60))),
          ])),
          Text('${(pct * 100).toInt()}%',
              style: AppText.body.copyWith(
                color: pct > 0.85 ? AppColors.expense : category.color,
                fontWeight: FontWeight.w600,
              )),
        ]),
        const SizedBox(height: Sp.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(Rd.sm),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0), minHeight: 4,
            backgroundColor: AppColors.onDark.withOpacity(0.10),
            valueColor: AlwaysStoppedAnimation<Color>(
                pct > 0.85 ? AppColors.expense : category.color),
          ),
        ),
      ]),
    );
  }
}