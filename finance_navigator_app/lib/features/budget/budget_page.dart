import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});
  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final List<_BudgetCategory> _categories = [
    _BudgetCategory('🍕', 'Food & Dining',    800,  640, AppColors.expense,              12),
    _BudgetCategory('🚌', 'Transport',         400,  180, const Color(0xFF4ECDC4),        8),
    _BudgetCategory('🎮', 'Entertainment',     200,   95, const Color(0xFFA29BFE),        5),
    _BudgetCategory('💡', 'Bills & Utilities', 350,  360, AppColors.warning,              4),
    _BudgetCategory('🛍️', 'Shopping',          300,   88, const Color(0xFFFF7675),        3),
    _BudgetCategory('🏥', 'Health',            150,   40, const Color(0xFF00B894),        2),
  ];

  static const double _totalBudget = 4000;
  double get _totalSpent =>
      _categories.fold(0, (s, c) => s + c.spent);

  @override
  Widget build(BuildContext context) {
    final overBudget = _categories.where((c) => c.isOver).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          Positioned(
            top: -60, left: 0, right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [
                  AppColors.accent.withOpacity(0.10),
                  Colors.transparent,
                ], radius: 0.65),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Budget', style: AppText.h2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.14),
                          border: Border.all(
                              color: AppColors.accent.withOpacity(0.30)),
                          borderRadius: Rd.chip,
                        ),
                        child: Text('April 2026',
                            style: AppText.caption.copyWith(
                                color: AppColors.accent, fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.md),

                  // ── Total overview card ───────────────
                  GlassCard(
                    padding: const EdgeInsets.all(Sp.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL SPENT',
                                    style: AppText.caption.copyWith(
                                        letterSpacing: 0.8, fontSize: 10)),
                                const SizedBox(height: 3),
                                Text(
                                  '\$${_totalSpent.toInt()}',
                                  style: AppText.moneyLarge,
                                ),
                                Text(
                                  'of \$${_totalBudget.toInt()} budget',
                                  style: AppText.caption.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${((_totalSpent / _totalBudget) * 100).toInt()}%',
                                  style: TextStyle(
                                    color: _totalSpent > _totalBudget
                                        ? AppColors.expense
                                        : AppColors.income,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text('used',
                                    style: AppText.caption.copyWith(
                                        fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: Sp.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:
                                (_totalSpent / _totalBudget).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                AppColors.onDark.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _totalSpent > _totalBudget
                                  ? AppColors.expense
                                  : AppColors.income,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$0',
                                style: AppText.caption.copyWith(fontSize: 10)),
                            Text(
                              '\$${(_totalBudget - _totalSpent).abs().toInt()} ${_totalSpent > _totalBudget ? 'over' : 'remaining'}',
                              style: AppText.caption.copyWith(
                                color: _totalSpent > _totalBudget
                                    ? AppColors.expense
                                    : AppColors.income,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${_totalBudget.toInt()}',
                              style: AppText.caption.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sp.lg),

                  // ── Over-budget warning ───────────────
                  if (overBudget.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sp.md, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.10),
                        border: Border.all(
                            color: AppColors.warning.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(Rd.md),
                      ),
                      child: Row(children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${overBudget.map((c) => c.name).join(', ')} exceeded budget',
                            style: AppText.caption.copyWith(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Sp.md),
                  ],

                  // ── Category header ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Categories',
                          style: AppText.body.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      GestureDetector(
                        onTap: () {},
                        child: Text('Edit budgets',
                            style: AppText.caption.copyWith(
                                color: AppColors.accent, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.sm),

                  // ── Category cards ────────────────────
                  ..._categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: Sp.sm),
                      child: _CategoryCard(category: cat),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────
class _BudgetCategory {
  final String emoji, name;
  final double budget, spent;
  final Color color;
  final int transactions;

  const _BudgetCategory(
      this.emoji, this.name, this.budget, this.spent, this.color,
      this.transactions);

  double get pct => (spent / budget).clamp(0.0, 1.2);
  bool get isOver => spent > budget;
  double get remaining => budget - spent;
}

// ─────────────────────────────────────────────
//  Category card
// ─────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final _BudgetCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final barColor = category.isOver ? AppColors.expense : category.color;

    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      borderRadius: BorderRadius.circular(Rd.md),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(category.emoji,
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),

              // Name + txn count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name,
                        style: AppText.body.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${category.transactions} transactions',
                        style: AppText.caption.copyWith(fontSize: 10)),
                  ],
                ),
              ),

              // Amounts
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${category.spent.toInt()}',
                    style: TextStyle(
                      color: category.isOver
                          ? AppColors.expense
                          : AppColors.onDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      if (category.isOver)
                        const Icon(Icons.warning_rounded,
                            color: AppColors.warning, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        'of \$${category.budget.toInt()}',
                        style: AppText.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: category.pct.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AppColors.onDark.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 5),

          // Remaining label
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                category.isOver
                    ? '\$${category.remaining.abs().toInt()} over budget'
                    : '\$${category.remaining.toInt()} left',
                style: TextStyle(
                  color: category.isOver
                      ? AppColors.expense
                      : AppColors.onDark.withOpacity(0.40),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}