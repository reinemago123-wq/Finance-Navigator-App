import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../bills/bill_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int? _selectedDay = DateTime.now().day;

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    _selectedDay  = null;
  });
  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    _selectedDay  = null;
  });

  void _openBill(BillModel bill) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BillDetailPage(bill: bill)));
  }

  void _showAddBill() {
    final newBill = BillModel(
      id: '', name: '', amount: 0, category: 'Utilities',
      frequency: 'Monthly', dueDate: DateTime.now(), isPaid: false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BillDetailPage(bill: newBill, isNew: true)));
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    final monthName = monthNames[_focusedMonth.month - 1];

    return StreamBuilder<List<BillModel>>(
      stream: DbService.watchBillsForMonth(_focusedMonth.year, _focusedMonth.month),
      builder: (ctx, snap) {
        final bills      = snap.data ?? [];
        final billsByDay = <int, List<BillModel>>{};
        for (final b in bills) {
          billsByDay.putIfAbsent(b.dueDate.day, () => []).add(b);
        }
        final selectedBills = _selectedDay != null ? (billsByDay[_selectedDay] ?? []) : <BillModel>[];
        final unpaidCount   = bills.where((b) => !b.isPaid).length;

        return Stack(children: [
          Positioned(top: -60, right: -40, child: Container(width: 260, height: 260,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.expense.withOpacity(0.10), Colors.transparent])))),

          SafeArea(bottom: false, child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Bill Calendar', style: AppText.h2.copyWith(color: AppColors.onDark)),
                  const SizedBox(height: 2),
                  Text('Tap a bill to view or edit',
                    style: AppText.caption.copyWith(fontSize: 11)),
                ]),
                Row(children: [
                  if (unpaidCount > 0) Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.14),
                      border: Border.all(color: AppColors.expense.withOpacity(0.28)),
                      borderRadius: BorderRadius.circular(Rd.full)),
                    child: Text('$unpaidCount unpaid', style: TextStyle(
                      color: AppColors.expense, fontSize: 11, fontWeight: FontWeight.w700))),
                  GestureDetector(onTap: _showAddBill,
                    child: Container(width: 36, height: 36,
                      decoration: BoxDecoration(gradient: AppGradients.accent,
                        borderRadius: BorderRadius.circular(Rd.md), boxShadow: AppShadows.goldGlow),
                      child: const Icon(Icons.add_rounded, color: AppColors.primaryDark, size: 20))),
                ]),
              ]),
              const SizedBox(height: Sp.lg),

              // Calendar
              GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(onTap: _prevMonth,
                    child: Container(width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.glassWhite,
                        border: Border.all(color: AppColors.glassBorder),
                        borderRadius: BorderRadius.circular(Rd.sm)),
                      child: const Icon(Icons.chevron_left, color: AppColors.onDark, size: 18))),
                  Text('$monthName ${_focusedMonth.year}',
                    style: AppText.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                  GestureDetector(onTap: _nextMonth,
                    child: Container(width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.glassWhite,
                        border: Border.all(color: AppColors.glassBorder),
                        borderRadius: BorderRadius.circular(Rd.sm)),
                      child: const Icon(Icons.chevron_right, color: AppColors.onDark, size: 18))),
                ]),
                const SizedBox(height: Sp.lg),
                Row(children: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'].map((d) =>
                  Expanded(child: Center(child: Text(d, style: AppText.caption.copyWith(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.onDark.withOpacity(0.40)))))).toList()),
                const SizedBox(height: Sp.sm),
                _buildGrid(billsByDay),
                const SizedBox(height: Sp.md),
                Row(children: [
                  _LegendDot(color: AppColors.expense, label: 'Unpaid'),
                  const SizedBox(width: Sp.lg),
                  _LegendDot(color: AppColors.income, label: 'Paid'),
                ]),
              ])),
              const SizedBox(height: Sp.lg),

              // Selected day bills
              if (_selectedDay != null && selectedBills.isNotEmpty) ...[
                Row(children: [
                  Container(width: 4, height: 18,
                    decoration: BoxDecoration(color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text('Bills on ${_selectedDay!} $monthName',
                    style: AppText.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
                const SizedBox(height: Sp.md),
                ...selectedBills.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: Sp.md),
                  child: _BillTile(bill: b, onTap: () => _openBill(b)))),
                const SizedBox(height: Sp.lg),
              ],

              // All bills this month
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('All Bills This Month',
                  style: AppText.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${bills.length} total',
                  style: AppText.caption.copyWith(fontSize: 11)),
              ]),
              const SizedBox(height: Sp.md),

              if (snap.connectionState == ConnectionState.waiting)
                const Center(child: Padding(padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.accent)))
              else if (bills.isEmpty)
                GlassCard(padding: const EdgeInsets.all(Sp.xl),
                  child: Column(children: [
                    Icon(Icons.calendar_month_outlined,
                      color: AppColors.onDark.withOpacity(0.20), size: 48),
                    const SizedBox(height: Sp.md),
                    Text('No bills this month',
                      style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.45))),
                    const SizedBox(height: Sp.sm),
                    Text('Tap + to add a bill',
                      style: AppText.caption.copyWith(fontSize: 12)),
                  ]))
              else
                ...bills.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: Sp.md),
                  child: _BillTile(bill: b, onTap: () => _openBill(b)))),
            ]),
          )),
        ]);
      },
    );
  }

  Widget _buildGrid(Map<int, List<BillModel>> billsByDay) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
    final rows = ((firstWeekday + daysInMonth) / 7).ceil();
    final now  = DateTime.now();

    return Column(children: List.generate(rows, (row) => Row(
      children: List.generate(7, (col) {
        final idx = row * 7 + col;
        final day = idx - firstWeekday + 1;
        if (day < 1 || day > daysInMonth) {
          return const Expanded(child: SizedBox(height: 36));
        }
        final isToday    = _focusedMonth.year == now.year && _focusedMonth.month == now.month && day == now.day;
        final isSelected = day == _selectedDay;
        final dayBills   = billsByDay[day] ?? [];
        final hasUnpaid  = dayBills.any((b) => !b.isPaid);
        final hasPaid    = dayBills.any((b) => b.isPaid);

        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _selectedDay = day),
          child: Container(height: 36, margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isToday ? AppColors.accent
                  : isSelected ? AppColors.accent.withOpacity(0.20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected && !isToday
                  ? Border.all(color: AppColors.accent.withOpacity(0.50), width: 1)
                  : null),
            child: Stack(alignment: Alignment.center, children: [
              Text('$day', style: TextStyle(
                fontSize: 12,
                fontWeight: (isToday || isSelected) ? FontWeight.w700 : FontWeight.w400,
                color: isToday ? AppColors.primaryDark
                    : isSelected ? AppColors.accent
                    : AppColors.onDark.withOpacity(0.65))),
              if (dayBills.isNotEmpty) Positioned(bottom: 3, child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasUnpaid) Container(width: 4, height: 4,
                    decoration: const BoxDecoration(color: AppColors.expense, shape: BoxShape.circle)),
                  if (hasUnpaid && hasPaid) const SizedBox(width: 2),
                  if (hasPaid) Container(width: 4, height: 4,
                    decoration: const BoxDecoration(color: AppColors.income, shape: BoxShape.circle)),
                ])),
            ])),
        ));
      }))));
  }
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: AppText.caption.copyWith(fontSize: 11)),
  ]);
}

class _BillTile extends StatelessWidget {
  final BillModel bill; final VoidCallback onTap;
  const _BillTile({required this.bill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: GlassCard(padding: const EdgeInsets.all(Sp.md), child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: bill.statusColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(Rd.md)),
          child: Icon(Icons.receipt_outlined, color: bill.statusColor, size: 22)),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bill.name, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(bill.dueDateLabel, style: AppText.caption.copyWith(
            color: bill.statusColor, fontSize: 11,
            fontWeight: (!bill.isPaid && bill.daysUntilDue <= 3) ? FontWeight.w600 : null)),
        ])),
        const SizedBox(width: Sp.sm),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(bill.formattedAmount, style: AppText.body.copyWith(fontWeight: FontWeight.w700,
            color: bill.isPaid ? AppColors.onDark.withOpacity(0.45) : AppColors.onDark)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => DbService.markBillPaid(bill.id, !bill.isPaid),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: (bill.isPaid ? AppColors.income : AppColors.expense).withOpacity(0.14),
                border: Border.all(color: (bill.isPaid ? AppColors.income : AppColors.expense).withOpacity(0.30)),
                borderRadius: BorderRadius.circular(6)),
              child: Text(bill.isPaid ? 'Paid ✓' : 'Mark Paid',
                style: TextStyle(color: bill.isPaid ? AppColors.income : AppColors.expense,
                  fontSize: 10, fontWeight: FontWeight.w700)))),
        ]),
        const SizedBox(width: 6),
        Icon(Icons.chevron_right_rounded, color: AppColors.onDark.withOpacity(0.25), size: 18),
      ])));
  }
}