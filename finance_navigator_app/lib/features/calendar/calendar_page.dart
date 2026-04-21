import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../bills/bill_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime(2026, 4);
  int? _selectedDay = DateTime.now().day;

  // Mutable bill list — supports add / edit / delete
  late List<BillModel> _bills;

  @override
  void initState() {
    super.initState();
    _bills = [
      BillModel(
        id: '1', name: 'Electricity', amount: '\$145.00',
        category: 'Utilities', frequency: 'Monthly',
        dueDate: DateTime(2026, 4, 25), isPaid: false,
        icon: Icons.flash_on_outlined, color: AppColors.expense,
      ),
      BillModel(
        id: '2', name: 'Internet', amount: '\$59.99',
        category: 'Utilities', frequency: 'Monthly',
        dueDate: DateTime(2026, 4, 10), isPaid: true,
        icon: Icons.wifi_outlined, color: const Color(0xFF4ECDC4),
        note: 'Fiber plan',
      ),
      BillModel(
        id: '3', name: 'Netflix', amount: '\$15.99',
        category: 'Entertainment', frequency: 'Monthly',
        dueDate: DateTime(2026, 4, 5), isPaid: true,
        icon: Icons.tv_outlined, color: const Color(0xFFA29BFE),
      ),
      BillModel(
        id: '4', name: 'Rent', amount: '\$1,200.00',
        category: 'Housing', frequency: 'Monthly',
        dueDate: DateTime(2026, 4, 30), isPaid: false,
        icon: Icons.home_outlined, color: AppColors.warning,
      ),
      BillModel(
        id: '5', name: 'Gym Membership', amount: '\$49.99',
        category: 'Health', frequency: 'Monthly',
        dueDate: DateTime(2026, 4, 15), isPaid: false,
        icon: Icons.fitness_center_outlined, color: const Color(0xFF00B894),
      ),
    ];
  }

  // Bills due on the focused month, keyed by day
  Map<int, List<BillModel>> get _billsByDay {
    final map = <int, List<BillModel>>{};
    for (final b in _bills) {
      if (b.dueDate.year == _focusedMonth.year &&
          b.dueDate.month == _focusedMonth.month) {
        map.putIfAbsent(b.dueDate.day, () => []).add(b);
      }
    }
    return map;
  }

  List<BillModel> get _selectedBills =>
      _selectedDay != null ? (_billsByDay[_selectedDay] ?? []) : [];

  int get _unpaidCount => _bills.where((b) => !b.isPaid).length;

  void _openBill(BillModel bill) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BillDetailPage(
        bill: bill,
        onUpdated: (updated) {
          setState(() {
            final i = _bills.indexWhere((b) => b.id == updated.id);
            if (i != -1) _bills[i] = updated;
          });
        },
        onDeleted: () {
          setState(() => _bills.removeWhere((b) => b.id == bill.id));
        },
      ),
    ));
  }

  void _showAddBill() {
    // Reuse BillDetailPage in add mode with a blank model
    final newBill = BillModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '', amount: '', category: 'Utilities',
      frequency: 'Monthly', dueDate: DateTime.now(),
      isPaid: false, icon: Icons.receipt_long_outlined, color: AppColors.accent,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BillDetailPage(
        bill: newBill,
        onUpdated: (b) {
          if (b.name.isNotEmpty) setState(() => _bills.add(b));
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    final monthName = monthNames[_focusedMonth.month - 1];

    return Stack(children: [
        Positioned(
          top: -60, right: -40,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.expense.withOpacity(0.10), Colors.transparent]),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Header ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bill Calendar',
                        style: AppText.h2.copyWith(color: AppColors.onDark)),
                    const SizedBox(height: 2),
                    Text('Tap a bill to view or edit',
                        style: AppText.caption.copyWith(fontSize: 11)),
                  ]),
                  Row(children: [
                    if (_unpaidCount > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withOpacity(0.14),
                          border: Border.all(color: AppColors.expense.withOpacity(0.28)),
                          borderRadius: BorderRadius.circular(Rd.full),
                        ),
                        child: Text('$_unpaidCount unpaid',
                            style: TextStyle(color: AppColors.expense,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    GestureDetector(
                      onTap: _showAddBill,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: AppGradients.accent,
                          borderRadius: BorderRadius.circular(Rd.md),
                          boxShadow: AppShadows.goldGlow,
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: AppColors.primaryDark, size: 20),
                      ),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: Sp.lg),

              // ── Calendar card ────────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(Sp.lg),
                child: Column(children: [
                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month - 1);
                          _selectedDay = null;
                        }),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            border: Border.all(color: AppColors.glassBorder),
                            borderRadius: BorderRadius.circular(Rd.sm),
                          ),
                          child: const Icon(Icons.chevron_left,
                              color: AppColors.onDark, size: 18),
                        ),
                      ),
                      Text('$monthName ${_focusedMonth.year}',
                          style: AppText.body.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      GestureDetector(
                        onTap: () => setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month + 1);
                          _selectedDay = null;
                        }),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            border: Border.all(color: AppColors.glassBorder),
                            borderRadius: BorderRadius.circular(Rd.sm),
                          ),
                          child: const Icon(Icons.chevron_right,
                              color: AppColors.onDark, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.lg),

                  // Day-of-week headers
                  Row(
                    children: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
                        .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: AppText.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onDark.withOpacity(0.40))),
                          ),
                        ))
                        .toList(),
                  ),
                  const SizedBox(height: Sp.sm),

                  _buildGrid(),

                  const SizedBox(height: Sp.md),
                  // Legend
                  Row(children: [
                    _LegendDot(color: AppColors.expense, label: 'Unpaid'),
                    const SizedBox(width: Sp.lg),
                    _LegendDot(color: AppColors.income, label: 'Paid'),
                  ]),
                ]),
              ),
              const SizedBox(height: Sp.lg),

              // ── Selected-day bills ────────────────────────
              if (_selectedDay != null && _selectedBills.isNotEmpty) ...[
                Row(children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Bills on ${_selectedDay!} $monthName',
                      style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
                const SizedBox(height: Sp.md),
                ..._selectedBills.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: Sp.md),
                  child: _BillTile(
                    bill: b,
                    onTap: () => _openBill(b),
                    onTogglePaid: () => setState(() {
                      final i = _bills.indexWhere((x) => x.id == b.id);
                      if (i != -1) {
                        _bills[i] = _bills[i].copyWith(isPaid: !_bills[i].isPaid);
                      }
                    }),
                  ),
                )),
                const SizedBox(height: Sp.lg),
              ],

              // ── All bills this month ──────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All Bills This Month',
                      style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text('${_bills.length} total',
                      style: AppText.caption.copyWith(fontSize: 11)),
                ],
              ),
              const SizedBox(height: Sp.md),
              ..._bills.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: Sp.md),
                child: _BillTile(
                  bill: b,
                  onTap: () => _openBill(b),
                  onTogglePaid: () => setState(() {
                    final i = _bills.indexWhere((x) => x.id == b.id);
                    if (i != -1) {
                      _bills[i] = _bills[i].copyWith(isPaid: !_bills[i].isPaid);
                    }
                  }),
                ),
              )),
            ]),
          ),
        ),
      ]);
  }

  Widget _buildGrid() {
    final billsByDay = _billsByDay;
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
    final cells = firstWeekday + daysInMonth;
    final rows  = (cells / 7).ceil();
    final now   = DateTime.now();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final idx = row * 7 + col;
            final day = idx - firstWeekday + 1;
            if (day < 1 || day > daysInMonth) {
              return const Expanded(child: SizedBox(height: 36));
            }

            final isToday = _focusedMonth.year == now.year &&
                _focusedMonth.month == now.month &&
                day == now.day;
            final isSelected = day == _selectedDay;
            final dayBills   = billsByDay[day] ?? [];
            final hasUnpaid  = dayBills.any((b) => !b.isPaid);
            final hasPaid    = dayBills.any((b) => b.isPaid);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  height: 36,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.accent
                        : isSelected
                            ? AppColors.accent.withOpacity(0.20)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected && !isToday
                        ? Border.all(
                            color: AppColors.accent.withOpacity(0.50), width: 1)
                        : null,
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (isToday || isSelected)
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isToday
                            ? AppColors.primaryDark
                            : isSelected
                                ? AppColors.accent
                                : AppColors.onDark.withOpacity(0.65),
                      ),
                    ),
                    if (dayBills.isNotEmpty)
                      Positioned(
                        bottom: 3,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasUnpaid)
                              Container(width: 4, height: 4,
                                  decoration: BoxDecoration(
                                      color: AppColors.expense,
                                      shape: BoxShape.circle)),
                            if (hasUnpaid && hasPaid) const SizedBox(width: 2),
                            if (hasPaid)
                              Container(width: 4, height: 4,
                                  decoration: BoxDecoration(
                                      color: AppColors.income,
                                      shape: BoxShape.circle)),
                          ],
                        ),
                      ),
                  ]),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ── Legend dot ────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: AppText.caption.copyWith(fontSize: 11)),
    ]);
  }
}

// ── Bill tile ─────────────────────────────────────────────────────────────────
class _BillTile extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onTap;
  final VoidCallback onTogglePaid;
  const _BillTile({required this.bill, required this.onTap, required this.onTogglePaid});

  @override
  Widget build(BuildContext context) {
    final urgent = !bill.isPaid && bill.daysUntilDue >= 0 && bill.daysUntilDue <= 3;
    final overdue = !bill.isPaid && bill.daysUntilDue < 0;
    final statusColor = bill.isPaid ? AppColors.income
        : overdue ? AppColors.expense
        : urgent  ? AppColors.warning
        : AppColors.onDark.withOpacity(0.40);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(Sp.md),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: bill.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(Rd.md),
            ),
            child: Icon(bill.icon, color: bill.color, size: 22),
          ),
          const SizedBox(width: Sp.md),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bill.name,
                  style: AppText.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: bill.isPaid
                          ? AppColors.onDark.withOpacity(0.50)
                          : AppColors.onDark)),
              const SizedBox(height: 3),
              Text(bill.dueDateLabel,
                  style: AppText.caption.copyWith(
                      color: statusColor, fontSize: 11,
                      fontWeight: (urgent || overdue) ? FontWeight.w600 : null)),
            ],
          )),
          const SizedBox(width: Sp.sm),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(bill.amount,
                style: AppText.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: bill.isPaid
                        ? AppColors.onDark.withOpacity(0.45)
                        : AppColors.onDark)),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: onTogglePaid,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: (bill.isPaid ? AppColors.income : AppColors.expense)
                      .withOpacity(0.14),
                  border: Border.all(
                      color: (bill.isPaid ? AppColors.income : AppColors.expense)
                          .withOpacity(0.30)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(bill.isPaid ? 'Paid ✓' : 'Mark Paid',
                    style: TextStyle(
                      color: bill.isPaid ? AppColors.income : AppColors.expense,
                      fontSize: 10, fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ]),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.onDark.withOpacity(0.25), size: 18),
        ]),
      ),
    );
  }
}