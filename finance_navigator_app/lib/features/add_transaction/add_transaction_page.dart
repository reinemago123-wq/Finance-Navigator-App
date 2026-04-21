import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

// ─────────────────────────────────────────────
//  Transaction types
// ─────────────────────────────────────────────
enum TxnType { expense, income, bill, savings }

extension TxnTypeExt on TxnType {
  String get label => ['Expense', 'Income', 'Bill', 'Savings'][index];
  String get emoji => ['🔴', '🟢', '📋', '💰'][index];
  Color get color => [
    AppColors.expense,
    AppColors.income,
    AppColors.warning,
    AppColors.accent,
  ][index];
}

// ─────────────────────────────────────────────
//  Categories per type
// ─────────────────────────────────────────────
const _expenseCategories = [
  ('🍕', 'Food & Dining'),
  ('🚌', 'Transport'),
  ('🎮', 'Entertainment'),
  ('💡', 'Bills & Utilities'),
  ('🛍️', 'Shopping'),
  ('🏥', 'Health'),
  ('📚', 'Education'),
  ('✈️', 'Travel'),
  ('📦', 'Other'),
];

const _incomeCategories = [
  ('💼', 'Salary'),
  ('💸', 'Freelance'),
  ('📈', 'Investments'),
  ('🎁', 'Gift'),
  ('📦', 'Other'),
];

// ─────────────────────────────────────────────
//  AddTransactionPage
// ─────────────────────────────────────────────
class AddTransactionPage extends StatefulWidget {
  final TxnType initialType;
  const AddTransactionPage({super.key, this.initialType = TxnType.expense});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late TxnType _type;
    @override
  void initState() { super.initState(); _type = widget.initialType; }

  final _amountCtrl = TextEditingController(text: '0.00');
  final _titleCtrl  = TextEditingController();
  final _noteCtrl   = TextEditingController();
  int? _selectedCategory;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<(String, String)> get _categories =>
      _type == TxnType.income ? _incomeCategories : _expenseCategories;

  void _save() {
    // TODO: persist to data layer
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
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
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave =
        _titleCtrl.text.isNotEmpty && double.tryParse(_amountCtrl.text) != null && double.parse(_amountCtrl.text) > 0;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Tinted orb matching selected type
          Positioned(
            top: -80, left: 0, right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [_type.color.withOpacity(0.14), Colors.transparent],
                  radius: 0.65,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: GlassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: BorderRadius.circular(Rd.md),
                          child: const Icon(Icons.chevron_left_rounded,
                              color: AppColors.onDark, size: 22),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text('Add Transaction', style: AppText.h3),
                        ),
                      ),
                      const SizedBox(width: 42), // balance
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Sp.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Type selector ────────────────
                        Row(
                          children: TxnType.values.map((t) {
                            final active = _type == t;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _type = t;
                                  _selectedCategory = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(
                                      right: t != TxnType.savings ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? t.color.withOpacity(0.18)
                                        : AppColors.glassWhite,
                                    border: Border.all(
                                      color: active
                                          ? t.color.withOpacity(0.45)
                                          : AppColors.glassBorder,
                                      width: active ? 1.5 : 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(Rd.md),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(t.emoji,
                                          style: const TextStyle(fontSize: 18)),
                                      const SizedBox(height: 3),
                                      Text(t.label,
                                          style: TextStyle(
                                            color: active
                                                ? t.color
                                                : AppColors.onDark
                                                    .withOpacity(0.35),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: Sp.md),

                        // ── Amount display ───────────────
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: Sp.lg, horizontal: Sp.md),
                          borderRadius: BorderRadius.circular(Rd.xl),
                          child: Column(
                            children: [
                              Text('AMOUNT',
                                  style: AppText.caption.copyWith(
                                      letterSpacing: 1.0, fontSize: 10)),
                              const SizedBox(height: Sp.sm),
                              IntrinsicWidth(
                                child: TextField(
                                  controller: _amountCtrl,
                                  onChanged: (_) => setState(() {}),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]')),
                                  ],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _type.color,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.0,
                                  ),
                                  decoration: InputDecoration(
                                    prefix: Text(
                                      _type == TxnType.income ? '+ \$' : '- \$',
                                      style: TextStyle(
                                        color: _type.color,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const SizedBox(height: Sp.sm),
                              GestureDetector(
                                onTap: _pickDate,
                                child: Text(
                                  '${_date.day}/${_date.month}/${_date.year}',
                                  style: AppText.caption.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Sp.md),

                        // ── Title field ──────────────────
                        _InputRow(
                          icon: Icons.title_rounded,
                          child: TextField(
                            controller: _titleCtrl,
                            onChanged: (_) => setState(() {}),
                            style: AppText.body.copyWith(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Transaction title',
                              hintStyle: AppText.body.copyWith(
                                  color: AppColors.onDark.withOpacity(0.30),
                                  fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: Sp.sm),

                        // ── Category picker ──────────────
                        GlassCard(
                          padding: const EdgeInsets.all(Sp.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.sell_outlined,
                                    color: AppColors.accent.withOpacity(0.65),
                                    size: 18),
                                const SizedBox(width: 8),
                                Text('Category',
                                    style: AppText.body.copyWith(
                                        color: AppColors.onDark.withOpacity(0.6),
                                        fontSize: 12)),
                              ]),
                              const SizedBox(height: Sp.sm),
                              Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: List.generate(
                                  _categories.length,
                                  (i) {
                                    final cat = _categories[i];
                                    final sel = _selectedCategory == i;
                                    return GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedCategory = i),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? _type.color.withOpacity(0.18)
                                              : Colors.white.withOpacity(0.06),
                                          border: Border.all(
                                            color: sel
                                                ? _type.color.withOpacity(0.4)
                                                : Colors.white.withOpacity(0.10),
                                            width: sel ? 1.5 : 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(Rd.full),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(cat.$1,
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                            const SizedBox(width: 4),
                                            Text(cat.$2,
                                                style: TextStyle(
                                                  color: sel
                                                      ? _type.color
                                                      : AppColors.onDark
                                                          .withOpacity(0.55),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Sp.sm),

                        // ── Date picker row ──────────────
                        GestureDetector(
                          onTap: _pickDate,
                          child: _InputRow(
                            icon: Icons.calendar_today_outlined,
                            child: Text(
                              '${_date.day}/${_date.month}/${_date.year}',
                              style: AppText.body.copyWith(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: Sp.sm),

                        // ── Note field ───────────────────
                        _InputRow(
                          icon: Icons.notes_rounded,
                          child: TextField(
                            controller: _noteCtrl,
                            maxLines: 2,
                            style: AppText.body.copyWith(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Add a note (optional)',
                              hintStyle: AppText.body.copyWith(
                                  color: AppColors.onDark.withOpacity(0.30),
                                  fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: Sp.md),

                        // ── Recurring toggle ─────────────
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isRecurring = !_isRecurring),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _isRecurring
                                      ? AppColors.accent.withOpacity(0.28)
                                      : AppColors.onDark.withOpacity(0.10),
                                  border: Border.all(
                                    color: _isRecurring
                                        ? AppColors.accent.withOpacity(0.45)
                                        : AppColors.onDark.withOpacity(0.15),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: _isRecurring
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 18, height: 18,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: _isRecurring
                                          ? AppColors.accent
                                          : AppColors.onDark.withOpacity(0.35),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: Sp.md),
                              Text('Recurring transaction',
                                  style: AppText.body.copyWith(
                                      fontSize: 13,
                                      color:
                                          AppColors.onDark.withOpacity(0.70))),
                            ],
                          ),
                        ),
                        const SizedBox(height: Sp.xl),

                        // ── Save button ──────────────────
                        GestureDetector(
                          onTap: canSave ? _save : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: canSave
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.accent,
                                        AppColors.accentDark
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: canSave
                                  ? null
                                  : AppColors.onDark.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(Rd.lg),
                              boxShadow: canSave ? AppShadows.goldGlow : null,
                            ),
                            child: Center(
                              child: Text(
                                'Save Transaction',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: canSave
                                      ? AppColors.primaryDark
                                      : AppColors.onDark.withOpacity(0.30),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Sp.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared input row wrapper ───────────────────────────────────────────────────
class _InputRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _InputRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
          const SizedBox(width: Sp.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}