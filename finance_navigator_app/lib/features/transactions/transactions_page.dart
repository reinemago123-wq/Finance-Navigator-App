import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../add_transaction/add_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _filter  = 'All';
  String _search  = '';
  final _filters  = ['All', 'Income', 'Expense'];
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<TransactionModel> _applyFilter(List<TransactionModel> all) {
    var list = all;
    if (_filter == 'Income')  list = list.where((t) => t.isIncome).toList();
    if (_filter == 'Expense') list = list.where((t) => t.isExpense).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((t) =>
        t.title.toLowerCase().contains(q) ||
        t.category.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Map<String, List<TransactionModel>> _group(List<TransactionModel> list) {
    final now = DateTime.now();
    final map = <String, List<TransactionModel>>{};
    for (final t in list) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(t.date.year, t.date.month, t.date.day)).inDays;
      final key = diff == 0 ? 'TODAY'
          : diff == 1 ? 'YESTERDAY'
          : DateFormat('MMM d, yyyy').format(t.date).toUpperCase();
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: -60, left: 0, right: 0, child: Container(
        height: 280,
        decoration: BoxDecoration(gradient: RadialGradient(
          colors: [AppColors.income.withOpacity(0.10), Colors.transparent], radius: 0.65)))),

      SafeArea(bottom: false, child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Transactions', style: AppText.h2),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTransactionPage())),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(gradient: AppGradients.accent,
                    borderRadius: BorderRadius.circular(Rd.md), boxShadow: AppShadows.goldGlow),
                  child: const Icon(Icons.add_rounded, color: AppColors.primaryDark, size: 20))),
            ]),
            const SizedBox(height: Sp.md),
            GlassCard(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Icon(Icons.search, color: AppColors.onDark.withOpacity(0.35), size: 18),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  style: AppText.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(hintText: 'Search transactions...',
                    hintStyle: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.30), fontSize: 13),
                    border: InputBorder.none, contentPadding: EdgeInsets.zero))),
                if (_search.isNotEmpty) GestureDetector(
                  onTap: () { _searchCtrl.clear(); setState(() => _search = ''); },
                  child: Icon(Icons.close, color: AppColors.onDark.withOpacity(0.40), size: 18)),
              ])),
            const SizedBox(height: Sp.md),
            SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: Row(children: _filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: _filter == f ? AppColors.accent.withOpacity(0.18) : AppColors.glassWhite,
                      border: Border.all(color: _filter == f ? AppColors.accent.withOpacity(0.35) : AppColors.glassBorder),
                      borderRadius: Rd.chip),
                    child: Text(f, style: TextStyle(
                      color: _filter == f ? AppColors.accent : AppColors.onDark.withOpacity(0.45),
                      fontSize: 11, fontWeight: FontWeight.w600)))),
              )).toList())),
          ])),
        const SizedBox(height: Sp.sm),

        Expanded(child: StreamBuilder<List<TransactionModel>>(
          stream: DbService.watchTransactions(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (snap.hasError) {
              return Center(child: Text('Error loading transactions',
                style: AppText.body.copyWith(color: AppColors.expense)));
            }
            final all     = snap.data ?? [];
            final filtered = _applyFilter(all);
            if (filtered.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_outlined, color: AppColors.onDark.withOpacity(0.20), size: 56),
                const SizedBox(height: Sp.md),
                Text(_search.isNotEmpty ? 'No results found' : 'No transactions yet',
                  style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.45))),
                const SizedBox(height: Sp.sm),
                Text('Tap + to add your first transaction',
                  style: AppText.caption.copyWith(fontSize: 12)),
              ]));
            }
            final grouped = _group(filtered);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(Sp.md, 0, Sp.md, 120),
              itemCount: grouped.length,
              itemBuilder: (ctx, i) {
                final entry = grouped.entries.elementAt(i);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(entry.key, style: AppText.caption.copyWith(
                        letterSpacing: 0.8, fontSize: 10,
                        color: AppColors.onDark.withOpacity(0.40)))),
                  ...entry.value.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TxnCard(txn: t))),
                ]);
              });
          })),
      ])),
    ]);
  }
}

class _TxnCard extends StatelessWidget {
  final TransactionModel txn;
  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AddTransactionPage(existing: txn))),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(Rd.md),
        child: Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: txn.typeColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(11)),
            child: Icon(_categoryIcon(txn.category), color: txn.typeColor, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(txn.title, style: AppText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(txn.category, style: AppText.caption.copyWith(fontSize: 10)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(txn.formattedAmount, style: TextStyle(
              color: txn.isIncome ? AppColors.income : AppColors.expense,
              fontSize: 13, fontWeight: FontWeight.w700)),
            Text(DateFormat('h:mm a').format(txn.date),
              style: AppText.caption.copyWith(fontSize: 9)),
          ]),
        ]),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Food & Dining': return Icons.restaurant_outlined;
      case 'Transport':     return Icons.directions_car_outlined;
      case 'Entertainment': return Icons.movie_outlined;
      case 'Bills & Utilities': return Icons.flash_on_outlined;
      case 'Shopping':      return Icons.shopping_bag_outlined;
      case 'Health':        return Icons.health_and_safety_outlined;
      case 'Education':     return Icons.school_outlined;
      case 'Travel':        return Icons.flight_outlined;
      case 'Salary':        return Icons.work_outline;
      case 'Freelance':     return Icons.laptop_outlined;
      case 'Investments':   return Icons.trending_up_rounded;
      case 'Gift':          return Icons.card_giftcard_outlined;
      default:              return Icons.receipt_long_outlined;
    }
  }
}