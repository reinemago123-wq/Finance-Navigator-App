import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});
  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<SavingsGoalModel>>(
        stream: DbService.watchGoals(),
        builder: (ctx, snap) {
          final goals      = snap.data ?? [];
          final totalSaved = goals.fold(0.0, (s, g) => s + g.saved);
          final loading    = snap.connectionState == ConnectionState.waiting;

          return Stack(children: [
            // Background orb
            Positioned(top: -60, right: -40, child: Container(width: 240, height: 240,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.income.withOpacity(0.10), Colors.transparent])))),

            SafeArea(bottom: false, child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Header ──────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Savings Goals', style: AppText.h2.copyWith(color: AppColors.onDark)),
                  GestureDetector(
                    onTap: () => _openSheet(context, null),
                    child: Container(width: 38, height: 38,
                      decoration: BoxDecoration(gradient: AppGradients.accent,
                        borderRadius: BorderRadius.circular(Rd.md),
                        boxShadow: AppShadows.goldGlow),
                      child: const Icon(Icons.add_rounded, color: AppColors.primaryDark, size: 22))),
                ]),
                const SizedBox(height: Sp.lg),

                // ── Summary card ─────────────────────────
                GlassCard(padding: const EdgeInsets.all(Sp.lg),
                  child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('TOTAL SAVED', style: AppText.caption.copyWith(letterSpacing: 0.8, fontSize: 10)),
                    const SizedBox(height: 3),
                    Text('\$${totalSaved.toInt()}',
                      style: AppText.moneyLarge.copyWith(color: AppColors.accent)),
                    Text('across ${goals.length} goal${goals.length == 1 ? '' : 's'}',
                      style: AppText.caption.copyWith(fontSize: 11)),
                  ])),
                  Container(width: 1, height: 44, color: AppColors.glassBorder,
                    margin: const EdgeInsets.symmetric(horizontal: Sp.md)),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('IN PROGRESS', style: AppText.caption.copyWith(letterSpacing: 0.8, fontSize: 10)),
                    const SizedBox(height: 3),
                    Text('${goals.where((g) => !g.complete).length}',
                      style: const TextStyle(color: AppColors.income,
                        fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('active goals', style: AppText.caption.copyWith(fontSize: 11)),
                  ])),
                ])),
                const SizedBox(height: Sp.lg),

                // ── Goal list ────────────────────────────
                if (loading)
                  const Center(child: Padding(padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.accent)))
                else if (goals.isEmpty)
                  _EmptyState(onAdd: () => _openSheet(context, null))
                else
                  ...goals.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: Sp.md),
                    child: GestureDetector(
                      onTap: () => _openSheet(context, g),
                      child: _GoalCard(goal: g)))),
              ]),
            )),
          ]);
        }),
      );
  }

  void _openSheet(BuildContext ctx, SavingsGoalModel? goal) {
    showModalBottomSheet(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _GoalSheet(goal: goal));
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.symmetric(vertical: Sp.xl, horizontal: Sp.lg),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Icon(Icons.savings_outlined, color: AppColors.onDark.withOpacity(0.20), size: 56),
      const SizedBox(height: Sp.md),
      Text('No savings goals yet', style: AppText.h3, textAlign: TextAlign.center),
      const SizedBox(height: Sp.sm),
      Text('Create a goal to start saving',
        style: AppText.caption.copyWith(fontSize: 12), textAlign: TextAlign.center),
      const SizedBox(height: Sp.lg),
      GestureDetector(onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(gradient: AppGradients.accent,
            borderRadius: BorderRadius.circular(Rd.lg),
            boxShadow: AppShadows.goldGlow),
          child: const Text('Create First Goal', style: TextStyle(
            color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center))),
    ]));
}

// ── Goal card ──────────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  const _GoalCard({required this.goal});
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(Sp.lg),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 46, height: 46,
          decoration: BoxDecoration(color: goal.color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(goal.emoji, style: const TextStyle(fontSize: 22)))),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(goal.name, style: AppText.body.copyWith(
            fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onDark)),
          const SizedBox(height: 2),
          Text('Target: ${goal.deadlineLabel}',
            style: AppText.caption.copyWith(fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: goal.color.withOpacity(0.14),
              border: Border.all(color: goal.color.withOpacity(0.28)),
              borderRadius: Rd.chip),
            child: Text(goal.complete ? '✓ Done' : '${(goal.pct * 100).toInt()}%',
              style: TextStyle(color: goal.color, fontSize: 11, fontWeight: FontWeight.w700))),
          const SizedBox(height: 4),
          Text('tap to edit', style: AppText.caption.copyWith(
            fontSize: 10, color: AppColors.onDark.withOpacity(0.30))),
        ]),
      ]),
      const SizedBox(height: Sp.md),
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: goal.pct, minHeight: 7,
          backgroundColor: AppColors.onDark.withOpacity(0.08),
          valueColor: AlwaysStoppedAnimation<Color>(goal.color))),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('\$${goal.saved.toInt()} saved',
          style: AppText.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.onDark.withOpacity(0.70))),
        Text('\$${goal.remaining.toInt()} to go',
          style: AppText.caption.copyWith(fontSize: 10)),
      ]),
    ]));
}

// ── Add / Edit sheet ───────────────────────────────────────────────────────────
class _GoalSheet extends StatefulWidget {
  final SavingsGoalModel? goal;
  const _GoalSheet({this.goal});
  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _saved;
  late DateTime _deadline;
  bool _saving = false;
  bool get _isNew => widget.goal == null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _name     = TextEditingController(text: g?.name ?? '');
    _target   = TextEditingController(text: g != null ? g.target.toStringAsFixed(0) : '');
    _saved    = TextEditingController(text: g != null && g.saved > 0 ? g.saved.toStringAsFixed(0) : '');
    _deadline = g?.deadline ?? DateTime.now().add(const Duration(days: 180));
  }

  @override
  void dispose() { _name.dispose(); _target.dispose(); _saved.dispose(); super.dispose(); }

  bool get _canSave => _name.text.trim().isNotEmpty && (double.tryParse(_target.text) ?? 0) > 0;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final target = double.parse(_target.text);
      final saved  = (double.tryParse(_saved.text) ?? (widget.goal?.saved ?? 0)).clamp(0.0, target);
      if (_isNew) {
        await DbService.addGoal(SavingsGoalModel(
          id: '', emoji: '🎯', name: _name.text.trim(),
          target: target, saved: saved,
          colorValue: AppColors.accent.value,
          deadline: _deadline));
      } else {
        await DbService.updateGoal(
          widget.goal!.copyWith(name: _name.text.trim(), target: target, saved: saved, deadline: _deadline));
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    await DbService.deleteGoal(widget.goal!.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(context: context, initialDate: _deadline,
      firstDate: DateTime.now(), lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent, surface: AppColors.primary)), child: child!));
    if (p != null) setState(() => _deadline = p);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(Sp.lg),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.97),
          borderRadius: BorderRadius.circular(Rd.xxl),
          border: Border.all(color: AppColors.glassBorder)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.onDark.withOpacity(0.18), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: Sp.lg),
          Row(children: [
            Text(_isNew ? 'New Goal' : 'Edit Goal', style: AppText.h3),
            const Spacer(),
            if (!_isNew) GestureDetector(onTap: _delete,
              child: Text('Delete', style: TextStyle(
                color: AppColors.expense, fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: Sp.lg),
          _field(ctrl: _name,   hint: 'Goal name',           icon: Icons.flag_outlined,
            onChanged: () => setState(() {})),
          const SizedBox(height: Sp.sm),
          _field(ctrl: _target, hint: 'Target amount',        icon: Icons.track_changes_rounded,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            prefix: '\$', onChanged: () => setState(() {})),
          const SizedBox(height: Sp.sm),
          _field(ctrl: _saved,  hint: 'Amount saved so far',  icon: Icons.savings_outlined,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            prefix: '\$', onChanged: () {}),
          const SizedBox(height: Sp.sm),
          GestureDetector(onTap: _pickDate,
            child: GlassCard(padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 13),
              child: Row(children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.accent.withOpacity(0.65), size: 18),
                const SizedBox(width: Sp.md),
                Text('Deadline: ${_deadline.day}/${_deadline.month}/${_deadline.year}',
                  style: AppText.body.copyWith(fontSize: 13)),
                const Spacer(),
                Icon(Icons.edit_calendar_outlined, color: AppColors.onDark.withOpacity(0.30), size: 16),
              ]))),
          const SizedBox(height: Sp.xl),
          GestureDetector(onTap: (_canSave && !_saving) ? _save : null,
            child: AnimatedContainer(duration: const Duration(milliseconds: 180),
              height: 52, width: double.infinity,
              decoration: BoxDecoration(
                gradient: _canSave ? AppGradients.accent : null,
                color: _canSave ? null : AppColors.onDark.withOpacity(0.07),
                borderRadius: BorderRadius.circular(Rd.lg),
                boxShadow: _canSave ? AppShadows.goldGlow : null),
              child: Center(child: _saving
                ? const CircularProgressIndicator(color: AppColors.primaryDark, strokeWidth: 2.5)
                : Text(_isNew ? 'Create Goal' : 'Save Changes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: _canSave ? AppColors.primaryDark : AppColors.onDark.withOpacity(0.30)))))),
        ])));
  }

  Widget _field({required TextEditingController ctrl, required String hint,
      required IconData icon, TextInputType keyboard = TextInputType.text,
      String? prefix, required VoidCallback onChanged}) =>
    GlassCard(padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 13),
      child: Row(children: [
        Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
        const SizedBox(width: Sp.md),
        if (prefix != null) ...[
          Text(prefix, style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.50))),
          const SizedBox(width: 4),
        ],
        Expanded(child: TextField(controller: ctrl, keyboardType: keyboard,
          onChanged: (_) => onChanged(),
          style: AppText.body.copyWith(fontSize: 14),
          decoration: InputDecoration(hintText: hint,
            hintStyle: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.28), fontSize: 14),
            border: InputBorder.none, contentPadding: EdgeInsets.zero))),
      ]));
}