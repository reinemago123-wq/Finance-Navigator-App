import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../services/user_service.dart';
import '../../services/db_service.dart';
import '../../models/models.dart';
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
  final _now = DateTime.now();
  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: -100, left: 0, right: 0, child: Container(height: 400,
        decoration: BoxDecoration(gradient: RadialGradient(
          colors: [AppColors.accent.withOpacity(0.15), Colors.transparent], radius: 0.7)))),

      SafeArea(bottom: false, child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ── Header ───────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back, ${UserService.firstName}',
                  style: AppText.h2.copyWith(color: AppColors.onDark)),
              const SizedBox(height: Sp.xs),
              Text(DateFormat('EEEE, MMM d').format(_now),
                  style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.60))),
            ]),
            GestureDetector(onTap: () {},
              child: Container(width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.glassWhite,
                  border: Border.all(color: AppColors.glassBorder),
                  borderRadius: BorderRadius.circular(Rd.lg)),
                child: Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.notifications_outlined, color: AppColors.accent, size: 24),
                  Positioned(top: 8, right: 8, child: Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.income, shape: BoxShape.circle))),
                ]))),
          ]),
          const SizedBox(height: Sp.xl),

          // ── Balance card (live) ───────────────────────
          _LiveBalanceCard(now: _now),
          const SizedBox(height: Sp.xl),

          // ── Income / Expense mini cards ────────────────
          _LiveIncomeExpenseRow(now: _now),
          const SizedBox(height: Sp.xl),

          // ── Quick Actions ─────────────────────────────
          Text('Quick Actions', style: AppText.h3.copyWith(color: AppColors.onDark)),
          const SizedBox(height: Sp.md),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _quickAction(icon: Icons.add_circle_outline, label: 'Income',
              onTap: () => _push(AddTransactionPage(initialType: TxnType.income))),
            _quickAction(icon: Icons.remove_circle_outline, label: 'Expense',
              onTap: () => _push(AddTransactionPage(initialType: TxnType.expense))),
            _quickAction(icon: Icons.event_note_outlined, label: 'Bill',
              onTap: () => _push(AddTransactionPage(initialType: TxnType.bill))),
            _quickAction(icon: Icons.savings_outlined, label: 'Savings',
              onTap: () => _push(AddTransactionPage(initialType: TxnType.savings))),
          ]),
          const SizedBox(height: Sp.xl),

          // ── Savings Goal (live) ───────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Savings Goal', style: AppText.h3.copyWith(color: AppColors.onDark)),
            GestureDetector(onTap: () => _push(const SavingsPage()),
              child: Text('View all', style: AppText.caption.copyWith(
                color: AppColors.accent, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: Sp.md),
          _LiveSavingsPreview(),
          const SizedBox(height: Sp.xl),

          // ── Budget Status (live) ──────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Budget Status', style: AppText.h3.copyWith(color: AppColors.onDark)),
            GestureDetector(onTap: () => _push(const BudgetPage()),
              child: Text('View all', style: AppText.caption.copyWith(
                color: AppColors.accent, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: Sp.md),
          _LiveBudgetPreview(now: _now),
          const SizedBox(height: Sp.xl),

          // ── Recent Transactions (live) ────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Recent Transactions', style: AppText.h3.copyWith(color: AppColors.onDark)),
            GestureDetector(onTap: () => _push(const TransactionsPage()),
              child: Text('View All', style: AppText.caption.copyWith(
                color: AppColors.accent, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: Sp.md),
          _LiveRecentTransactions(),
          const SizedBox(height: Sp.xl),

          // ── Upcoming Bills (live) ─────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Upcoming Bills', style: AppText.h3.copyWith(color: AppColors.onDark)),
            GestureDetector(onTap: () => _push(const CalendarPage()),
              child: Text('View All', style: AppText.caption.copyWith(
                color: AppColors.accent, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: Sp.md),
          _LiveUpcomingBills(),
        ]),
      )),
    ]);
  }

  Widget _quickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap, child: Column(children: [
      Container(width: 60, height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.accent.withOpacity(0.3), AppColors.accent.withOpacity(0.1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 1.0),
          borderRadius: BorderRadius.circular(Rd.lg)),
        child: Icon(icon, color: AppColors.accent, size: 28)),
      const SizedBox(height: Sp.sm),
      Text(label, style: AppText.caption.copyWith(color: AppColors.onDark.withOpacity(0.70))),
    ]));
  }
}

// ── Live balance card ──────────────────────────────────────────────────────────
class _LiveBalanceCard extends StatelessWidget {
  final DateTime now;
  const _LiveBalanceCard({required this.now});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: DbService.watchTransactions(),
      builder: (ctx, snap) {
        final txns    = snap.data ?? [];
        final income  = txns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
        final expense = txns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
        final balance = income - expense;
        return GlassCard.gold(padding: const EdgeInsets.all(Sp.lg), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total Balance', style: AppText.label.copyWith(color: AppColors.accent.withOpacity(0.80))),
          const SizedBox(height: Sp.md),
          Text('\$${balance.toStringAsFixed(2)}', style: AppText.moneyLarge),
          const SizedBox(height: Sp.md),
          Row(children: [
            _statChip('↑ Income',   '\$${income.toStringAsFixed(0)}',  AppColors.income),
            const SizedBox(width: Sp.md),
            _statChip('↓ Expenses', '\$${expense.toStringAsFixed(0)}', AppColors.expense),
          ]),
        ]));
      });
  }
  Widget _statChip(String label, String val, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.12),
      border: Border.all(color: color.withOpacity(0.22)),
      borderRadius: BorderRadius.circular(Rd.md)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: color.withOpacity(0.75), fontSize: 9, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(val, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    ])));
}

// ── Income / Expense row ───────────────────────────────────────────────────────
class _LiveIncomeExpenseRow extends StatelessWidget {
  final DateTime now;
  const _LiveIncomeExpenseRow({required this.now});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: DbService.watchTransactionsForMonth(now.year, now.month),
      builder: (ctx, snap) {
        final txns    = snap.data ?? [];
        final income  = txns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
        final expense = txns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
        return Row(children: [
          Expanded(child: GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Income', style: AppText.label.copyWith(color: AppColors.income)),
            const SizedBox(height: Sp.md),
            Text('\$${income.toStringAsFixed(0)}', style: AppText.money),
            const SizedBox(height: Sp.sm),
            Text('This month', style: AppText.caption.copyWith(color: AppColors.income)),
          ]))),
          const SizedBox(width: Sp.md),
          Expanded(child: GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Expenses', style: AppText.label.copyWith(color: AppColors.expense)),
            const SizedBox(height: Sp.md),
            Text('\$${expense.toStringAsFixed(0)}', style: AppText.money),
            const SizedBox(height: Sp.sm),
            Text('This month', style: AppText.caption.copyWith(color: AppColors.expense)),
          ]))),
        ]);
      });
  }
}

// ── Savings preview ────────────────────────────────────────────────────────────
class _LiveSavingsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SavingsGoalModel>>(
      stream: DbService.watchGoals(),
      builder: (ctx, snap) {
        final goals = snap.data ?? [];
        if (goals.isEmpty) {
          return GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Row(children: [
            Icon(Icons.savings_outlined, color: AppColors.onDark.withOpacity(0.25), size: 36),
            const SizedBox(width: Sp.md),
            Expanded(child: Text('No savings goals yet. Tap to add one.',
              style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.45), fontSize: 13))),
          ]));
        }
        final g = goals.first;
        return GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Row(children: [
          SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: g.pct, strokeWidth: 7,
              backgroundColor: AppColors.onDark.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.income)),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${(g.pct * 100).toInt()}%',
                style: AppText.h3.copyWith(color: AppColors.income)),
              Text('of goal', style: AppText.caption.copyWith(
                color: AppColors.onDark.withOpacity(0.60))),
            ]),
          ])),
          const SizedBox(width: Sp.lg),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(g.name, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: Sp.sm),
            Text('\$${g.saved.toInt()} / \$${g.target.toInt()}',
              style: AppText.money.copyWith(color: AppColors.accent)),
            const SizedBox(height: Sp.md),
            ClipRRect(borderRadius: BorderRadius.circular(Rd.sm),
              child: LinearProgressIndicator(value: g.pct, minHeight: 4,
                backgroundColor: AppColors.onDark.withOpacity(0.10),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent))),
          ])),
        ]));
      });
  }
}

// ── Budget preview ─────────────────────────────────────────────────────────────
class _LiveBudgetPreview extends StatelessWidget {
  final DateTime now;
  const _LiveBudgetPreview({required this.now});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BudgetModel>>(
      stream: DbService.watchBudgetsForMonth(DbService.monthKey(now)),
      builder: (ctx, budgetSnap) {
        return StreamBuilder<List<TransactionModel>>(
          stream: DbService.watchTransactionsForMonth(now.year, now.month),
          builder: (ctx2, txnSnap) {
            final budgets = (budgetSnap.data ?? []).take(3).toList();
            final txns    = txnSnap.data ?? [];
            final spentMap = <String, double>{};
            for (final t in txns) {
              if (t.isExpense) spentMap[t.category] = (spentMap[t.category] ?? 0) + t.amount;
            }
            if (budgets.isEmpty) {
              return GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Row(children: [
                Icon(Icons.pie_chart_outline_rounded,
                  color: AppColors.onDark.withOpacity(0.25), size: 36),
                const SizedBox(width: Sp.md),
                Expanded(child: Text('No budgets set. Tap to create one.',
                  style: AppText.body.copyWith(
                    color: AppColors.onDark.withOpacity(0.45), fontSize: 13))),
              ]));
            }
            return Column(children: budgets.asMap().entries.map((e) {
              final i = e.key; final b = e.value;
              final spent = spentMap[b.category] ?? 0;
              final pct   = b.limit > 0 ? (spent / b.limit).clamp(0.0, 1.0) : 0.0;
              final color = pct > 0.8 ? AppColors.expense : AppColors.accent;
              return Padding(padding: EdgeInsets.only(bottom: i < budgets.length - 1 ? Sp.md : 0),
                child: GlassCard(padding: const EdgeInsets.all(Sp.md), child: Column(children: [
                  Row(children: [
                    Expanded(child: Text(b.category,
                      style: AppText.body.copyWith(fontWeight: FontWeight.w500))),
                    Text('\$${spent.toInt()} / \$${b.limit.toInt()}',
                      style: AppText.caption.copyWith(
                        color: pct > 0.8 ? AppColors.expense : AppColors.onDark.withOpacity(0.60))),
                  ]),
                  const SizedBox(height: Sp.sm),
                  ClipRRect(borderRadius: BorderRadius.circular(Rd.sm),
                    child: LinearProgressIndicator(value: pct, minHeight: 4,
                      backgroundColor: AppColors.onDark.withOpacity(0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(color))),
                ])));
            }).toList());
          });
      });
  }
}

// ── Recent transactions ────────────────────────────────────────────────────────
class _LiveRecentTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: DbService.watchRecentTransactions(limit: 4),
      builder: (ctx, snap) {
        final txns = snap.data ?? [];
        if (txns.isEmpty) {
          return GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Row(children: [
            Icon(Icons.receipt_long_outlined, color: AppColors.onDark.withOpacity(0.25), size: 36),
            const SizedBox(width: Sp.md),
            Text('No transactions yet', style: AppText.body.copyWith(
              color: AppColors.onDark.withOpacity(0.45), fontSize: 13)),
          ]));
        }
        return Column(children: txns.asMap().entries.map((e) {
          final i = e.key; final t = e.value;
          return Padding(padding: EdgeInsets.only(bottom: i < txns.length - 1 ? Sp.md : 0),
            child: GlassCard(padding: const EdgeInsets.all(Sp.md), child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: t.typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Rd.md)),
                child: Icon(Icons.receipt_long_outlined, color: t.typeColor, size: 22)),
              const SizedBox(width: Sp.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: Sp.xs),
                Text(DateFormat('MMM d').format(t.date),
                  style: AppText.caption.copyWith(color: AppColors.onDark.withOpacity(0.60))),
              ])),
              Text(t.formattedAmount, style: AppText.body.copyWith(
                color: t.isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w600)),
            ])));
        }).toList());
      });
  }
}

// ── Upcoming bills ─────────────────────────────────────────────────────────────
class _LiveUpcomingBills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BillModel>>(
      stream: DbService.watchUpcomingBills(limit: 3),
      builder: (ctx, snap) {
        final bills = snap.data ?? [];
        if (bills.isEmpty) {
          return GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Row(children: [
            Icon(Icons.calendar_month_outlined, color: AppColors.onDark.withOpacity(0.25), size: 36),
            const SizedBox(width: Sp.md),
            Text('No upcoming bills', style: AppText.body.copyWith(
              color: AppColors.onDark.withOpacity(0.45), fontSize: 13)),
          ]));
        }
        return Column(children: bills.asMap().entries.map((e) {
          final i = e.key; final b = e.value;
          final isUrgent = b.daysUntilDue <= 3;
          return Padding(padding: EdgeInsets.only(bottom: i < bills.length - 1 ? Sp.md : 0),
            child: GlassCard(padding: const EdgeInsets.all(Sp.md), child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (isUrgent ? AppColors.expense : AppColors.accent).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Rd.md)),
                child: Icon(Icons.receipt_outlined,
                  color: isUrgent ? AppColors.expense : AppColors.accent, size: 22)),
              const SizedBox(width: Sp.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.name, style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: Sp.xs),
                Text(b.dueDateLabel, style: AppText.caption.copyWith(
                  color: isUrgent ? AppColors.expense : AppColors.onDark.withOpacity(0.60),
                  fontWeight: isUrgent ? FontWeight.w600 : null)),
              ])),
              Text(b.formattedAmount, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
            ])));
        }).toList());
      });
  }
}