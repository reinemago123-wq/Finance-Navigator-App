import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../services/user_service.dart';
import '../../services/db_service.dart';
import '../../models/models.dart';
import '../add_transaction/add_transaction_page.dart';
import '../main_shell.dart';
import '../bills/bill_detail_page.dart';
import '../savings/savings_page.dart';
import '../budget/budget_page.dart';
import '../transactions/transactions_page.dart';
import '../calendar/calendar_page.dart';
import '../../widgets/glass_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Background orb
      Positioned(top: -100, left: 0, right: 0, child: Container(height: 400,
        decoration: BoxDecoration(gradient: RadialGradient(
          colors: [AppColors.accent.withOpacity(0.15), Colors.transparent],
          radius: 0.7)))),

      SafeArea(bottom: false, child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ── Header ──────────────────────────────────────
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

          // ── Live balance card ────────────────────────────
          _LiveBalanceCard(now: _now),
          const SizedBox(height: Sp.xl),

          // ── Income / Expense row ─────────────────────────
          _LiveIncomeExpenseRow(now: _now),
          const SizedBox(height: Sp.xl),

          // ── Quick Actions ────────────────────────────────
          Text('Quick Actions', style: AppText.h3.copyWith(color: AppColors.onDark)),
          const SizedBox(height: Sp.md),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _QuickBtn(icon: Icons.add_circle_outline, label: 'Income',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddTransactionPage(initialType: TxnType.income)))),
            _QuickBtn(icon: Icons.remove_circle_outline, label: 'Expense',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddTransactionPage(initialType: TxnType.expense)))),
            _QuickBtn(icon: Icons.event_note_outlined, label: 'Bill',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddTransactionPage(initialType: TxnType.bill)))),
            // ← Savings Goals shortcut goes directly to the Savings tab
            _QuickBtn(icon: Icons.savings_outlined, label: 'Savings',
              onTap: () => MainShell.switchTab(AppTab.profile + 0),
              // Savings is not a tab — open via nav
              onTapOverride: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SavingsPage()))),
          ]),
          const SizedBox(height: Sp.xl),

          // ── Savings Goals card ────────────────────────────
          _SectionHeader(
            title: 'Savings Goals',
            actionLabel: 'View all',
            // Tapping "View all" stays in the app shell — no new page push
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavingsPage())),
          ),
          const SizedBox(height: Sp.md),
          _LiveSavingsPreview(),
          const SizedBox(height: Sp.xl),

          // ── Budget Status ─────────────────────────────────
          _SectionHeader(
            title: 'Budget Status',
            actionLabel: 'View all',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => Scaffold(
                backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                body: const BudgetPage()))),
          ),
          const SizedBox(height: Sp.md),
          _LiveBudgetPreview(now: _now),
          const SizedBox(height: Sp.xl),

          // ── Recent Transactions ───────────────────────────
          _SectionHeader(
            title: 'Recent Transactions',
            actionLabel: 'View All',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => Scaffold(
                backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                body: const TransactionsPage()))),
          ),
          const SizedBox(height: Sp.md),
          _LiveRecentTransactions(),
          const SizedBox(height: Sp.xl),

          // ── Upcoming Bills ────────────────────────────────
          _SectionHeader(
            title: 'Upcoming Bills',
            actionLabel: 'View All',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => Scaffold(
                backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                body: const CalendarPage()))),
          ),
          const SizedBox(height: Sp.md),
          _LiveUpcomingBills(),
        ]),
      )),
    ]);
  }
}

// ── Reusable section header ────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, actionLabel;
  final VoidCallback onAction;
  const _SectionHeader({required this.title, required this.actionLabel, required this.onAction});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: AppText.h3.copyWith(color: AppColors.onDark)),
      GestureDetector(onTap: onAction, child: Text(actionLabel,
        style: AppText.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600))),
    ]);
}

// ── Quick action button ────────────────────────────────────────────────────────
class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onTapOverride;
  const _QuickBtn({required this.icon, required this.label, this.onTap, this.onTapOverride});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTapOverride ?? onTap,
    child: Column(children: [
      Container(width: 60, height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent.withOpacity(0.3), AppColors.accent.withOpacity(0.1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 1.0),
          borderRadius: BorderRadius.circular(Rd.lg)),
        child: Icon(icon, color: AppColors.accent, size: 28)),
      const SizedBox(height: Sp.sm),
      Text(label, style: AppText.caption.copyWith(color: AppColors.onDark.withOpacity(0.70))),
    ]));
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
        return GlassCard.gold(padding: const EdgeInsets.all(Sp.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total Balance', style: AppText.label.copyWith(color: AppColors.accent.withOpacity(0.80))),
          const SizedBox(height: Sp.md),
          Text('\$${balance.toStringAsFixed(2)}', style: AppText.moneyLarge),
          const SizedBox(height: Sp.md),
          Row(children: [
            _chip('↑ Income',   '\$${income.toStringAsFixed(0)}',  AppColors.income),
            const SizedBox(width: Sp.md),
            _chip('↓ Expenses', '\$${expense.toStringAsFixed(0)}', AppColors.expense),
          ]),
        ]));
      });
  }
  Widget _chip(String label, String val, Color color) => Expanded(child: Container(
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
          Expanded(child: GlassCard(padding: const EdgeInsets.all(Sp.lg),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Income', style: AppText.label.copyWith(color: AppColors.income)),
            const SizedBox(height: Sp.md),
            Text('\$${income.toStringAsFixed(0)}', style: AppText.money),
            const SizedBox(height: Sp.sm),
            Text('This month', style: AppText.caption.copyWith(color: AppColors.income)),
          ]))),
          const SizedBox(width: Sp.md),
          Expanded(child: GlassCard(padding: const EdgeInsets.all(Sp.lg),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        if (snap.connectionState == ConnectionState.waiting) {
          return const GlassCard(child: Center(child: Padding(
            padding: EdgeInsets.all(Sp.lg),
            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))));
        }
        final goals = snap.data ?? [];
        if (goals.isEmpty) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavingsPage())),
            child: GlassCard(padding: const EdgeInsets.all(Sp.lg),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Rd.md)),
                  child: const Icon(Icons.add_rounded, color: AppColors.accent, size: 24)),
                const SizedBox(width: Sp.md),
                Text('Tap to create your first savings goal',
                  style: AppText.body.copyWith(
                    color: AppColors.onDark.withOpacity(0.55), fontSize: 13)),
              ])));
        }
        final g = goals.first;
        return GlassCard(padding: const EdgeInsets.all(Sp.lg),
          child: Row(children: [
          SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: g.pct, strokeWidth: 7,
              backgroundColor: AppColors.onDark.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(g.color)),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${(g.pct * 100).toInt()}%',
                style: AppText.h3.copyWith(color: g.color)),
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
                valueColor: AlwaysStoppedAnimation<Color>(g.color))),
            const SizedBox(height: 4),
            Text('${goals.length} goal${goals.length == 1 ? '' : 's'} · \$${goals.fold(0.0, (s, x) => s + x.saved).toInt()} total saved',
              style: AppText.caption.copyWith(fontSize: 10)),
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
      builder: (ctx, budgetSnap) => StreamBuilder<List<TransactionModel>>(
        stream: DbService.watchTransactionsForMonth(now.year, now.month),
        builder: (ctx2, txnSnap) {
          final budgets  = (budgetSnap.data ?? []).take(3).toList();
          final spentMap = <String, double>{};
          for (final t in txnSnap.data ?? []) {
            if (t.isExpense) spentMap[t.category] = (spentMap[t.category] ?? 0) + t.amount;
          }
          if (budgets.isEmpty) {
            return GlassCard(padding: const EdgeInsets.all(Sp.lg),
              child: Row(children: [
              Icon(Icons.pie_chart_outline_rounded,
                color: AppColors.onDark.withOpacity(0.25), size: 36),
              const SizedBox(width: Sp.md),
              Expanded(child: Text('No budgets set yet.',
                style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.45), fontSize: 13))),
            ]));
          }
          return Column(children: List.generate(budgets.length, (i) {
            final b     = budgets[i];
            final spent = spentMap[b.category] ?? 0;
            final pct   = b.limit > 0 ? (spent / b.limit).clamp(0.0, 1.0) : 0.0;
            final color = pct > 0.8 ? AppColors.expense : AppColors.accent;
            return Padding(padding: EdgeInsets.only(bottom: i < budgets.length - 1 ? Sp.md : 0),
              child: GlassCard(padding: const EdgeInsets.all(Sp.md),
                child: Column(children: [
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
          }));
        }));
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
          return GlassCard(padding: const EdgeInsets.all(Sp.lg),
            child: Row(children: [
            Icon(Icons.receipt_long_outlined, color: AppColors.onDark.withOpacity(0.25), size: 36),
            const SizedBox(width: Sp.md),
            Text('No transactions yet', style: AppText.body.copyWith(
              color: AppColors.onDark.withOpacity(0.45), fontSize: 13)),
          ]));
        }
        return Column(children: List.generate(txns.length, (i) {
          final t = txns[i];
          return Padding(padding: EdgeInsets.only(bottom: i < txns.length - 1 ? Sp.md : 0),
            child: GlassCard(padding: const EdgeInsets.all(Sp.md),
              child: Row(children: [
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
        }));
      });
  }
}

// ── Upcoming bills (live — no orderBy to avoid Firestore index requirement) ────
class _LiveUpcomingBills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BillModel>>(
      // Watch ALL bills then filter/sort in-app — avoids composite index requirement
      stream: DbService.watchBills(),
      builder: (ctx, snap) {
        final now  = DateTime.now();
        final all  = snap.data ?? [];
        // Filter: unpaid, due in future (or today), sort by soonest
        final upcoming = all
          .where((b) => !b.isPaid)
          .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final bills = upcoming.take(3).toList();

        if (snap.connectionState == ConnectionState.waiting) {
          return const GlassCard(child: Center(child: Padding(
            padding: EdgeInsets.all(Sp.lg),
            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))));
        }
        if (bills.isEmpty) {
          return GlassCard(padding: const EdgeInsets.all(Sp.lg),
            child: Row(children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.income.withOpacity(0.50), size: 36),
            const SizedBox(width: Sp.md),
            Text('No upcoming bills — all clear!', style: AppText.body.copyWith(
              color: AppColors.onDark.withOpacity(0.45), fontSize: 13)),
          ]));
        }
        return Column(children: List.generate(bills.length, (i) {
          final b       = bills[i];
          final isUrgent = b.daysUntilDue >= 0 && b.daysUntilDue <= 3;
          final color   = isUrgent ? AppColors.expense : AppColors.accent;
          return Padding(padding: EdgeInsets.only(bottom: i < bills.length - 1 ? Sp.md : 0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BillDetailPage(bill: b))),
              child: GlassCard(padding: const EdgeInsets.all(Sp.md),
                child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Rd.md)),
                  child: Icon(Icons.receipt_outlined, color: color, size: 22)),
                const SizedBox(width: Sp.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.name, style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: Sp.xs),
                  Text(b.dueDateLabel, style: AppText.caption.copyWith(
                    color: isUrgent ? AppColors.expense : AppColors.onDark.withOpacity(0.60),
                    fontWeight: isUrgent ? FontWeight.w600 : null)),
                ])),
                Text(b.formattedAmount, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
              ]))));
        }));
      });
  }
}