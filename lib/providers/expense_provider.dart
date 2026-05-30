import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/expense.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExpenseProvider — the single source of truth for all expense data.
//
// • Extends ChangeNotifier so any widget that calls
//   context.watch<ExpenseProvider>() automatically rebuilds when notifyListeners()
//   is called.
// • Talks to DatabaseHelper for persistence; the UI never touches the DB directly.
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseProvider extends ChangeNotifier {
  /// In-memory copy of all expenses, newest-first.
  List<Expense> _expenses = [];

  /// Public read-only view of the list.
  List<Expense> get expenses => List.unmodifiable(_expenses);

  // ── Aggregate totals ────────────────────────────────────────────────────────

  /// Sum of all stored expenses.
  double get totalAll => _expenses.fold(0, (sum, e) => sum + e.amount);

  /// Sum of expenses whose date matches today.
  double get totalToday {
    final today = DateTime.now();
    return _expenses
        .where(
          (e) =>
              e.date.year == today.year &&
              e.date.month == today.month &&
              e.date.day == today.day,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Sum of expenses within the current calendar week (Mon–Sun).
  double get totalThisWeek {
    final now = DateTime.now();
    // weekday: Mon = 1 … Sun = 7
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return _expenses
        .where(
          (e) => !e.date.isBefore(startOfWeek) && e.date.isBefore(endOfWeek),
        )
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Sum of expenses within the current calendar month.
  double get totalThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  // ── Category breakdown ──────────────────────────────────────────────────────

  /// Returns a map of { category → total amount } for expenses this month.
  /// Used to populate the pie chart.
  Map<ExpenseCategory, double> get monthlyByCategory {
    final now = DateTime.now();
    final result = <ExpenseCategory, double>{};
    for (final cat in ExpenseCategory.values) {
      result[cat] = 0;
    }
    for (final e in _expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        result[e.category] = (result[e.category] ?? 0) + e.amount;
      }
    }
    return result;
  }

  // ── Weekly trend ────────────────────────────────────────────────────────────

  /// Returns a list of 7 daily totals starting from the beginning of the
  /// current week (Monday). Index 0 = Monday, index 6 = Sunday.
  List<double> get weeklyDailyTotals {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return _expenses
          .where(
            (e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day,
          )
          .fold(0.0, (sum, e) => sum + e.amount);
    });
  }

  // ── Database operations ─────────────────────────────────────────────────────

  /// Loads all rows from SQLite into [_expenses].
  /// Call this once at app startup from [main].
  Future<void> loadExpenses() async {
    _expenses = await DatabaseHelper.instance.fetchAllExpenses();
    notifyListeners();
  }

  /// Persists a new expense and refreshes the in-memory list.
  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.instance.insertExpense(expense);
    await loadExpenses(); // reload so sorting stays correct
  }

  /// Saves changes to an existing expense.
  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.updateExpense(expense);
    await loadExpenses();
  }

  /// Removes an expense by its [id].
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await DatabaseHelper.instance.deleteExpense(id);
  }

  // ── Sample data ─────────────────────────────────────────────────────────────

  /// Inserts realistic sample expenses on first launch so charts and lists
  /// look meaningful out of the box.
  Future<void> seedSampleData() async {
    final now = DateTime.now();

    // Helper to create a date relative to today.
    DateTime daysAgo(int n) => now.subtract(Duration(days: n));

    final samples = [
      Expense(
        name: 'Courses alimentaires',
        amount: 54.30,
        date: daysAgo(0),
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Café & viennoiserie',
        amount: 8.50,
        date: daysAgo(0),
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Pass Navigo',
        amount: 25.00,
        date: daysAgo(1),
        category: ExpenseCategory.travel,
      ),
      Expense(
        name: 'Facture électricité',
        amount: 78.00,
        date: daysAgo(2),
        category: ExpenseCategory.bills,
      ),
      Expense(
        name: 'Vêtements en ligne',
        amount: 120.00,
        date: daysAgo(3),
        category: ExpenseCategory.shopping,
      ),
      Expense(
        name: 'Déjeuner équipe',
        amount: 32.50,
        date: daysAgo(3),
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Course en taxi',
        amount: 18.75,
        date: daysAgo(4),
        category: ExpenseCategory.travel,
      ),
      Expense(
        name: 'Netflix',
        amount: 15.99,
        date: daysAgo(5),
        category: ExpenseCategory.bills,
      ),
      Expense(
        name: 'Librairie',
        amount: 42.00,
        date: daysAgo(6),
        category: ExpenseCategory.shopping,
      ),
      Expense(
        name: 'Dîner au restaurant',
        amount: 65.00,
        date: daysAgo(7),
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Billet d’avion',
        amount: 310.00,
        date: daysAgo(8),
        category: ExpenseCategory.travel,
      ),
      Expense(
        name: 'Facture internet',
        amount: 49.99,
        date: daysAgo(10),
        category: ExpenseCategory.bills,
      ),
      Expense(
        name: 'Chaussures',
        amount: 89.00,
        date: daysAgo(12),
        category: ExpenseCategory.shopping,
      ),
      Expense(
        name: 'Supermarché',
        amount: 61.20,
        date: daysAgo(14),
        category: ExpenseCategory.food,
      ),
      Expense(
        name: 'Train vers la ville',
        amount: 12.00,
        date: daysAgo(15),
        category: ExpenseCategory.travel,
      ),
    ];

    for (final s in samples) {
      await DatabaseHelper.instance.insertExpense(s);
    }
    await loadExpenses();
  }
}
