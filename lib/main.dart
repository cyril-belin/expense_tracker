import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'data/database_helper.dart';
import 'providers/budget_provider.dart';
import 'providers/expense_provider.dart';
import 'screens/main_shell.dart';

// ─────────────────────────────────────────────────────────────
// main — app entry point.
// ─────────────────────────────────────────────────────────────

Future<void> main() async {
  // Required before calling any Flutter/plugin APIs in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise expense provider and load saved expenses from SQLite.
  final expenseProvider = ExpenseProvider();
  await expenseProvider.loadExpenses();

  // Seed sample data on the very first launch (empty database).
  final count = await DatabaseHelper.instance.countExpenses();
  if (count == 0) {
    await expenseProvider.seedSampleData();
  }

  // Initialise budget provider and load the saved budget amount.
  final budgetProvider = BudgetProvider();
  await budgetProvider.loadBudget();

  // Initialise French locale data for DateFormat.
  await initializeDateFormatting('fr_FR');

  runApp(
    // MultiProvider makes both providers available to the whole widget tree.
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: expenseProvider),
        ChangeNotifierProvider.value(value: budgetProvider),
      ],
      child: const SmartExpenseTrackerApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// SmartExpenseTrackerApp — root MaterialApp with light/dark theme.
// ─────────────────────────────────────────────────────────────

class SmartExpenseTrackerApp extends StatelessWidget {
  const SmartExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suivi de dépenses',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}
