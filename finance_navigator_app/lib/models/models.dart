import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Transaction model
// ─────────────────────────────────────────────────────────────────────────────
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;       // 'expense' | 'income' | 'bill' | 'savings'
  final String category;
  final DateTime date;
  final String? note;
  final bool isRecurring;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.isRecurring = false,
  });

  bool get isExpense => type == 'expense' || type == 'bill';
  bool get isIncome  => type == 'income';

  Color get typeColor {
    switch (type) {
      case 'income':  return AppColors.income;
      case 'bill':    return AppColors.warning;
      case 'savings': return AppColors.accent;
      default:        return AppColors.expense;
    }
  }

  String get formattedAmount {
    final prefix = isIncome ? '+' : '-';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  // ── Firestore → model ──────────────────────────────────────────────────────
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id:          doc.id,
      title:       d['title']    as String? ?? '',
      amount:      (d['amount']  as num?)?.toDouble() ?? 0.0,
      type:        d['type']     as String? ?? 'expense',
      category:    d['category'] as String? ?? 'Other',
      date:        (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note:        d['note']     as String?,
      isRecurring: d['isRecurring'] as bool? ?? false,
    );
  }

  // ── model → Firestore ──────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'title':       title,
    'amount':      amount,
    'type':        type,
    'category':    category,
    'date':        Timestamp.fromDate(date),
    'note':        note,
    'isRecurring': isRecurring,
    'updatedAt':   FieldValue.serverTimestamp(),
  };

  TransactionModel copyWith({
    String? title, double? amount, String? type,
    String? category, DateTime? date, String? note, bool? isRecurring,
  }) => TransactionModel(
    id:          id,
    title:       title       ?? this.title,
    amount:      amount      ?? this.amount,
    type:        type        ?? this.type,
    category:    category    ?? this.category,
    date:        date        ?? this.date,
    note:        note        ?? this.note,
    isRecurring: isRecurring ?? this.isRecurring,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bill model
// ─────────────────────────────────────────────────────────────────────────────
class BillModel {
  final String id;
  String name;
  double amount;
  String category;
  String frequency;
  DateTime dueDate;
  bool isPaid;
  String? note;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.dueDate,
    required this.isPaid,
    this.note,
  });

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  String get dueDateLabel {
    final d = daysUntilDue;
    if (d < 0)  return 'Overdue by ${-d}d';
    if (d == 0) return 'Due today';
    if (d == 1) return 'Due tomorrow';
    return 'Due in ${d}d';
  }

  Color get statusColor {
    if (isPaid)           return AppColors.income;
    if (daysUntilDue < 0) return AppColors.expense;
    if (daysUntilDue <= 3) return AppColors.warning;
    return AppColors.accent;
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BillModel(
      id:        doc.id,
      name:      d['name']      as String? ?? '',
      amount:    (d['amount']   as num?)?.toDouble() ?? 0.0,
      category:  d['category']  as String? ?? 'Utilities',
      frequency: d['frequency'] as String? ?? 'Monthly',
      dueDate:   (d['dueDate']  as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid:    d['isPaid']    as bool? ?? false,
      note:      d['note']      as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':      name,
    'amount':    amount,
    'category':  category,
    'frequency': frequency,
    'dueDate':   Timestamp.fromDate(dueDate),
    'isPaid':    isPaid,
    'note':      note,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  BillModel copyWith({
    String? name, double? amount, String? category,
    String? frequency, DateTime? dueDate, bool? isPaid, String? note,
  }) => BillModel(
    id:        id,
    name:      name      ?? this.name,
    amount:    amount    ?? this.amount,
    category:  category  ?? this.category,
    frequency: frequency ?? this.frequency,
    dueDate:   dueDate   ?? this.dueDate,
    isPaid:    isPaid    ?? this.isPaid,
    note:      note      ?? this.note,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Savings Goal model
// ─────────────────────────────────────────────────────────────────────────────
class SavingsGoalModel {
  final String id;
  String emoji;
  String name;
  double target;
  double saved;
  int colorValue;   // stored as int (Color.value)
  DateTime deadline;
  String? note;

  SavingsGoalModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.target,
    required this.saved,
    required this.colorValue,
    required this.deadline,
    this.note,
  });

  Color  get color     => Color(colorValue);
  double get pct       => target > 0 ? (saved / target).clamp(0.0, 1.0) : 0;
  double get remaining => (target - saved).clamp(0.0, double.infinity);
  bool   get complete  => saved >= target;

  String get deadlineLabel {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[deadline.month - 1]} ${deadline.year}';
  }

  factory SavingsGoalModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SavingsGoalModel(
      id:         doc.id,
      emoji:      d['emoji']      as String? ?? '🎯',
      name:       d['name']       as String? ?? '',
      target:     (d['target']    as num?)?.toDouble() ?? 0.0,
      saved:      (d['saved']     as num?)?.toDouble() ?? 0.0,
      colorValue: d['colorValue'] as int?    ?? AppColors.accent.value,
      deadline:   (d['deadline']  as Timestamp?)?.toDate() ??
                  DateTime.now().add(const Duration(days: 180)),
      note:       d['note']       as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'emoji':      emoji,
    'name':       name,
    'target':     target,
    'saved':      saved,
    'colorValue': colorValue,
    'deadline':   Timestamp.fromDate(deadline),
    'note':       note,
    'updatedAt':  FieldValue.serverTimestamp(),
  };

  SavingsGoalModel copyWith({
    String? emoji, String? name, double? target,
    double? saved, int? colorValue, DateTime? deadline, String? note,
  }) => SavingsGoalModel(
    id:         id,
    emoji:      emoji      ?? this.emoji,
    name:       name       ?? this.name,
    target:     target     ?? this.target,
    saved:      saved      ?? this.saved,
    colorValue: colorValue ?? this.colorValue,
    deadline:   deadline   ?? this.deadline,
    note:       note       ?? this.note,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Budget model
// ─────────────────────────────────────────────────────────────────────────────
class BudgetModel {
  final String id;
  String category;
  double limit;
  String month;   // format: "2026-04"

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id:       doc.id,
      category: d['category'] as String? ?? 'Other',
      limit:    (d['limit']   as num?)?.toDouble() ?? 0.0,
      month:    d['month']    as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'category':  category,
    'limit':     limit,
    'month':     month,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  BudgetModel copyWith({String? category, double? limit, String? month}) =>
      BudgetModel(
        id:       id,
        category: category ?? this.category,
        limit:    limit    ?? this.limit,
        month:    month    ?? this.month,
      );
}