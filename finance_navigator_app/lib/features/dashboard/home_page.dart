import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // ── Background orbs ──────────────────────────
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),

          // ── Main scrollable content ────────────────────
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Sp.lg,
                Sp.lg,
                Sp.lg,
                120, // Extra padding for bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header: Welcome + Date + Notification ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, User',
                            style: AppText.h2.copyWith(
                              color: AppColors.onDark,
                            ),
                          ),
                          const SizedBox(height: Sp.xs),
                          Text(
                            DateFormat('EEEE, MMM d').format(_selectedDate),
                            style: AppText.body.copyWith(
                              color: AppColors.onDark.withOpacity(0.60),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // Show notification menu
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(Rd.lg),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.accent,
                                size: 24,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.income,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Total Balance Card ────────────────────
                  GlassCard.gold(
                    padding: const EdgeInsets.all(Sp.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: AppText.label.copyWith(
                            color: AppColors.accent.withOpacity(0.80),
                          ),
                        ),
                        const SizedBox(height: Sp.md),
                        const Text(
                          '\$12,458.50',
                          style: AppText.moneyLarge,
                        ),
                        const SizedBox(height: Sp.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBalanceItem(
                                label: 'Savings',
                                amount: '\$8,250.00',
                                color: AppColors.income,
                              ),
                            ),
                            const SizedBox(width: Sp.md),
                            Expanded(
                              child: _buildBalanceItem(
                                label: 'Checking',
                                amount: '\$4,208.50',
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Income vs Expense Summary ──────────────
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(Sp.lg),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Income',
                                style: AppText.label.copyWith(
                                  color: AppColors.income,
                                ),
                              ),
                              const SizedBox(height: Sp.md),
                              const Text(
                                '\$4,500',
                                style: AppText.money,
                              ),
                              const SizedBox(height: Sp.sm),
                              Text(
                                '+12% vs last month',
                                style: AppText.caption.copyWith(
                                  color: AppColors.income,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(Sp.lg),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expenses',
                                style: AppText.label.copyWith(
                                  color: AppColors.expense,
                                ),
                              ),
                              const SizedBox(height: Sp.md),
                              const Text(
                                '\$2,150',
                                style: AppText.money,
                              ),
                              const SizedBox(height: Sp.sm),
                              Text(
                                '-8% vs last month',
                                style: AppText.caption.copyWith(
                                  color: AppColors.income,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Quick Actions ──────────────────────────
                  Text(
                    'Quick Actions',
                    style: AppText.h3.copyWith(
                      color: AppColors.onDark,
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Income',
                        onTap: () {},
                      ),
                      _buildQuickActionButton(
                        icon: Icons.remove_circle_outline,
                        label: 'Expense',
                        onTap: () {},
                      ),
                      _buildQuickActionButton(
                        icon: Icons.event_note_outlined,
                        label: 'Bill',
                        onTap: () {},
                      ),
                      _buildQuickActionButton(
                        icon: Icons.savings_outlined,
                        label: 'Savings',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Savings Progress ───────────────────────
                  Text(
                    'Savings Goal',
                    style: AppText.h3.copyWith(
                      color: AppColors.onDark,
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  GlassCard(
                    padding: const EdgeInsets.all(Sp.lg),
                    child: Row(
                      children: [
                        // Circular progress
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 0.65,
                                strokeWidth: 8,
                                backgroundColor: AppColors.onDark
                                    .withOpacity(0.10),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  AppColors.income,
                                ),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '65%',
                                    style: AppText.h3.copyWith(
                                      color: AppColors.income,
                                    ),
                                  ),
                                  Text(
                                    'of goal',
                                    style: AppText.caption.copyWith(
                                      color: AppColors.onDark
                                          .withOpacity(0.60),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Sp.lg),
                        // Progress details
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vacation Fund',
                                style: AppText.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onDark,
                                ),
                              ),
                              const SizedBox(height: Sp.sm),
                              Text(
                                '\$6,500 / \$10,000',
                                style: AppText.money.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: Sp.md),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(Rd.sm),
                                child:
                                    LinearProgressIndicator(
                                  value: 0.65,
                                  minHeight: 4,
                                  backgroundColor: AppColors
                                      .onDark
                                      .withOpacity(0.10),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Budget Status ──────────────────────────
                  Text(
                    'Budget Status',
                    style: AppText.h3.copyWith(
                      color: AppColors.onDark,
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  _buildBudgetItem(
                    label: 'Food & Dining',
                    spent: 320,
                    budget: 500,
                    icon: Icons.restaurant_outlined,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: Sp.md),
                  _buildBudgetItem(
                    label: 'Transportation',
                    spent: 180,
                    budget: 250,
                    icon: Icons.directions_car_outlined,
                    color: AppColors.income,
                  ),
                  const SizedBox(height: Sp.md),
                  _buildBudgetItem(
                    label: 'Entertainment',
                    spent: 150,
                    budget: 200,
                    icon: Icons.movie_outlined,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Recent Transactions ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: AppText.h3.copyWith(
                          color: AppColors.onDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'View All',
                          style: AppText.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.md),
                  _buildTransactionItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Grocery Store',
                    date: 'Today at 2:30 PM',
                    amount: '-\$45.99',
                    isExpense: true,
                  ),
                  const SizedBox(height: Sp.md),
                  _buildTransactionItem(
                    icon: Icons.work_outline,
                    label: 'Salary Deposit',
                    date: 'Yesterday',
                    amount: '+\$3,500.00',
                    isExpense: false,
                  ),
                  const SizedBox(height: Sp.md),
                  _buildTransactionItem(
                    icon: Icons.local_cafe_outlined,
                    label: 'Coffee Shop',
                    date: 'Mar 19',
                    amount: '-\$5.50',
                    isExpense: true,
                  ),
                  const SizedBox(height: Sp.xl),

                  // ── Upcoming Bills ─────────────────────────
                  Text(
                    'Upcoming Bills',
                    style: AppText.h3.copyWith(
                      color: AppColors.onDark,
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  _buildBillItem(
                    provider: 'Electricity Bill',
                    amount: '\$125.00',
                    dueDate: 'Due in 5 days',
                    status: 'Pending',
                    icon: Icons.flash_on_outlined,
                  ),
                  const SizedBox(height: Sp.md),
                  _buildBillItem(
                    provider: 'Internet Service',
                    amount: '\$59.99',
                    dueDate: 'Due in 8 days',
                    status: 'Pending',
                    icon: Icons.wifi_outlined,
                  ),
                  const SizedBox(height: Sp.md),
                  _buildBillItem(
                    provider: 'Gym Membership',
                    amount: '\$49.99',
                    dueDate: 'Due Tomorrow',
                    status: 'Urgent',
                    icon: Icons.fitness_center_outlined,
                  ),
                ],
              ),
            ),
          ),

          // ── Glasscard Bottom Navigation Bar ────────────
          Positioned(
            bottom: Sp.lg,
            left: Sp.lg,
            right: Sp.lg,
            child: _buildGlassBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.caption.copyWith(
            color: AppColors.onDark.withOpacity(0.60),
          ),
        ),
        const SizedBox(height: Sp.sm),
        Text(
          amount,
          style: AppText.h3.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.3),
                  AppColors.accent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.4),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(Rd.lg),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: Sp.sm),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: AppColors.onDark.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem({
    required String label,
    required double spent,
    required double budget,
    required IconData icon,
    required Color color,
  }) {
    double percentage = spent / budget;
    String percentStr = (percentage * 100).toStringAsFixed(0);

    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(Rd.md),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.body.copyWith(
                        color: AppColors.onDark,
                      ),
                    ),
                    const SizedBox(height: Sp.xs),
                    Text(
                      '\$${spent.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}',
                      style: AppText.caption.copyWith(
                        color: AppColors.onDark.withOpacity(0.60),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentStr%',
                style: AppText.body.copyWith(
                  color: percentage > 0.8 ? AppColors.expense : color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(Rd.sm),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.onDark.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.8 ? AppColors.expense : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String label,
    required String date,
    required String amount,
    required bool isExpense,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isExpense
                      ? AppColors.expense
                      : AppColors.income)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(Rd.md),
            ),
            child: Icon(
              icon,
              color: isExpense
                  ? AppColors.expense
                  : AppColors.income,
              size: 22,
            ),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.body.copyWith(
                    color: AppColors.onDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: Sp.xs),
                Text(
                  date,
                  style: AppText.caption.copyWith(
                    color: AppColors.onDark.withOpacity(0.60),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppText.body.copyWith(
              color: isExpense
                  ? AppColors.expense
                  : AppColors.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem({
    required String provider,
    required String amount,
    required String dueDate,
    required String status,
    required IconData icon,
  }) {
    bool isUrgent = status == 'Urgent';

    return GlassCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isUrgent ? AppColors.expense : AppColors.accent)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(Rd.md),
            ),
            child: Icon(
              icon,
              color:
                  isUrgent ? AppColors.expense : AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider,
                  style: AppText.body.copyWith(
                    color: AppColors.onDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: Sp.xs),
                Text(
                  dueDate,
                  style: AppText.caption.copyWith(
                    color: isUrgent
                        ? AppColors.expense
                        : AppColors.onDark.withOpacity(0.60),
                    fontWeight: isUrgent ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppText.body.copyWith(
              color: AppColors.onDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Rd.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(Rd.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.analytics_outlined,
                label: 'Analytics',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.credit_card_outlined,
                label: 'Cards',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Sp.md,
          horizontal: Sp.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.accent
                  : AppColors.onDark.withOpacity(0.50),
              size: 24,
            ),
            const SizedBox(height: Sp.xs),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: isActive
                    ? AppColors.accent
                    : AppColors.onDark.withOpacity(0.50),
                fontWeight: isActive ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
