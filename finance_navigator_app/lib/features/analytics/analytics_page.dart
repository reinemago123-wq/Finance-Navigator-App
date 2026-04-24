import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedPeriod = 1; // 0=Week 1=Month 2=Year
  final _periods = ['Week', 'Month', 'Year'];
  final _now = DateTime.now();

  // Date range for the selected period
  DateTime get _start {
    switch (_selectedPeriod) {
      case 0: return _now.subtract(const Duration(days: 7));
      case 2: return DateTime(_now.year, 1, 1);
      default: return DateTime(_now.year, _now.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: DbService.watchTransactions(),
      builder: (ctx, snap) {
        final all  = snap.data ?? [];
        final txns = all.where((t) => !t.date.isBefore(_start)).toList();

        final income  = txns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
        final expense = txns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
        final net     = income - expense;

        // Spending by category
        final catMap = <String, double>{};
        for (final t in txns.where((t) => t.isExpense)) {
          catMap[t.category] = (catMap[t.category] ?? 0) + t.amount;
        }
        final cats = catMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Monthly bars — last 6 months
        final bars = List.generate(6, (i) {
          final month = DateTime(_now.year, _now.month - (5 - i), 1);
          final monthTxns = all.where((t) =>
            t.date.year == month.year && t.date.month == month.month).toList();
          return _Bar(
            label: DateFormat('MMM').format(month),
            income:  monthTxns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount),
            expense: monthTxns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount),
          );
        });

        final isLoading = snap.connectionState == ConnectionState.waiting;

        return Stack(children: [
          Positioned(top: -80, right: -40, child: Container(width: 280, height: 280,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.income.withOpacity(0.12), Colors.transparent])))),

          SafeArea(bottom: false, child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Header ──────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Analytics', style: AppText.h2.copyWith(color: AppColors.onDark)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.glassWhite,
                    border: Border.all(color: AppColors.glassBorder),
                    borderRadius: BorderRadius.circular(Rd.full)),
                  child: Text(DateFormat('MMMM yyyy').format(_now),
                    style: AppText.caption.copyWith(
                      color: AppColors.accent, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: Sp.lg),

              // ── Period selector ──────────────────────
              Row(children: List.generate(_periods.length, (i) {
                final active = _selectedPeriod == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.accent : AppColors.glassWhite,
                      border: Border.all(color: active ? AppColors.accent : AppColors.glassBorder),
                      borderRadius: BorderRadius.circular(Rd.full)),
                    child: Text(_periods[i], style: TextStyle(
                      color: active ? AppColors.primaryDark : AppColors.onDark.withOpacity(0.60),
                      fontSize: 12, fontWeight: FontWeight.w600))));
              })),
              const SizedBox(height: Sp.xl),

              if (isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.accent)))
              else ...[

              // ── Summary tiles ────────────────────────
              Row(children: [
                Expanded(child: _SummaryTile(label: 'Total Spent', value: '\$${expense.toStringAsFixed(0)}',
                  sub: txns.where((t) => t.isExpense).length.toString() + ' transactions',
                  subColor: AppColors.onDark.withOpacity(0.45),
                  icon: Icons.trending_down_rounded, iconColor: AppColors.expense)),
                const SizedBox(width: Sp.md),
                Expanded(child: _SummaryTile(label: 'Total Income', value: '\$${income.toStringAsFixed(0)}',
                  sub: txns.where((t) => t.isIncome).length.toString() + ' transactions',
                  subColor: AppColors.onDark.withOpacity(0.45),
                  icon: Icons.trending_up_rounded, iconColor: AppColors.income)),
              ]),
              const SizedBox(height: Sp.md),
              GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Net Savings', style: AppText.caption.copyWith(
                    color: AppColors.onDark.withOpacity(0.60))),
                  const SizedBox(height: Sp.xs),
                  Text('\$${net.toStringAsFixed(0)}', style: TextStyle(
                    color: net >= 0 ? AppColors.income : AppColors.expense,
                    fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                ])),
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: (net >= 0 ? AppColors.income : AppColors.expense).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Rd.md)),
                  child: Icon(net >= 0 ? Icons.account_balance_wallet_outlined : Icons.warning_amber_rounded,
                    color: net >= 0 ? AppColors.income : AppColors.expense, size: 22)),
              ])),
              const SizedBox(height: Sp.xl),

              // ── Bar chart ────────────────────────────
              Text('Income vs Expenses', style: AppText.h3.copyWith(color: AppColors.onDark)),
              const SizedBox(height: Sp.md),
              GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _Legend(color: AppColors.income, label: 'Income'),
                  const SizedBox(width: 16),
                  _Legend(color: AppColors.expense.withOpacity(0.75), label: 'Expense'),
                ]),
                const SizedBox(height: Sp.md),
                SizedBox(height: 160, child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: bars.map((b) {
                    final maxVal = bars.fold(0.0, (m, x) => [x.income, x.expense, m].reduce((a, b) => a > b ? a : b));
                    return _BarGroup(bar: b, maxVal: maxVal > 0 ? maxVal : 1);
                  }).toList())),
              ])),
              const SizedBox(height: Sp.xl),

              // ── Donut + legend ───────────────────────
              if (cats.isNotEmpty) ...[
                Text('Spending by Category', style: AppText.h3.copyWith(color: AppColors.onDark)),
                const SizedBox(height: Sp.md),
                GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Row(children: [
                  SizedBox(width: 110, height: 110,
                    child: CustomPaint(
                      painter: _DonutPainter(cats.map((e) =>
                        _CatSpend(e.key, e.value, _catColor(cats.indexOf(e)))).toList()),
                      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('\$${expense.toInt()}', style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 12)),
                        Text('spent', style: AppText.caption.copyWith(fontSize: 10)),
                      ])))),
                  const SizedBox(width: Sp.lg),
                  Expanded(child: Column(children: cats.take(5).toList().asMap().entries.map((e) =>
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(
                          color: _catColor(e.key), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.value.key,
                          style: AppText.caption.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis)),
                        Text('\$${e.value.value.toInt()}', style: AppText.caption.copyWith(
                          color: AppColors.onDark.withOpacity(0.70),
                          fontWeight: FontWeight.w600, fontSize: 11)),
                      ]))).toList())),
                ])),
                const SizedBox(height: Sp.xl),

                // ── Category breakdown ───────────────────
                Text('Category Breakdown', style: AppText.h3.copyWith(color: AppColors.onDark)),
                const SizedBox(height: Sp.md),
                ...cats.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: Sp.md),
                  child: _CategoryRow(name: e.value.key, spent: e.value.value,
                    total: expense, color: _catColor(e.key)))),
              ],

              if (cats.isEmpty && !isLoading)
                GlassCard(padding: const EdgeInsets.all(Sp.xl), child: Column(children: [
                  Icon(Icons.analytics_outlined, color: AppColors.onDark.withOpacity(0.20), size: 56),
                  const SizedBox(height: Sp.md),
                  Text('No data for this period',
                    style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.45))),
                  const SizedBox(height: Sp.sm),
                  Text('Add some transactions to see analytics',
                    style: AppText.caption.copyWith(fontSize: 12)),
                ])),
              ],
            ]),
          )),
        ]);
      });
  }

  static const _palette = [
    Color(0xFFF4B942), Color(0xFF2ECC71), Color(0xFF4ECDC4),
    Color(0xFFE74C3C), Color(0xFFA29BFE), Color(0xFFFF7675),
    Color(0xFF4A9EE8), Color(0xFFF39C12),
  ];
  Color _catColor(int i) => _palette[i % _palette.length];
}

// ── Widgets ────────────────────────────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String label, value, sub;
  final Color subColor, iconColor;
  final IconData icon;
  const _SummaryTile({required this.label, required this.value, required this.sub,
    required this.subColor, required this.iconColor, required this.icon});
  @override
  Widget build(BuildContext context) => GlassCard(padding: const EdgeInsets.all(Sp.md),
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
  ]));
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(
      color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 5),
    Text(label, style: AppText.caption.copyWith(fontSize: 11)),
  ]);
}

class _Bar { final String label; final double income, expense;
  const _Bar({required this.label, required this.income, required this.expense});
}

class _BarGroup extends StatelessWidget {
  final _Bar bar; final double maxVal;
  const _BarGroup({required this.bar, required this.maxVal});
  @override
  Widget build(BuildContext context) {
    final iH = (bar.income  / maxVal) * 130;
    final eH = (bar.expense / maxVal) * 130;
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(width: 14, height: iH.clamp(2.0, 130.0),
          decoration: BoxDecoration(color: AppColors.income,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
        const SizedBox(width: 3),
        Container(width: 14, height: eH.clamp(2.0, 130.0),
          decoration: BoxDecoration(color: AppColors.expense.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
      ]),
      const SizedBox(height: 6),
      Text(bar.label, style: AppText.caption.copyWith(fontSize: 10)),
    ]);
  }
}

class _CatSpend { final String name; final double spent; final Color color;
  const _CatSpend(this.name, this.spent, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_CatSpend> cats;
  const _DonutPainter(this.cats);
  @override
  void paint(Canvas canvas, Size size) {
    final total = cats.fold(0.0, (s, c) => s + c.spent);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final paint  = Paint()..style = PaintingStyle.stroke..strokeWidth = 16..strokeCap = StrokeCap.butt;
    double start = -1.5708;
    for (final c in cats) {
      final sweep = (c.spent / total) * 6.2832;
      paint.color = c.color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        start, sweep - 0.04, false, paint);
      start += sweep;
    }
  }
  @override bool shouldRepaint(_) => true;
}

class _CategoryRow extends StatelessWidget {
  final String name; final double spent, total; final Color color;
  const _CategoryRow({required this.name, required this.spent, required this.total, required this.color});
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? spent / total : 0.0;
    return GlassCard(padding: const EdgeInsets.all(Sp.md), child: Column(children: [
      Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(Rd.md)),
          child: Icon(Icons.category_outlined, color: color, size: 20)),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: AppText.body.copyWith(
            color: AppColors.onDark, fontWeight: FontWeight.w500)),
          const SizedBox(height: Sp.xs),
          Text('\$${spent.toInt()} spent', style: AppText.caption.copyWith(
            color: AppColors.onDark.withOpacity(0.60))),
        ])),
        Text('${(pct * 100).toInt()}%', style: AppText.body.copyWith(
          color: color, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: Sp.md),
      ClipRRect(borderRadius: BorderRadius.circular(Rd.sm),
        child: LinearProgressIndicator(value: pct.clamp(0.0, 1.0), minHeight: 4,
          backgroundColor: AppColors.onDark.withOpacity(0.10),
          valueColor: AlwaysStoppedAnimation<Color>(color))),
    ]));
  }
}