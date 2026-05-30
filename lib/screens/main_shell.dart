import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'add_edit_expense_screen.dart';
import 'budget_screen.dart';
import 'home_screen.dart';
import 'reports_screen.dart';

// ─────────────────────────────────────────────────────────────
// MainShell — root widget with an elegant floating bottom navigation.
//
// Four tabs:
//   0 — Home        (all expenses)
//   1 — Add Expense (form)
//   2 — Reports     (charts & summaries)
//   3 — Budget      (monthly budget tracker)
// ─────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Currently active tab index.
  int _currentIndex = 0;

  // Keep all four tab bodies alive so state (scroll position, etc.)
  // is preserved when the user switches tabs.
  static const _tabs = [
    HomeScreen(),
    _AddTab(),
    ReportsScreen(),
    BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody:
          true, // Allows content to scroll underneath the floating nav bar
      body: IndexedStack(index: _currentIndex, children: _tabs),

      // ── Premium Floating Bottom Navigation Bar ─────────────────────────────
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          height: 72,
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF141524) : Colors.white).withValues(
              alpha: 0.82,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: (isDark ? Colors.white : cs.primary).withValues(
                alpha: isDark ? 0.07 : 0.08,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : cs.primary).withValues(
                  alpha: isDark ? 0.45 : 0.06,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(
                      0,
                      Icons.home_rounded,
                      Icons.home_outlined,
                      'Accueil',
                      cs,
                    ),
                    _navItem(
                      1,
                      Icons.add_circle_rounded,
                      Icons.add_circle_outline_rounded,
                      'Ajouter',
                      cs,
                    ),
                    _navItem(
                      2,
                      Icons.bar_chart_rounded,
                      Icons.bar_chart_outlined,
                      'Rapports',
                      cs,
                    ),
                    _navItem(
                      3,
                      Icons.account_balance_wallet_rounded,
                      Icons.account_balance_wallet_outlined,
                      'Budget',
                      cs,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    ColorScheme cs,
  ) {
    final isSelected = _currentIndex == index;
    final isDark = cs.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withValues(alpha: isDark ? 0.16 : 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.65),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.65),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _AddTab — wraps AddEditExpenseScreen with its own Scaffold
// so it has an AppBar when shown as a tab.
// ─────────────────────────────────────────────────────────────

class _AddTab extends StatelessWidget {
  const _AddTab();

  @override
  Widget build(BuildContext context) {
    return const AddEditExpenseScreen();
  }
}
