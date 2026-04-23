import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});
  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final DateTime _now = DateTime.now();
  String get _monthKey => DbService.monthKey(_now);

  final _categoryMeta = {
    'Food & Dining':    (Icons.restaurant_outlined,   AppColors.expense),
    'Transport':        (Icons.directions_car_outlined,const Color(0xFF4ECDC4)),
    'Entertainment':    (Icons.movie_outlined,         const Color(0xFFA29BFE)),
    'Bills & Utilities':(Icons.flash_on_outlined,      AppColors.warning),
    'Shopping':         (Icons.shopping_bag_outlined,  const Color(0xFFFF7675)),
    'Health':           (Icons.health_and_safety_outlined, const Color(0xFF00B894)),
    'Education':        (Icons.school_outlined,        const Color(0xFF4A9EE8)),
    'Travel':           (Icons.flight_outlined,        AppColors.accent),
    'Other':            (Icons.category_outlined,      AppColors.onDark.withValues(alpha: 0.5)),
  };

  void _showEditBudget(BuildContext ctx, BudgetModel? existing, String category) {
    final ctrl = TextEditingController(
        text: existing != null ? existing.limit.toStringAsFixed(0) : '');
    showModalBottomSheet(context: ctx,
      backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(padding: const EdgeInsets.all(Sp.lg),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.97),
            borderRadius: BorderRadius.circular(Rd.xxl),
            border: Border.all(color: AppColors.glassBorder)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.onDark.withOpacity(0.18), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Sp.lg),
            Row(children: [
              Text('Set budget for $category', style: AppText.h3),
              const Spacer(),
              if (existing != null) GestureDetector(
                onTap: () { DbService.deleteBudget(existing.id); Navigator.pop(ctx); },
                child: Text('Remove', style: TextStyle(
                  color: AppColors.expense, fontSize: 12, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: Sp.lg),
            GlassCard(padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
              child: Row(children: [
                Icon(Icons.attach_money_rounded, color: AppColors.accent.withOpacity(0.65), size: 20),
                const SizedBox(width: 8),
                Text('\$', style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.50))),
                const SizedBox(width: 4),
                Expanded(child: TextField(controller: ctrl, autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppText.body.copyWith(fontSize: 14),
                  decoration: InputDecoration(hintText: 'Monthly limit',
                    hintStyle: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.28), fontSize: 14),
                    border: InputBorder.none, contentPadding: EdgeInsets.zero))),
              ])),
            const SizedBox(height: Sp.xl),
            GestureDetector(
              onTap: () async {
                final limit = double.tryParse(ctrl.text) ?? 0;
                if (limit <= 0) return;
                if (existing != null) {
                  await DbService.updateBudget(existing.copyWith(limit: limit));
                } else {
                  await DbService.addBudget(BudgetModel(
                    id: '', category: category, limit: limit, month: _monthKey));
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Container(height: 52, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(Rd.lg), boxShadow: AppShadows.goldGlow),
                child: const Center(child: Text('Save Budget',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark))))),
          ]))));
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];

    return StreamBuilder<List<BudgetModel>>(
      stream: DbService.watchBudgetsForMonth(_monthKey),
      builder: (ctx, budgetSnap) {
        final budgets = budgetSnap.data ?? [];
        return StreamBuilder<List<TransactionModel>>(
          stream: DbService.watchTransactionsForMonth(_now.year, _now.month),
          builder: (ctx2, txnSnap) {
            final txns = txnSnap.data ?? [];
            // Compute spending per category
            final spentMap = <String, double>{};
            for (final t in txns) {
              if (t.isExpense) spentMap[t.category] = (spentMap[t.category] ?? 0) + t.amount;
            }
            final totalLimit = budgets.fold(0.0, (s, b) => s + b.limit);
            final totalSpent = spentMap.values.fold(0.0, (s, v) => s + v);
            final overBudget = budgets.where((b) => (spentMap[b.category] ?? 0) > b.limit).toList();

            return Stack(children: [
              Positioned(top: -60, left: 0, right: 0, child: Container(height: 300,
                decoration: BoxDecoration(gradient: RadialGradient(
                  colors: [AppColors.accent.withOpacity(0.10), Colors.transparent], radius: 0.65)))),

              SafeArea(bottom: false, child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Budget', style: AppText.h2.copyWith(color: AppColors.onDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.14),
                        border: Border.all(color: AppColors.accent.withOpacity(0.30)),
                        borderRadius: Rd.chip),
                      child: Text('${monthNames[_now.month - 1]} ${_now.year}',
                        style: AppText.caption.copyWith(color: AppColors.accent,
                          fontSize: 11, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: Sp.md),

                  // Overview card
                  if (totalLimit > 0)
                    GlassCard(padding: const EdgeInsets.all(Sp.md), child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('TOTAL SPENT', style: AppText.caption.copyWith(
                            letterSpacing: 0.8, fontSize: 10)),
                          const SizedBox(height: 3),
                          Text('\$${totalSpent.toInt()}', style: AppText.moneyLarge),
                          Text('of \$${totalLimit.toInt()} budget',
                            style: AppText.caption.copyWith(fontSize: 11)),
                        ]),
                        Text('${totalLimit > 0 ? ((totalSpent / totalLimit) * 100).toInt() : 0}%',
                          style: TextStyle(
                            color: totalSpent > totalLimit ? AppColors.expense : AppColors.income,
                            fontSize: 24, fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: Sp.md),
                      ClipRRect(borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0,
                          minHeight: 8,
                          backgroundColor: AppColors.onDark.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            totalSpent > totalLimit ? AppColors.expense : AppColors.income))),
                      const SizedBox(height: 6),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$0', style: AppText.caption.copyWith(fontSize: 10)),
                        Text('\$${(totalLimit - totalSpent).abs().toInt()} ${totalSpent > totalLimit ? 'over' : 'remaining'}',
                          style: AppText.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w600,
                            color: totalSpent > totalLimit ? AppColors.expense : AppColors.income)),
                        Text('\$${totalLimit.toInt()}', style: AppText.caption.copyWith(fontSize: 10)),
                      ]),
                    ])),
                  const SizedBox(height: Sp.md),

                  // Over-budget alert
                  if (overBudget.isNotEmpty)
                    Container(margin: const EdgeInsets.only(bottom: Sp.md),
                      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.10),
                        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(Rd.md)),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          '${overBudget.map((b) => b.category).join(', ')} exceeded budget',
                          style: AppText.caption.copyWith(color: AppColors.warning,
                            fontSize: 11, fontWeight: FontWeight.w600))),
                      ])),

                  // Categories header
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Categories', style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 14)),
                    GestureDetector(
                      onTap: () => _showEditBudget(context, null, 'Food & Dining'),
                      child: Text('+ Add budget', style: AppText.caption.copyWith(
                        color: AppColors.accent, fontSize: 11))),
                  ]),
                  const SizedBox(height: Sp.sm),

                  // Category rows — show all categories that have either a budget or spending
                  ..._buildCategoryRows(ctx, budgets, spentMap),

                  // Empty state
                  if (budgets.isEmpty && spentMap.isEmpty)
                    GlassCard(padding: const EdgeInsets.all(Sp.xl), child: Column(children: [
                      Icon(Icons.pie_chart_outline_rounded,
                        color: AppColors.onDark.withOpacity(0.20), size: 56),
                      const SizedBox(height: Sp.md),
                      Text('No budgets set yet',
                        style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.45))),
                      const SizedBox(height: Sp.sm),
                      Text('Tap a category to set a monthly limit',
                        style: AppText.caption.copyWith(fontSize: 12)),
                    ])),
                ]),
              )),
            ]);
          });
      });
  }

  List<Widget> _buildCategoryRows(BuildContext ctx,
      List<BudgetModel> budgets, Map<String, double> spentMap) {
    // Show union of: categories with a budget + categories with spending
    final all = <String>{
      ...budgets.map((b) => b.category),
      ...spentMap.keys,
    };
    if (all.isEmpty) return [];

    return all.map((cat) {
      final budget = budgets.cast<BudgetModel?>().firstWhere(
          (b) => b?.category == cat, orElse: () => null);
      final spent  = spentMap[cat] ?? 0;
      final limit  = budget?.limit ?? 0;
      final pct    = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
      final isOver = limit > 0 && spent > limit;
      final meta = _categoryMeta[cat] ?? (Icons.category_outlined, AppColors.onDark.withValues(alpha: 0.5));
      final color  = isOver ? AppColors.expense : meta.$2;

      return Padding(padding: const EdgeInsets.only(bottom: Sp.sm),
        child: GestureDetector(
          onTap: () => _showEditBudget(ctx, budget, cat),
          child: GlassCard(padding: const EdgeInsets.all(Sp.md),
            borderRadius: BorderRadius.circular(Rd.md),
            child: Column(children: [
              Row(children: [
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: meta.$2.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(meta.$1, color: meta.$2, size: 18)),
                const SizedBox(width: Sp.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(cat, style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
                  Text('${txnSpentCount(spentMap, cat)} transaction${txnSpentCount(spentMap, cat) == 1 ? '' : 's'}',
                    style: AppText.caption.copyWith(fontSize: 10)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\$${spent.toInt()}', style: TextStyle(
                    color: isOver ? AppColors.expense : AppColors.onDark,
                    fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(limit > 0 ? 'of \$${limit.toInt()}' : 'no limit',
                    style: AppText.caption.copyWith(fontSize: 10)),
                ]),
              ]),
              if (limit > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: pct, minHeight: 5,
                    backgroundColor: AppColors.onDark.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color))),
                const SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(isOver
                    ? '\$${(spent - limit).toInt()} over budget'
                    : '\$${(limit - spent).toInt()} left',
                    style: TextStyle(color: isOver ? AppColors.expense : AppColors.onDark.withOpacity(0.40),
                      fontSize: 10, fontWeight: FontWeight.w500)),
                ]),
              ],
            ]))));
    }).toList();
  }

  int txnSpentCount(Map<String, double> map, String cat) => map.containsKey(cat) ? 1 : 0;
}