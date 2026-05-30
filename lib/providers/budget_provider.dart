import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BudgetProvider — manages the user's monthly budget amount.
//
// • The budget is stored with SharedPreferences so it survives app restarts.
// • Any widget that calls context.watch<BudgetProvider>() rebuilds
//   automatically whenever the budget changes.
// ─────────────────────────────────────────────────────────────────────────────

class BudgetProvider extends ChangeNotifier {
  // The key used to read/write the budget in SharedPreferences.
  static const _kBudgetKey = 'monthly_budget';

  // Internal budget value; starts at 0 until loaded from storage.
  double _monthlyBudget = 0;

  /// The current monthly budget amount set by the user.
  double get monthlyBudget => _monthlyBudget;

  /// True when the user has set a budget greater than zero.
  bool get hasBudget => _monthlyBudget > 0;

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Reads the saved budget from SharedPreferences.
  /// Call this once during app startup (in main()).
  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    // getDouble returns null if the key has never been written.
    _monthlyBudget = prefs.getDouble(_kBudgetKey) ?? 0;
    notifyListeners();
  }

  /// Saves a new [amount] and notifies all listening widgets.
  Future<void> setBudget(double amount) async {
    _monthlyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kBudgetKey, amount);
    notifyListeners();
  }

  // ── Derived values (require the current month's spending) ─────────────────

  /// How much of the budget has been spent this month.
  /// [spent] is provided by ExpenseProvider.totalThisMonth.
  double remaining(double spent) => _monthlyBudget - spent;

  /// A value between 0.0 and 1.0 representing budget usage.
  /// Capped at 1.0 even when over budget.
  double progress(double spent) {
    if (_monthlyBudget <= 0) return 0;
    return (spent / _monthlyBudget).clamp(0.0, 1.0);
  }

  /// True when this month's spending exceeds the budget.
  bool isOverBudget(double spent) =>
      _monthlyBudget > 0 && spent > _monthlyBudget;
}
