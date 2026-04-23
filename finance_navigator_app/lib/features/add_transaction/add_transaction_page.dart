import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';

enum TxnType { expense, income, bill, savings }

extension TxnTypeExt on TxnType {
  String get label => ['Expense', 'Income', 'Bill', 'Savings'][index];
  String get dbKey => ['expense', 'income', 'bill', 'savings'][index];
  Color get color  => [AppColors.expense, AppColors.income, AppColors.warning, AppColors.accent][index];
}

const _expenseCategories = [
  ('Food & Dining'), ('Transport'), ('Entertainment'),
  ('Bills & Utilities'), ('Shopping'), ('Health'), ('Education'), ('Travel'), ('Other'),
];
const _incomeCategories = [
  ('Salary'), ('Freelance'), ('Investments'), ('Gift'), ('Other'),
];

class AddTransactionPage extends StatefulWidget {
  final TxnType initialType;
  final TransactionModel? existing; // if editing
  const AddTransactionPage({super.key, this.initialType = TxnType.expense, this.existing});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late TxnType _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _noteCtrl;
  int? _selectedCategory;
  late DateTime _date;
  bool _isRecurring = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e != null
        ? TxnType.values.firstWhere((t) => t.dbKey == e.type, orElse: () => TxnType.expense)
        : widget.initialType;
    _amountCtrl = TextEditingController(text: e != null ? e.amount.toStringAsFixed(2) : '');
    _titleCtrl  = TextEditingController(text: e?.title ?? '');
    _noteCtrl   = TextEditingController(text: e?.note  ?? '');
    _date       = e?.date ?? DateTime.now();
    _isRecurring = e?.isRecurring ?? false;
    if (e != null) {
      final cats = _type == TxnType.income ? _incomeCategories : _expenseCategories;
      final idx = cats.indexOf(e.category);
      _selectedCategory = idx >= 0 ? idx : null;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose(); _titleCtrl.dispose(); _noteCtrl.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      _type == TxnType.income ? List.from(_incomeCategories) : List.from(_expenseCategories);

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      (double.tryParse(_amountCtrl.text) ?? 0) > 0;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final amount   = double.parse(_amountCtrl.text);
      final category = _selectedCategory != null ? _categories[_selectedCategory!] : 'Other';
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          title: _titleCtrl.text.trim(), amount: amount,
          type: _type.dbKey, category: category,
          date: _date, note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          isRecurring: _isRecurring,
        );
        await DbService.updateTransaction(updated);
      } else {
        final txn = TransactionModel(
          id: '', title: _titleCtrl.text.trim(), amount: amount,
          type: _type.dbKey, category: category, date: _date,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          isRecurring: _isRecurring,
        );
        await DbService.addTransaction(txn);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(
          primary: AppColors.accent, surface: AppColors.primary)),
        child: child!),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(children: [
        Positioned(top: -80, left: 0, right: 0, child: Container(
          height: 300,
          decoration: BoxDecoration(gradient: RadialGradient(
            colors: [_type.color.withOpacity(0.14), Colors.transparent], radius: 0.65)),
        )),
        SafeArea(child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 0),
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.of(context).pop(),
                child: GlassCard(padding: const EdgeInsets.all(10),
                  borderRadius: BorderRadius.circular(Rd.md),
                  child: const Icon(Icons.chevron_left_rounded, color: AppColors.onDark, size: 22))),
              Expanded(child: Center(child: Text(
                _isEditing ? 'Edit Transaction' : 'Add Transaction', style: AppText.h3))),
              if (_isEditing)
                GestureDetector(
                  onTap: () async {
                    await DbService.deleteTransaction(widget.existing!.id);
                    if (mounted) Navigator.of(context).pop(true);
                  },
                  child: GlassCard(padding: const EdgeInsets.all(10),
                    borderRadius: BorderRadius.circular(Rd.md),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 20)))
              else const SizedBox(width: 42),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sp.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Type selector
              Row(children: TxnType.values.map((t) {
                final active = _type == t;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() { _type = t; _selectedCategory = null; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: t != TxnType.savings ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? t.color.withOpacity(0.18) : AppColors.glassWhite,
                      border: Border.all(color: active ? t.color.withOpacity(0.45) : AppColors.glassBorder,
                          width: active ? 1.5 : 1.0),
                      borderRadius: BorderRadius.circular(Rd.md)),
                    child: Column(children: [
                      Icon(active ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: active ? t.color : AppColors.onDark.withOpacity(0.35), size: 16),
                      const SizedBox(height: 4),
                      Text(t.label, style: TextStyle(
                        color: active ? t.color : AppColors.onDark.withOpacity(0.35),
                        fontSize: 10, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ));
              }).toList()),
              const SizedBox(height: Sp.md),

              // Amount
              GlassCard(padding: const EdgeInsets.symmetric(vertical: Sp.lg, horizontal: Sp.md),
                borderRadius: BorderRadius.circular(Rd.xl),
                child: Column(children: [
                  Text('AMOUNT', style: AppText.caption.copyWith(letterSpacing: 1.0, fontSize: 10)),
                  const SizedBox(height: Sp.sm),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_type == TxnType.income ? '+\$' : '-\$',
                      style: TextStyle(color: _type.color, fontSize: 28, fontWeight: FontWeight.w700)),
                    IntrinsicWidth(child: TextField(
                      controller: _amountCtrl,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _type.color, fontSize: 28, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: _type.color.withOpacity(0.30), fontSize: 28),
                        border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    )),
                  ]),
                  const SizedBox(height: Sp.sm),
                  GestureDetector(onTap: _pickDate,
                    child: Text('${_date.day}/${_date.month}/${_date.year}',
                      style: AppText.caption.copyWith(fontSize: 12))),
                ])),
              const SizedBox(height: Sp.md),

              // Title
              _inputRow(icon: Icons.title_rounded,
                child: TextField(controller: _titleCtrl, onChanged: (_) => setState(() {}),
                  style: AppText.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(hintText: 'Title',
                    hintStyle: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
                    border: InputBorder.none, contentPadding: EdgeInsets.zero))),
              const SizedBox(height: Sp.sm),

              // Category
              GlassCard(padding: const EdgeInsets.all(Sp.md), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.sell_outlined, color: AppColors.accent.withOpacity(0.65), size: 18),
                    const SizedBox(width: 8),
                    Text('Category', style: AppText.body.copyWith(
                        color: AppColors.onDark.withOpacity(0.6), fontSize: 12)),
                  ]),
                  const SizedBox(height: Sp.sm),
                  Wrap(spacing: 7, runSpacing: 7,
                    children: List.generate(_categories.length, (i) {
                      final sel = _selectedCategory == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? _type.color.withOpacity(0.18) : Colors.white.withOpacity(0.06),
                            border: Border.all(color: sel ? _type.color.withOpacity(0.4) : Colors.white.withOpacity(0.10),
                                width: sel ? 1.5 : 1.0),
                            borderRadius: BorderRadius.circular(Rd.full)),
                          child: Text(_categories[i], style: TextStyle(
                            color: sel ? _type.color : AppColors.onDark.withOpacity(0.55),
                            fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      );
                    })),
                ])),
              const SizedBox(height: Sp.sm),

              // Date
              GestureDetector(onTap: _pickDate,
                child: _inputRow(icon: Icons.calendar_today_outlined,
                  child: Text('${_date.day}/${_date.month}/${_date.year}',
                    style: AppText.body.copyWith(fontSize: 13)))),
              const SizedBox(height: Sp.sm),

              // Note
              _inputRow(icon: Icons.notes_rounded,
                child: TextField(controller: _noteCtrl, maxLines: 2,
                  style: AppText.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(hintText: 'Note (optional)',
                    hintStyle: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
                    border: InputBorder.none, contentPadding: EdgeInsets.zero))),
              const SizedBox(height: Sp.md),

              // Recurring
              GestureDetector(onTap: () => setState(() => _isRecurring = !_isRecurring),
                child: Row(children: [
                  AnimatedContainer(duration: const Duration(milliseconds: 200),
                    width: 44, height: 24,
                    decoration: BoxDecoration(
                      color: _isRecurring ? AppColors.accent.withOpacity(0.28) : AppColors.onDark.withOpacity(0.10),
                      border: Border.all(color: _isRecurring ? AppColors.accent.withOpacity(0.45) : AppColors.onDark.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(12)),
                    child: AnimatedAlign(duration: const Duration(milliseconds: 200),
                      alignment: _isRecurring ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(width: 18, height: 18, margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: _isRecurring ? AppColors.accent : AppColors.onDark.withOpacity(0.35),
                          shape: BoxShape.circle)))),
                  const SizedBox(width: Sp.md),
                  Text('Recurring transaction', style: AppText.body.copyWith(fontSize: 13,
                      color: AppColors.onDark.withOpacity(0.70))),
                ])),
              const SizedBox(height: Sp.xl),

              // Save
              GestureDetector(onTap: (_canSave && !_saving) ? _save : null,
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: _canSave ? const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentDark],
                        begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                    color: _canSave ? null : AppColors.onDark.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(Rd.lg),
                    boxShadow: _canSave ? AppShadows.goldGlow : null),
                  child: Center(child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: AppColors.primaryDark, strokeWidth: 2.5))
                    : Text(_isEditing ? 'Save Changes' : 'Save Transaction',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          color: _canSave ? AppColors.primaryDark : AppColors.onDark.withOpacity(0.30)))))),
              const SizedBox(height: Sp.lg),
            ]),
          )),
        ])),
      ]),
    );
  }

  Widget _inputRow({required IconData icon, required Widget child}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
      child: Row(children: [
        Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
        const SizedBox(width: Sp.sm),
        Expanded(child: child),
      ]),
    );
  }
}