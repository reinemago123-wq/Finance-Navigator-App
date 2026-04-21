import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

// ─────────────────────────────────────────────
//  Shared Bill model (used by calendar + detail)
// ─────────────────────────────────────────────
class BillModel {
  final String id;
  String name;
  String amount;
  String category;
  String frequency;
  DateTime dueDate;
  bool isPaid;
  String? note;
  IconData icon;
  Color color;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.dueDate,
    required this.isPaid,
    required this.icon,
    required this.color,
    this.note,
  });

  BillModel copyWith({
    String? name, String? amount, String? category,
    String? frequency, DateTime? dueDate, bool? isPaid,
    String? note, IconData? icon, Color? color,
  }) => BillModel(
    id: id,
    name:      name      ?? this.name,
    amount:    amount    ?? this.amount,
    category:  category  ?? this.category,
    frequency: frequency ?? this.frequency,
    dueDate:   dueDate   ?? this.dueDate,
    isPaid:    isPaid    ?? this.isPaid,
    icon:      icon      ?? this.icon,
    color:     color     ?? this.color,
    note:      note      ?? this.note,
  );

  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  String get dueDateLabel {
    final d = daysUntilDue;
    if (d < 0)  return 'Overdue by ${-d} day${-d == 1 ? '' : 's'}';
    if (d == 0) return 'Due today';
    if (d == 1) return 'Due tomorrow';
    return 'Due in $d days';
  }
}

// ─────────────────────────────────────────────
//  BillDetailPage
// ─────────────────────────────────────────────
class BillDetailPage extends StatefulWidget {
  final BillModel bill;
  final ValueChanged<BillModel>? onUpdated;
  final VoidCallback? onDeleted;

  const BillDetailPage({
    super.key,
    required this.bill,
    this.onUpdated,
    this.onDeleted,
  });

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  late BillModel _bill;
  bool _editing = false;

  // Edit controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  String _selectedFrequency = 'Monthly';
  final _frequencies = ['Weekly', 'Monthly', 'Quarterly', 'Yearly', 'One-time'];

  @override
  void initState() {
    super.initState();
    _bill = widget.bill;
    _nameCtrl   = TextEditingController(text: _bill.name);
    _amountCtrl = TextEditingController(text: _bill.amount.replaceAll('\$', ''));
    _noteCtrl   = TextEditingController(text: _bill.note ?? '');
    _selectedFrequency = _bill.frequency;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _togglePaid() {
    setState(() => _bill = _bill.copyWith(isPaid: !_bill.isPaid));
    widget.onUpdated?.call(_bill);
  }

  void _saveEdits() {
    setState(() {
      _bill = _bill.copyWith(
        name:      _nameCtrl.text.trim(),
        amount:    '\$${_amountCtrl.text.trim()}',
        frequency: _selectedFrequency,
        note:      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      _editing = false;
    });
    widget.onUpdated?.call(_bill);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rd.xl)),
        title: const Text('Delete Bill',
            style: TextStyle(color: AppColors.onDark, fontWeight: FontWeight.w700)),
        content: Text('Remove "${_bill.name}" permanently?',
            style: TextStyle(color: AppColors.onDark.withOpacity(0.70))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleted?.call();
              Navigator.of(context).pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _bill.dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _bill = _bill.copyWith(dueDate: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue  = !_bill.isPaid && _bill.daysUntilDue < 0;
    final isUrgent   = !_bill.isPaid && _bill.daysUntilDue >= 0 && _bill.daysUntilDue <= 3;
    final statusColor = _bill.isPaid ? AppColors.income
        : isOverdue ? AppColors.expense
        : isUrgent  ? AppColors.warning
        : AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(children: [
        // Background orb
        Positioned(
          top: -80, left: 0, right: 0,
          child: Container(
            height: 350,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [_bill.color.withOpacity(0.14), Colors.transparent],
                radius: 0.7,
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(children: [
            // ── App bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: _iconBtn(Icons.chevron_left_rounded),
                ),
                const Spacer(),
                Text(_editing ? 'Edit Bill' : 'Bill Details',
                    style: AppText.h3),
                const Spacer(),
                if (!_editing)
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => _editing = true),
                      child: _iconBtn(Icons.edit_outlined),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _confirmDelete,
                      child: _iconBtn(Icons.delete_outline_rounded,
                          color: AppColors.expense),
                    ),
                  ])
                else
                  GestureDetector(
                    onTap: () => setState(() => _editing = false),
                    child: _iconBtn(Icons.close_rounded),
                  ),
              ]),
            ),

            // ── Content ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Sp.lg),
                child: _editing ? _buildEditForm() : _buildView(statusColor),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Read view ───────────────────────────────────────────────────────────────
  Widget _buildView(Color statusColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Hero card
      GlassCard.gold(
        padding: const EdgeInsets.all(Sp.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _bill.color.withOpacity(0.20),
                borderRadius: BorderRadius.circular(Rd.lg),
              ),
              child: Icon(_bill.icon, color: _bill.color, size: 26),
            ),
            const SizedBox(width: Sp.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_bill.name,
                  style: AppText.h3.copyWith(color: AppColors.onDark)),
              const SizedBox(height: 3),
              Text(_bill.category,
                  style: AppText.caption.copyWith(fontSize: 12)),
            ])),
            // Paid status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                border: Border.all(color: statusColor.withOpacity(0.35)),
                borderRadius: BorderRadius.circular(Rd.full),
              ),
              child: Text(
                _bill.isPaid ? 'Paid' : 'Unpaid',
                style: TextStyle(color: statusColor, fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: Sp.lg),
          Text('Amount', style: AppText.label.copyWith(
              color: AppColors.accent.withOpacity(0.80))),
          const SizedBox(height: 4),
          Text(_bill.amount, style: AppText.moneyLarge),
        ]),
      ),
      const SizedBox(height: Sp.lg),

      // Info grid
      Text('Details', style: AppText.h3),
      const SizedBox(height: Sp.md),
      GlassCard(
        padding: const EdgeInsets.all(Sp.lg),
        child: Column(children: [
          _detailRow(Icons.calendar_today_outlined, 'Due Date',
              '${_bill.dueDate.day}/${_bill.dueDate.month}/${_bill.dueDate.year}'),
          _divider(),
          _detailRow(Icons.schedule_outlined, 'Status', _bill.dueDateLabel,
              valueColor: statusColor),
          _divider(),
          _detailRow(Icons.repeat_rounded, 'Frequency', _bill.frequency),
          if (_bill.note != null && _bill.note!.isNotEmpty) ...[
            _divider(),
            _detailRow(Icons.notes_rounded, 'Note', _bill.note!),
          ],
        ]),
      ),
      const SizedBox(height: Sp.xl),

      // Mark paid button
      GestureDetector(
        onTap: _togglePaid,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: _bill.isPaid
                ? null
                : const LinearGradient(
                    colors: [AppColors.income, Color(0xFF27AE60)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
            color: _bill.isPaid ? AppColors.glassWhite : null,
            border: _bill.isPaid
                ? Border.all(color: AppColors.glassBorder)
                : null,
            borderRadius: BorderRadius.circular(Rd.lg),
          ),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_bill.isPaid ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                  color: _bill.isPaid ? AppColors.onDark.withOpacity(0.60) : AppColors.primaryDark,
                  size: 20),
              const SizedBox(width: 8),
              Text(
                _bill.isPaid ? 'Mark as Unpaid' : 'Mark as Paid',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: _bill.isPaid
                      ? AppColors.onDark.withOpacity(0.60)
                      : AppColors.primaryDark,
                ),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }

  // ── Edit form ────────────────────────────────────────────────────────────────
  Widget _buildEditForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      _formLabel('Bill Name'),
      const SizedBox(height: Sp.sm),
      _textField(controller: _nameCtrl, hint: 'e.g. Electricity Bill',
          icon: Icons.receipt_long_outlined),
      const SizedBox(height: Sp.md),

      _formLabel('Amount (\$)'),
      const SizedBox(height: Sp.sm),
      _textField(controller: _amountCtrl, hint: '0.00',
          icon: Icons.attach_money_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true)),
      const SizedBox(height: Sp.md),

      _formLabel('Due Date'),
      const SizedBox(height: Sp.sm),
      GestureDetector(
        onTap: _pickDate,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 14),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined,
                color: AppColors.accent.withOpacity(0.70), size: 20),
            const SizedBox(width: Sp.md),
            Text(
              '${_bill.dueDate.day}/${_bill.dueDate.month}/${_bill.dueDate.year}',
              style: AppText.body.copyWith(fontSize: 14),
            ),
          ]),
        ),
      ),
      const SizedBox(height: Sp.md),

      _formLabel('Frequency'),
      const SizedBox(height: Sp.sm),
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedFrequency,
            dropdownColor: AppColors.primary,
            isExpanded: true,
            icon: Icon(Icons.expand_more_rounded,
                color: AppColors.accent.withOpacity(0.70)),
            items: _frequencies.map((f) => DropdownMenuItem(
              value: f,
              child: Text(f, style: AppText.body.copyWith(fontSize: 14)),
            )).toList(),
            onChanged: (v) => setState(() => _selectedFrequency = v!),
          ),
        ),
      ),
      const SizedBox(height: Sp.md),

      _formLabel('Note (optional)'),
      const SizedBox(height: Sp.sm),
      GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 10),
        child: TextField(
          controller: _noteCtrl,
          maxLines: 3,
          style: AppText.body.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Add a note…',
            hintStyle: AppText.body.copyWith(
                color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      const SizedBox(height: Sp.xl),

      GestureDetector(
        onTap: _saveEdits,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Rd.lg),
            boxShadow: AppShadows.goldGlow,
          ),
          child: const Center(
            child: Text('Save Changes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark)),
          ),
        ),
      ),
    ]);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, {Color? color}) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(Rd.md),
      ),
      child: Icon(icon,
          color: color ?? AppColors.onDark.withOpacity(0.80), size: 20),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
        const SizedBox(width: Sp.md),
        Expanded(child: Text(label,
            style: AppText.body.copyWith(
                color: AppColors.onDark.withOpacity(0.55), fontSize: 13))),
        Text(value, style: AppText.body.copyWith(
            fontWeight: FontWeight.w600, fontSize: 13,
            color: valueColor ?? AppColors.onDark)),
      ]),
    );
  }

  Widget _divider() => Divider(
      height: 1, thickness: 1,
      color: AppColors.onDark.withOpacity(0.08));

  Widget _formLabel(String text) => Text(text,
      style: AppText.body.copyWith(
          color: AppColors.onDark.withOpacity(0.65),
          fontWeight: FontWeight.w600, fontSize: 13));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 10),
      child: Row(children: [
        Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
        const SizedBox(width: Sp.md),
        Expanded(child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppText.body.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(
                color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        )),
      ]),
    );
  }
}