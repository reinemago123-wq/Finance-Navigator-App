import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../services/user_service.dart';
import '../add_transaction/add_transaction_page.dart';
import '../transactions/transactions_page.dart';
import '../budget/budget_page.dart';
import '../savings/savings_page.dart';
import '../calendar/calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateTime _selectedDate = DateTime.now();

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background orb
        Positioned(
          top: -100, left: 0, right: 0,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppColors.accent.withOpacity(0.15), Colors.transparent],
                radius: 0.7,
              ),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Header ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${UserService.firstName}',
                          style: AppText.h2.copyWith(color: AppColors.onDark),
                        ),
                        const SizedBox(height: Sp.xs),
                        Text(
                          DateFormat('EEEE, MMM d').format(_selectedDate),
                          style: AppText.body.copyWith(
                              color: AppColors.onDark.withOpacity(0.60)),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          border: Border.all(color: AppColors.glassBorder),
                          borderRadius: BorderRadius.circular(Rd.lg),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.notifications_outlined,
                                color: AppColors.accent, size: 24),
                            Positioned(
                              top: 8, right: 8,
                              child: Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                    color: AppColors.income,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.xl),

                // ── Gold balance card ────────────────────────
                GlassCard.gold(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Balance',
                          style: AppText.label.copyWith(
                              color: AppColors.accent.withOpacity(0.80))),
                      const SizedBox(height: Sp.md),
                      const Text('\$12,458.50', style: AppText.moneyLarge),
                      const SizedBox(height: Sp.md),
                      Row(children: [
                        Expanded(child: _balanceItem(
                            label: 'Savings', amount: '\$8,250.00',
                            color: AppColors.income)),
                        const SizedBox(width: Sp.md),
                        Expanded(child: _balanceItem(
                            label: 'Checking', amount: '\$4,208.50',
                            color: AppColors.accent)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: Sp.xl),

                // ── Income / Expense cards ───────────────────
                Row(children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(Sp.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Income',
                              style: AppText.label.copyWith(
                                  color: AppColors.income)),
                          const SizedBox(height: Sp.md),
                          const Text('\$4,500', style: AppText.money),
                          const SizedBox(height: Sp.sm),
                          Text('+12% vs last month',
                              style: AppText.caption.copyWith(
                                  color: AppColors.income)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(Sp.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expenses',
                              style: AppText.label.copyWith(
                                  color: AppColors.expense)),
                          const SizedBox(height: Sp.md),
                          const Text('\$2,150', style: AppText.money),
                          const SizedBox(height: Sp.sm),
                          Text('-8% vs last month',
                              style: AppText.caption.copyWith(
                                  color: AppColors.income)),
                        ],
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: Sp.xl),

                // ── Quick Actions ────────────────────────────
                Text('Quick Actions',
                    style: AppText.h3.copyWith(color: AppColors.onDark)),
                const SizedBox(height: Sp.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quickAction(
                        icon: Icons.add_circle_outline, label: 'Income',
                        onTap: () => _push(AddTransactionPage(initialType: TxnType.income))),
                    _quickAction(
                        icon: Icons.remove_circle_outline, label: 'Expense',
                        onTap: () => _push(AddTransactionPage(initialType: TxnType.expense))),
                    _quickAction(
                        icon: Icons.event_note_outlined, label: 'Bill',
                        onTap: () => _push(AddTransactionPage(initialType: TxnType.bill))),
                    _quickAction(
                        icon: Icons.savings_outlined, label: 'Savings',
                        onTap: () => _push(AddTransactionPage(initialType: TxnType.savings))),
                  ],
                ),
                const SizedBox(height: Sp.xl),

                // ── Savings Goal ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Savings Goal',
                        style: AppText.h3.copyWith(color: AppColors.onDark)),
                    GestureDetector(
                      onTap: () => _push(const SavingsPage()),
                      child: Text('View all',
                          style: AppText.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.md),
                GlassCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Row(children: [
                    SizedBox(
                      width: 100, height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.65, strokeWidth: 8,
                            backgroundColor: AppColors.onDark.withOpacity(0.10),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.income),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Sp.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vacation Fund',
                              style: AppText.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onDark)),
                          const SizedBox(height: Sp.sm),
                          Text('\$6,500 / \$10,000',
                              style: AppText.money.copyWith(
                                  color: AppColors.accent)),
                          const SizedBox(height: Sp.md),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Rd.sm),
                            child: LinearProgressIndicator(
                              value: 0.65, minHeight: 4,
                              backgroundColor: AppColors.onDark.withOpacity(0.10),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: Sp.xl),

                // ── Budget Status ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget Status',
                        style: AppText.h3.copyWith(color: AppColors.onDark)),
                    GestureDetector(
                      onTap: () => _push(const BudgetPage()),
                      child: Text('View all',
                          style: AppText.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.md),
                _budgetItem(label: 'Food & Dining', spent: 320, budget: 500,
                    icon: Icons.restaurant_outlined, color: AppColors.accent),
                const SizedBox(height: Sp.md),
                _budgetItem(label: 'Transportation', spent: 180, budget: 250,
                    icon: Icons.directions_car_outlined, color: AppColors.income),
                const SizedBox(height: Sp.md),
                _budgetItem(label: 'Entertainment', spent: 150, budget: 200,
                    icon: Icons.movie_outlined, color: AppColors.warning),
                const SizedBox(height: Sp.xl),

                // ── Recent Transactions ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions',
                        style: AppText.h3.copyWith(color: AppColors.onDark)),
                    GestureDetector(
                      onTap: () => _push(const TransactionsPage()),
                      child: Text('View All',
                          style: AppText.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.md),
                _txnItem(icon: Icons.shopping_bag_outlined,
                    label: 'Grocery Store', date: 'Today at 2:30 PM',
                    amount: '-\$45.99', isExpense: true),
                const SizedBox(height: Sp.md),
                _txnItem(icon: Icons.work_outline,
                    label: 'Salary Deposit', date: 'Yesterday',
                    amount: '+\$3,500.00', isExpense: false),
                const SizedBox(height: Sp.md),
                _txnItem(icon: Icons.local_cafe_outlined,
                    label: 'Coffee Shop', date: 'Apr 19',
                    amount: '-\$5.50', isExpense: true),
                const SizedBox(height: Sp.xl),

                // ── Upcoming Bills ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Bills',
                        style: AppText.h3.copyWith(color: AppColors.onDark)),
                    GestureDetector(
                      onTap: () => _push(const CalendarPage()),
                      child: Text('View All',
                          style: AppText.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.md),
                _billItem(provider: 'Electricity Bill', amount: '\$125.00',
                    dueDate: 'Due in 5 days', status: 'Pending',
                    icon: Icons.flash_on_outlined),
                const SizedBox(height: Sp.md),
                _billItem(provider: 'Internet Service', amount: '\$59.99',
                    dueDate: 'Due in 8 days', status: 'Pending',
                    icon: Icons.wifi_outlined),
                const SizedBox(height: Sp.md),
                _billItem(provider: 'Gym Membership', amount: '\$49.99',
                    dueDate: 'Due Tomorrow', status: 'Urgent',
                    icon: Icons.fitness_center_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _balanceItem({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppText.caption.copyWith(
              color: AppColors.onDark.withOpacity(0.60))),
      const SizedBox(height: Sp.sm),
      Text(amount, style: AppText.h3.copyWith(color: color)),
    ]);
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.3),
                AppColors.accent.withOpacity(0.1),
              ],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            border: Border.all(
                color: AppColors.accent.withOpacity(0.4), width: 1.0),
            borderRadius: BorderRadius.circular(Rd.lg),
          ),
          child: Icon(icon, color: AppColors.accent, size: 28),
        ),
        const SizedBox(height: Sp.sm),
        Text(label,
            style: AppText.caption.copyWith(
                color: AppColors.onDark.withOpacity(0.70))),
      ]),
    );
  }

  Widget _budgetItem({
    required String label,
    required double spent,
    required double budget,
    required IconData icon,
    required Color color,
  }) {
    final pct = spent / budget;
    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Rd.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: Sp.md),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppText.body.copyWith(color: AppColors.onDark)),
              const SizedBox(height: Sp.xs),
              Text('\$${spent.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}',
                  style: AppText.caption.copyWith(
                      color: AppColors.onDark.withOpacity(0.60))),
            ],
          )),
          Text('${(pct * 100).toStringAsFixed(0)}%',
              style: AppText.body.copyWith(
                color: pct > 0.8 ? AppColors.expense : color,
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
                pct > 0.8 ? AppColors.expense : color),
          ),
        ),
      ]),
    );
  }

  Widget _txnItem({
    required IconData icon,
    required String label,
    required String date,
    required String amount,
    required bool isExpense,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: (isExpense ? AppColors.expense : AppColors.income)
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(Rd.md),
          ),
          child: Icon(icon,
              color: isExpense ? AppColors.expense : AppColors.income,
              size: 22),
        ),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.body.copyWith(
                color: AppColors.onDark, fontWeight: FontWeight.w500)),
            const SizedBox(height: Sp.xs),
            Text(date, style: AppText.caption.copyWith(
                color: AppColors.onDark.withOpacity(0.60))),
          ],
        )),
        Text(amount, style: AppText.body.copyWith(
          color: isExpense ? AppColors.expense : AppColors.income,
          fontWeight: FontWeight.w600,
        )),
      ]),
    );
  }

  Widget _billItem({
    required String provider,
    required String amount,
    required String dueDate,
    required String status,
    required IconData icon,
  }) {
    final isUrgent = status == 'Urgent';
    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: (isUrgent ? AppColors.expense : AppColors.accent)
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(Rd.md),
          ),
          child: Icon(icon,
              color: isUrgent ? AppColors.expense : AppColors.accent,
              size: 22),
        ),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider, style: AppText.body.copyWith(
                color: AppColors.onDark, fontWeight: FontWeight.w500)),
            const SizedBox(height: Sp.xs),
            Text(dueDate, style: AppText.caption.copyWith(
              color: isUrgent
                  ? AppColors.expense
                  : AppColors.onDark.withOpacity(0.60),
              fontWeight: isUrgent ? FontWeight.w600 : null,
            )),
          ],
        )),
        Text(amount, style: AppText.body.copyWith(
            color: AppColors.onDark, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}