import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});
  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final List<_Goal> _goals = [
    _Goal('✈️', 'Vacation Fund',   3000, 1200, AppColors.accent,              DateTime(2026, 7)),
    _Goal('🔒', 'Emergency Fund', 10000, 6500, AppColors.income,              DateTime(2026, 12)),
    _Goal('🚗', 'New Car',        10000,  850, const Color(0xFF4A9EE8),        DateTime(2027, 3)),
  ];

  double get _totalSaved => _goals.fold(0, (s, g) => s + g.saved);

  void _showAddGoal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddGoalSheet(
        onAdd: (goal) {
          setState(() => _goals.add(goal));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddFunds(_Goal goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddFundsSheet(
        goal: goal,
        onAdd: (amount) {
          setState(() {
            final i = _goals.indexOf(goal);
            _goals[i] = goal.withSaved(goal.saved + amount);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          Positioned(
            top: -60, right: -40,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.income.withOpacity(0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.md, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Savings Goals', style: AppText.h2),
                      GestureDetector(
                        onTap: _showAddGoal,
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
                    ],
                  ),
                  const SizedBox(height: Sp.md),

                  // ── Summary card ──────────────────────
                  GlassCard(
                    padding: const EdgeInsets.all(Sp.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL SAVED',
                                  style: AppText.caption.copyWith(
                                      letterSpacing: 0.8, fontSize: 10)),
                              const SizedBox(height: 3),
                              Text(
                                '\$${_totalSaved.toInt()}',
                                style: AppText.moneyLarge.copyWith(
                                    color: AppColors.accent),
                              ),
                              Text('across ${_goals.length} goals',
                                  style: AppText.caption.copyWith(
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1, height: 50,
                          color: AppColors.glassBorder,
                          margin: const EdgeInsets.symmetric(horizontal: Sp.md),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('THIS MONTH',
                                  style: AppText.caption.copyWith(
                                      letterSpacing: 0.8, fontSize: 10)),
                              const SizedBox(height: 3),
                              const Text('+\$350',
                                  style: TextStyle(
                                    color: AppColors.income,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  )),
                              Text('contributed',
                                  style: AppText.caption.copyWith(
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sp.lg),

                  // ── Goal cards ────────────────────────
                  ..._goals.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: Sp.md),
                      child: _GoalCard(
                        goal: g,
                        onAddFunds: () => _showAddFunds(g),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────
class _Goal {
  final String emoji, name;
  final double target, saved;
  final Color color;
  final DateTime deadline;

  const _Goal(
      this.emoji, this.name, this.target, this.saved, this.color, this.deadline);

  double get pct => saved / target;
  double get remaining => target - saved;

  _Goal withSaved(double newSaved) =>
      _Goal(emoji, name, target, newSaved.clamp(0, target), color, deadline);

  String get deadlineLabel {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[deadline.month - 1]} ${deadline.year}';
  }
}

// ─────────────────────────────────────────────
//  Goal card
// ─────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final _Goal goal;
  final VoidCallback onAddFunds;
  const _GoalCard({required this.goal, required this.onAddFunds});

  @override
  Widget build(BuildContext context) {
    final pct = goal.pct;
    final complete = pct >= 1.0;

    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                    child: Text(goal.emoji,
                        style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),

              // Name + deadline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: AppText.body.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('Target: ${goal.deadlineLabel}',
                        style: AppText.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),

              // Percentage badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.14),
                  border: Border.all(color: goal.color.withOpacity(0.25)),
                  borderRadius: Rd.chip,
                ),
                child: Text(
                  complete ? '✓ Done' : '${(pct * 100).toInt()}%',
                  style: TextStyle(
                    color: goal.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColors.onDark.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            ),
          ),
          const SizedBox(height: 6),

          // Amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${goal.saved.toInt()} saved',
                  style: AppText.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onDark.withOpacity(0.70))),
              Text('\$${goal.target.toInt()} goal',
                  style: AppText.caption.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: Sp.sm),

          // Action row
          if (!complete)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.10),
                      border: Border.all(color: goal.color.withOpacity(0.20)),
                      borderRadius: BorderRadius.circular(Rd.sm),
                    ),
                    child: Text(
                      '\$${goal.remaining.toInt()} to go',
                      style: TextStyle(
                        color: goal.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: Sp.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: onAddFunds,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: AppGradients.accent,
                        borderRadius: BorderRadius.circular(Rd.sm),
                      ),
                      child: const Text(
                        'Add Funds',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.income.withOpacity(0.12),
                border: Border.all(color: AppColors.income.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(Rd.sm),
              ),
              child: const Text(
                '🎉 Goal achieved!',
                style: TextStyle(
                    color: AppColors.income,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Add Funds sheet
// ─────────────────────────────────────────────
class _AddFundsSheet extends StatefulWidget {
  final _Goal goal;
  final ValueChanged<double> onAdd;
  const _AddFundsSheet({required this.goal, required this.onAdd});
  @override
  State<_AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<_AddFundsSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_ctrl.text) ?? 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12,
          12 + MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(Sp.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.96),
          borderRadius: BorderRadius.circular(Rd.xxl),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.onDark.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Sp.md),
            Row(children: [
              Text(widget.goal.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text('Add to ${widget.goal.name}', style: AppText.h3),
            ]),
            const SizedBox(height: Sp.lg),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
              child: Row(children: [
                Text('\$', style: TextStyle(color: widget.goal.color,
                    fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _ctrl,
                  onChanged: (_) => setState(() {}),
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: widget.goal.color,
                      fontSize: 20, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                        color: AppColors.onDark.withOpacity(0.25), fontSize: 20),
                    border: InputBorder.none, contentPadding: EdgeInsets.zero),
                )),
              ]),
            ),
            const SizedBox(height: Sp.lg),
            GestureDetector(
              onTap: amount > 0 ? () => widget.onAdd(amount) : null,
              child: Container(
                height: 50, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: amount > 0 ? AppGradients.accent : null,
                  color: amount > 0 ? null : AppColors.onDark.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(Rd.lg),
                ),
                child: Center(child: Text('Add Funds',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: amount > 0
                          ? AppColors.primaryDark
                          : AppColors.onDark.withOpacity(0.30),
                    ))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Add New Goal sheet
// ─────────────────────────────────────────────
class _AddGoalSheet extends StatefulWidget {
  final ValueChanged<_Goal> onAdd;
  const _AddGoalSheet({required this.onAdd});
  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _nameCtrl   = TextEditingController();
  final _targetCtrl = TextEditingController();
  String _emoji = '🎯';
  final _emojis = ['🎯','✈️','🚗','🏠','💍','🎓','🔒','💻','🎮','⛵'];

  @override
  void dispose() { _nameCtrl.dispose(); _targetCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final canAdd = _nameCtrl.text.isNotEmpty &&
        (double.tryParse(_targetCtrl.text) ?? 0) > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12,
          12 + MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(Sp.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.96),
          borderRadius: BorderRadius.circular(Rd.xxl),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.onDark.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Sp.md),
            const Text('New Savings Goal', style: AppText.h3),
            const SizedBox(height: Sp.lg),

            // Emoji picker
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final e = _emojis[i];
                  final sel = _emoji == e;
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: sel ? AppColors.accent.withOpacity(0.18) : AppColors.glassWhite,
                        border: Border.all(
                            color: sel ? AppColors.accent.withOpacity(0.40) : AppColors.glassBorder,
                            width: sel ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Sp.md),

            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                style: AppText.body.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Goal name',
                  hintStyle: AppText.body.copyWith(
                      color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
                  border: InputBorder.none, contentPadding: EdgeInsets.zero),
              ),
            ),
            const SizedBox(height: Sp.sm),

            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
              child: Row(children: [
                Text('\$', style: AppText.body.copyWith(
                    color: AppColors.accent.withOpacity(0.7))),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _targetCtrl,
                  onChanged: (_) => setState(() {}),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppText.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Target amount',
                    hintStyle: AppText.body.copyWith(
                        color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
                    border: InputBorder.none, contentPadding: EdgeInsets.zero),
                )),
              ]),
            ),
            const SizedBox(height: Sp.lg),

            GestureDetector(
              onTap: canAdd ? () => widget.onAdd(_Goal(
                _emoji, _nameCtrl.text,
                double.parse(_targetCtrl.text), 0,
                AppColors.accent, DateTime.now().add(const Duration(days: 180)),
              )) : null,
              child: Container(
                height: 50, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: canAdd ? AppGradients.accent : null,
                  color: canAdd ? null : AppColors.onDark.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(Rd.lg),
                ),
                child: Center(child: Text('Create Goal',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: canAdd ? AppColors.primaryDark : AppColors.onDark.withOpacity(0.30),
                    ))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}