import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';

class BillDetailPage extends StatefulWidget {
  final BillModel bill;
  final bool isNew;
  const BillDetailPage({super.key, required this.bill, this.isNew = false});
  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  late BillModel _bill;
  bool _editing = false;
  bool _saving  = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  String _selectedFrequency = 'Monthly';
  final _frequencies = ['Weekly','Monthly','Quarterly','Yearly','One-time'];

  @override
  void initState() {
    super.initState();
    _bill = widget.bill;
    _nameCtrl   = TextEditingController(text: _bill.name);
    _amountCtrl = TextEditingController(text: _bill.amount > 0 ? _bill.amount.toStringAsFixed(2) : '');
    _noteCtrl   = TextEditingController(text: _bill.note ?? '');
    _selectedFrequency = _bill.frequency;
    if (widget.isNew) _editing = true;
  }

  @override
  void dispose() { _nameCtrl.dispose(); _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty && (double.tryParse(_amountCtrl.text) ?? 0) > 0;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final updated = _bill.copyWith(
        name: _nameCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text),
        frequency: _selectedFrequency,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      if (widget.isNew) {
        await DbService.addBill(updated);
      } else {
        await DbService.updateBill(updated);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rd.xl)),
        title: const Text('Delete Bill', style: TextStyle(color: AppColors.onDark, fontWeight: FontWeight.w700)),
        content: Text('Remove "${_bill.name}" permanently?',
          style: TextStyle(color: AppColors.onDark.withOpacity(0.70))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.accent))),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700))),
        ]));
    if (confirm == true) {
      await DbService.deleteBill(_bill.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _bill.dueDate,
      firstDate: DateTime(2024), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: AppColors.accent, surface: AppColors.primary)),
        child: child!));
    if (picked != null) setState(() => _bill = _bill.copyWith(dueDate: picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(children: [
        Positioned(top: -80, left: 0, right: 0, child: Container(height: 350,
          decoration: BoxDecoration(gradient: RadialGradient(
            colors: [AppColors.accent.withOpacity(0.12), Colors.transparent], radius: 0.7)))),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 0),
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.of(context).pop(),
                child: _iconBtn(Icons.chevron_left_rounded)),
              const Spacer(),
              Text(_editing ? (_bill.id.isEmpty ? 'New Bill' : 'Edit Bill') : 'Bill Details', style: AppText.h3),
              const Spacer(),
              if (!_editing)
                Row(children: [
                  GestureDetector(onTap: () => setState(() => _editing = true), child: _iconBtn(Icons.edit_outlined)),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _delete, child: _iconBtn(Icons.delete_outline_rounded, color: AppColors.expense)),
                ])
              else
                GestureDetector(onTap: () => _bill.id.isEmpty
                  ? Navigator.pop(context)
                  : setState(() => _editing = false),
                  child: _iconBtn(Icons.close_rounded)),
            ])),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sp.lg),
            child: _editing ? _buildForm() : _buildView())),
        ])),
      ]),
    );
  }

  Widget _buildView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GlassCard.gold(padding: const EdgeInsets.all(Sp.lg), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 52, height: 52,
              decoration: BoxDecoration(color: _bill.statusColor.withOpacity(0.20),
                borderRadius: BorderRadius.circular(Rd.lg)),
              child: Icon(Icons.receipt_outlined, color: _bill.statusColor, size: 26)),
            const SizedBox(width: Sp.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_bill.name, style: AppText.h3.copyWith(color: AppColors.onDark)),
              const SizedBox(height: 3),
              Text(_bill.category, style: AppText.caption.copyWith(fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _bill.statusColor.withOpacity(0.15),
                border: Border.all(color: _bill.statusColor.withOpacity(0.35)),
                borderRadius: BorderRadius.circular(Rd.full)),
              child: Text(_bill.isPaid ? 'Paid' : 'Unpaid',
                style: TextStyle(color: _bill.statusColor, fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: Sp.lg),
          Text('Amount', style: AppText.label.copyWith(color: AppColors.accent.withOpacity(0.80))),
          const SizedBox(height: 4),
          Text(_bill.formattedAmount, style: AppText.moneyLarge),
        ])),
      const SizedBox(height: Sp.lg),
      Text('Details', style: AppText.h3),
      const SizedBox(height: Sp.md),
      GlassCard(padding: const EdgeInsets.all(Sp.lg), child: Column(children: [
        _detailRow(Icons.calendar_today_outlined, 'Due Date',
          '${_bill.dueDate.day}/${_bill.dueDate.month}/${_bill.dueDate.year}'),
        _divider(),
        _detailRow(Icons.schedule_outlined, 'Status', _bill.dueDateLabel, valueColor: _bill.statusColor),
        _divider(),
        _detailRow(Icons.repeat_rounded, 'Frequency', _bill.frequency),
        if (_bill.note != null && _bill.note!.isNotEmpty) ...[
          _divider(),
          _detailRow(Icons.notes_rounded, 'Note', _bill.note!),
        ],
      ])),
      const SizedBox(height: Sp.xl),
      GestureDetector(
        onTap: () => DbService.markBillPaid(_bill.id, !_bill.isPaid).then((_) =>
          setState(() => _bill = _bill.copyWith(isPaid: !_bill.isPaid))),
        child: Container(height: 54,
          decoration: BoxDecoration(
            gradient: _bill.isPaid ? null : const LinearGradient(
              colors: [AppColors.income, Color(0xFF27AE60)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            color: _bill.isPaid ? AppColors.glassWhite : null,
            border: _bill.isPaid ? Border.all(color: AppColors.glassBorder) : null,
            borderRadius: BorderRadius.circular(Rd.lg)),
          child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_bill.isPaid ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
              color: _bill.isPaid ? AppColors.onDark.withOpacity(0.60) : AppColors.primaryDark, size: 20),
            const SizedBox(width: 8),
            Text(_bill.isPaid ? 'Mark as Unpaid' : 'Mark as Paid',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: _bill.isPaid ? AppColors.onDark.withOpacity(0.60) : AppColors.primaryDark)),
          ])))),
    ]);
  }

  Widget _buildForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _formLabel('Bill Name'),
      const SizedBox(height: Sp.sm),
      _textField(controller: _nameCtrl, hint: 'e.g. Electricity Bill', icon: Icons.receipt_long_outlined,
        onChanged: () => setState(() {})),
      const SizedBox(height: Sp.md),
      _formLabel('Amount (\$)'),
      const SizedBox(height: Sp.sm),
      _textField(controller: _amountCtrl, hint: '0.00', icon: Icons.attach_money_rounded,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: () => setState(() {})),
      const SizedBox(height: Sp.md),
      _formLabel('Due Date'),
      const SizedBox(height: Sp.sm),
      GestureDetector(onTap: _pickDate,
        child: GlassCard(padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 14),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.accent.withOpacity(0.70), size: 20),
            const SizedBox(width: Sp.md),
            Text('${_bill.dueDate.day}/${_bill.dueDate.month}/${_bill.dueDate.year}',
              style: AppText.body.copyWith(fontSize: 14)),
            const Spacer(),
            Icon(Icons.edit_calendar_outlined, color: AppColors.onDark.withOpacity(0.30), size: 16),
          ]))),
      const SizedBox(height: Sp.md),
      _formLabel('Frequency'),
      const SizedBox(height: Sp.sm),
      GlassCard(padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 4),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: _selectedFrequency, dropdownColor: AppColors.primary,
          isExpanded: true,
          icon: Icon(Icons.expand_more_rounded, color: AppColors.accent.withOpacity(0.70)),
          items: _frequencies.map((f) => DropdownMenuItem(value: f,
            child: Text(f, style: AppText.body.copyWith(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _selectedFrequency = v!)))),
      const SizedBox(height: Sp.md),
      _formLabel('Note (optional)'),
      const SizedBox(height: Sp.sm),
      GlassCard(padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 10),
        child: TextField(controller: _noteCtrl, maxLines: 3,
          style: AppText.body.copyWith(fontSize: 13),
          decoration: InputDecoration(hintText: 'Add a note...',
            hintStyle: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
            border: InputBorder.none, contentPadding: EdgeInsets.zero))),
      const SizedBox(height: Sp.xl),
      GestureDetector(onTap: (_canSave && !_saving) ? _save : null,
        child: Container(height: 54,
          decoration: BoxDecoration(
            gradient: _canSave ? const LinearGradient(colors: [AppColors.accent, AppColors.accentDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            color: _canSave ? null : AppColors.onDark.withOpacity(0.07),
            borderRadius: BorderRadius.circular(Rd.lg),
            boxShadow: _canSave ? AppShadows.goldGlow : null),
          child: Center(child: _saving
            ? const CircularProgressIndicator(color: AppColors.primaryDark, strokeWidth: 2.5)
            : Text('Save Bill', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: _canSave ? AppColors.primaryDark : AppColors.onDark.withOpacity(0.30)))))),
    ]);
  }

  Widget _iconBtn(IconData icon, {Color? color}) => Container(width: 40, height: 40,
    decoration: BoxDecoration(color: AppColors.glassWhite, border: Border.all(color: AppColors.glassBorder),
      borderRadius: BorderRadius.circular(Rd.md)),
    child: Icon(icon, color: color ?? AppColors.onDark.withOpacity(0.80), size: 20));

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
      const SizedBox(width: Sp.md),
      Expanded(child: Text(label, style: AppText.body.copyWith(
        color: AppColors.onDark.withOpacity(0.55), fontSize: 13))),
      Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13,
        color: valueColor ?? AppColors.onDark)),
    ]));

  Widget _divider() => Divider(height: 1, thickness: 1, color: AppColors.onDark.withOpacity(0.08));
  Widget _formLabel(String text) => Text(text, style: AppText.body.copyWith(
    color: AppColors.onDark.withOpacity(0.65), fontWeight: FontWeight.w600, fontSize: 13));

  Widget _textField({required TextEditingController controller, required String hint,
      required IconData icon, TextInputType keyboardType = TextInputType.text,
      required VoidCallback onChanged}) =>
    GlassCard(padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 10),
      child: Row(children: [
        Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
        const SizedBox(width: Sp.md),
        Expanded(child: TextField(controller: controller, keyboardType: keyboardType,
          onChanged: (_) => onChanged(),
          style: AppText.body.copyWith(fontSize: 13),
          decoration: InputDecoration(hintText: hint,
            hintStyle: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
            border: InputBorder.none, contentPadding: EdgeInsets.zero))),
      ]));
}