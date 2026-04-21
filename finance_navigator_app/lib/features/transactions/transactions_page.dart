import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Income', 'Expense'];

  final _transactions = [
    _Txn('🛒', 'Grocery Store', 'Food & Dining', 'Today, 2:45 PM', -84.20, AppColors.expense),
    _Txn('🚌', 'Bus Pass', 'Transport', 'Today, 8:15 AM', -2.50, const Color(0xFF4ECDC4)),
    _Txn('💼', 'Monthly Salary', 'Income', 'Yesterday, 9:00 AM', 3000.00, AppColors.income),
    _Txn('🍕', 'Pizza Palace', 'Food & Dining', 'Yesterday, 7:30 PM', -22.00, AppColors.expense),
    _Txn('☕', 'Coffee Shop', 'Food & Dining', 'Apr 18, 9:00 AM', -4.50, const Color(0xFFFF7675)),
    _Txn('🎮', 'Steam Games', 'Entertainment', 'Apr 17, 3:00 PM', -29.99, const Color(0xFFA29BFE)),
    _Txn('💡', 'Electricity', 'Bills', 'Apr 15, 12:00 PM', -145.00, AppColors.warning),
  ];

  List<_Txn> get _filtered {
    if (_filter == 'Income') return _transactions.where((t) => t.amount > 0).toList();
    if (_filter == 'Expense') return _transactions.where((t) => t.amount < 0).toList();
    return _transactions;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_filtered);

    return Stack(children: [
        Positioned(
          top: -60, left: 0, right: 0,
          child: Container(height: 280,
            decoration: BoxDecoration(gradient: RadialGradient(
              colors: [AppColors.income.withOpacity(0.10), Colors.transparent], radius: 0.65))),
        ),
        SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Transactions', style: AppText.h2),
                  GlassCard(
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(Rd.md),
                    child: const Icon(Icons.tune_rounded, color: AppColors.onDark, size: 18),
                  ),
                ]),
                const SizedBox(height: Sp.md),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    Icon(Icons.search, color: AppColors.onDark.withOpacity(0.35), size: 18),
                    const SizedBox(width: 8),
                    Text('Search transactions...', style: AppText.body.copyWith(
                        color: AppColors.onDark.withOpacity(0.30), fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: Sp.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _filters.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: _filter == f ? AppColors.accent.withOpacity(0.18) : AppColors.glassWhite,
                          border: Border.all(color: _filter == f ? AppColors.accent.withOpacity(0.35) : AppColors.glassBorder),
                          borderRadius: Rd.chip,
                        ),
                        child: Text(f, style: TextStyle(
                          color: _filter == f ? AppColors.accent : AppColors.onDark.withOpacity(0.45),
                          fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )).toList()),
                ),
              ]),
            ),
            const SizedBox(height: Sp.sm),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(Sp.md, 0, Sp.md, 120),
                itemCount: grouped.length,
                itemBuilder: (ctx, i) {
                  final entry = grouped.entries.elementAt(i);
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(entry.key,
                          style: AppText.caption.copyWith(letterSpacing: 0.8, fontSize: 10,
                              color: AppColors.onDark.withOpacity(0.40))),
                    ),
                    ...entry.value.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TxnCard(txn: t),
                    )),
                  ]);
                },
              ),
            ),
          ]),
        ),
      ]);
  }

  Map<String, List<_Txn>> _groupByDate(List<_Txn> txns) {
    final map = <String, List<_Txn>>{};
    for (final t in txns) {
      final d = t.date.contains('Today') ? 'TODAY'
          : t.date.contains('Yesterday') ? 'YESTERDAY'
          : t.date.split(',').first.toUpperCase();
      map.putIfAbsent(d, () => []).add(t);
    }
    return map;
  }
}

class _Txn {
  final String icon, label, category, date;
  final double amount;
  final Color color;
  const _Txn(this.icon, this.label, this.category, this.date, this.amount, this.color);
}

class _TxnCard extends StatelessWidget {
  final _Txn txn;
  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.amount > 0;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: BorderRadius.circular(Rd.md),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: txn.color.withOpacity(0.18), borderRadius: BorderRadius.circular(11)),
          child: Center(child: Text(txn.icon, style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(txn.label, style: AppText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(txn.category, style: AppText.caption.copyWith(fontSize: 10)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${isIncome ? '+' : ''}\$${txn.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(color: isIncome ? AppColors.income : AppColors.expense,
                fontSize: 13, fontWeight: FontWeight.w700)),
          Text(txn.date.split(',').last.trim(),
              style: AppText.caption.copyWith(fontSize: 9)),
        ]),
      ]),
    );
  }
}