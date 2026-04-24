import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DbService
//
//  All Firestore reads and writes go through here.
//  Uses the currently-logged-in user's UID to scope
//  every collection under:  users/{uid}/{collection}
//
//  Pattern:
//    watch*()  → Stream — use in StreamBuilder for live updates
//    get*()    → Future — one-time read
//    add/update/delete* → Future<void> — writes
// ─────────────────────────────────────────────────────────────────────────────
class DbService {
  static final _db  = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ── Helpers ────────────────────────────────────────────────────────────────
  static String get _uid => _auth.currentUser?.uid ?? '';

  static CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(_uid).collection(name);

  // ══════════════════════════════════════════════════════════════════════════
  //  TRANSACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Live stream of all transactions, newest first
  static Stream<List<TransactionModel>> watchTransactions() =>
      _col('transactions')
          .orderBy('date', descending: true)
          .snapshots()
          .map((s) => s.docs.map(TransactionModel.fromFirestore).toList());

  /// One-time fetch
  static Future<List<TransactionModel>> getTransactions() async {
    final snap = await _col('transactions')
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map(TransactionModel.fromFirestore).toList();
  }

  /// Transactions for a specific month (used by Budget page)
  static Stream<List<TransactionModel>> watchTransactionsForMonth(
      int year, int month) {
    final start = DateTime(year, month, 1);
    final end   = DateTime(year, month + 1, 1);
    return _col('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map(TransactionModel.fromFirestore).toList());
  }

  /// Add a new transaction — returns the new document ID
  static Future<String> addTransaction(TransactionModel txn) async {
    final ref = await _col('transactions').add({
      ...txn.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Update an existing transaction
  static Future<void> updateTransaction(TransactionModel txn) =>
      _col('transactions').doc(txn.id).update(txn.toFirestore());

  /// Delete a transaction
  static Future<void> deleteTransaction(String id) =>
      _col('transactions').doc(id).delete();

  // ══════════════════════════════════════════════════════════════════════════
  //  BILLS
  // ══════════════════════════════════════════════════════════════════════════

  /// Live stream of all bills, ordered by due date
  static Stream<List<BillModel>> watchBills() =>
      _col('bills')
          .orderBy('dueDate')
          .snapshots()
          .map((s) => s.docs.map(BillModel.fromFirestore).toList());

  /// Bills for a specific month — sorted in-app to avoid composite index
  static Stream<List<BillModel>> watchBillsForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end   = DateTime(year, month + 1, 1);
    return _col('bills')
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) {
          final list = s.docs.map(BillModel.fromFirestore).toList();
          list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return list;
        });
  }

  static Future<String> addBill(BillModel bill) async {
    final ref = await _col('bills').add({
      ...bill.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Future<void> updateBill(BillModel bill) =>
      _col('bills').doc(bill.id).update(bill.toFirestore());

  static Future<void> markBillPaid(String id, bool isPaid) =>
      _col('bills').doc(id).update({
        'isPaid':    isPaid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  static Future<void> deleteBill(String id) =>
      _col('bills').doc(id).delete();

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVINGS GOALS
  // ══════════════════════════════════════════════════════════════════════════

  static Stream<List<SavingsGoalModel>> watchGoals() =>
      _col('savings_goals')
          .orderBy('deadline')
          .snapshots()
          .map((s) => s.docs.map(SavingsGoalModel.fromFirestore).toList());

  static Future<String> addGoal(SavingsGoalModel goal) async {
    final ref = await _col('savings_goals').add({
      ...goal.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Future<void> updateGoal(SavingsGoalModel goal) =>
      _col('savings_goals').doc(goal.id).update(goal.toFirestore());

  /// Add funds to a savings goal
  static Future<void> addFundsToGoal(String goalId, double additionalAmount) =>
      _col('savings_goals').doc(goalId).update({
        'saved':     FieldValue.increment(additionalAmount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  static Future<void> deleteGoal(String id) =>
      _col('savings_goals').doc(id).delete();

  // ══════════════════════════════════════════════════════════════════════════
  //  BUDGETS
  // ══════════════════════════════════════════════════════════════════════════

  /// Budgets for a given month string, e.g. "2026-04"
  static Stream<List<BudgetModel>> watchBudgetsForMonth(String month) =>
      _col('budgets')
          .where('month', isEqualTo: month)
          .snapshots()
          .map((s) => s.docs.map(BudgetModel.fromFirestore).toList());

  static Future<String> addBudget(BudgetModel budget) async {
    final ref = await _col('budgets').add({
      ...budget.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Future<void> updateBudget(BudgetModel budget) =>
      _col('budgets').doc(budget.id).update(budget.toFirestore());

  static Future<void> deleteBudget(String id) =>
      _col('budgets').doc(id).delete();

  // ══════════════════════════════════════════════════════════════════════════
  //  DASHBOARD HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Monthly income total
  static Future<double> getMonthlyIncome(int year, int month) async {
    final txns = await _getMonthlyTxns(year, month);
    return txns
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
  }

  /// Monthly expense total
  static Future<double> getMonthlyExpenses(int year, int month) async {
    final txns = await _getMonthlyTxns(year, month);
    return txns
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);
  }

  static Future<List<TransactionModel>> _getMonthlyTxns(
      int year, int month) async {
    final start = DateTime(year, month, 1);
    final end   = DateTime(year, month + 1, 1);
    final snap  = await _col('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();
    return snap.docs.map(TransactionModel.fromFirestore).toList();
  }

  /// Stream of the 5 most recent transactions (for home page)
  static Stream<List<TransactionModel>> watchRecentTransactions({int limit = 5}) =>
      _col('transactions')
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map(TransactionModel.fromFirestore).toList());

  /// Stream of upcoming unpaid bills (for home page) — sorted in-app
  static Stream<List<BillModel>> watchUpcomingBills({int limit = 3}) =>
      _col('bills')
          .where('isPaid', isEqualTo: false)
          .snapshots()
          .map((s) {
            final list = s.docs.map(BillModel.fromFirestore).toList();
            list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
            return list.take(limit).toList();
          });

  // ── Month string helper ────────────────────────────────────────────────────
  static String monthKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
}

extension on FutureOr<double> {
  FutureOr<double> operator +(double other) {
    if (this is Future<double>) {
      return (this as Future<double>).then((value) => value + other);
    } else {
      return (this as double) + other;
    }
  }
}