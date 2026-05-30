import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

// ─────────────────────────────────────────────────────────────
// ReportsScreen — Tab 2
// Shows today / week / month totals, a pie chart by category,
// and a bar chart for daily spending this week.
// ─────────────────────────────────────────────────────────────

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static final _currency = NumberFormat.currency(symbol: '€');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final currency = _currency;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient hero AppBar ───────────────────────────
          SliverAppBar(
            expandedHeight: 255,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF0C0D14) : cs.primary,
            foregroundColor: isDark ? cs.onSurface : cs.onPrimary,
            elevation: 0,
            title: const Text(
              'Rapports',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0C0D14), const Color(0xFF191B29)]
                        : [cs.primary, cs.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: 40,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer.withValues(alpha: 0.15),
                        ),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 84, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(
                                    alpha: isDark ? 0.08 : 0.14,
                                  ),
                                  Colors.white.withValues(
                                    alpha: isDark ? 0.03 : 0.06,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: isDark ? 0.12 : 0.22,
                                ),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'DÉPENSES CE MOIS-CI',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    Icon(
                                      Icons.analytics_outlined,
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currency.format(provider.totalThisMonth),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Cette semaine : ${currency.format(provider.totalThisWeek)}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Rapports d\'activité',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtle empty padding to align size with other headers
                          const SizedBox(height: 38),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────
          SliverPadding(
            // Extra bottom padding to avoid bottom navigation bar overlap
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 115),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stat cards
                _SummaryRow(provider: provider, currency: currency),
                const SizedBox(height: 28),

                // Pie chart
                const _SectionTitle(title: 'Ce mois par catégorie'),
                const SizedBox(height: 12),
                _PieChartCard(provider: provider, currency: currency),
                const SizedBox(height: 28),

                // Bar chart
                const _SectionTitle(title: 'Dépenses journalières cette semaine'),
                const SizedBox(height: 12),
                _BarChartCard(provider: provider),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _SummaryRow — three stat cards side by side.
// ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.provider, required this.currency});
  final ExpenseProvider provider;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: "Aujourd'hui",
          value: currency.format(provider.totalToday),
          icon: Icons.today_rounded,
          color: const Color(0xFFFF5E5E),
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Semaine',
          value: currency.format(provider.totalThisWeek),
          icon: Icons.date_range_rounded,
          color: const Color(0xFF6C5CE7),
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Ce mois',
          value: currency.format(provider.totalThisMonth),
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF00C9A7),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF141524) : Colors.white).withValues(
            alpha: isDark ? 0.45 : 0.65,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.25 : 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isDark ? Colors.white : cs.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _PieChartCard — spending split by category this month.
// ─────────────────────────────────────────────────────────────

class _PieChartCard extends StatefulWidget {
  const _PieChartCard({required this.provider, required this.currency});
  final ExpenseProvider provider;
  final NumberFormat currency;

  @override
  State<_PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<_PieChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final byCategory = widget.provider.monthlyByCategory;
    final entries = byCategory.entries.where((e) => e.value > 0).toList();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (entries.isEmpty) {
      return const _EmptyChartPlaceholder(
        message: 'Aucune dépense enregistrée ce mois-ci.',
      );
    }

    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    // Build doughnut slices
    final sections = entries.asMap().entries.map((entry) {
      final i = entry.key;
      final cat = entry.value.key;
      final amount = entry.value.value;
      final isTouched = i == _touchedIndex;
      final pct = total > 0 ? (amount / total * 100) : 0;

      return PieChartSectionData(
        value: amount,
        color: cat.color,
        // Thick doughnut ring
        radius: isTouched ? 48 : 38,
        title: '${pct.toStringAsFixed(0)}%',
        showTitle: isTouched, // Show percentage only on tap for a cleaner UI
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
        ),
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF141524) : Colors.white).withValues(
              alpha: isDark ? 0.45 : 0.65,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? Colors.white : cs.primary).withValues(
                alpha: isDark ? 0.08 : 0.12,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Doughnut Chart with center text
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 65,
                        sectionsSpace: 3,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                      ),
                    ),
                    // Central information
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.currency.format(total),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Vertical progress legend items
              Column(
                children: entries.map((e) {
                  return _LegendItem(
                    category: e.key,
                    amount: e.value,
                    total: total,
                    currency: widget.currency,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final double total;
  final NumberFormat currency;

  const _LegendItem({
    required this.category,
    required this.amount,
    required this.total,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (amount / total) : 0.0;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${category.emoji}  ${category.label}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                currency.format(amount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${(pct * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: isDark
                  ? const Color(0xFF1E1F30)
                  : cs.primary.withValues(alpha: 0.04),
              valueColor: AlwaysStoppedAnimation<Color>(category.color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _BarChartCard — daily totals for Mon–Sun of the current week.
// ─────────────────────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.provider});
  final ExpenseProvider provider;

  static const _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyTotals = provider.weeklyDailyTotals;
    final maxY = dailyTotals.reduce((a, b) => a > b ? a : b);

    if (maxY == 0) {
      return const _EmptyChartPlaceholder(
        message: 'Aucune dépense enregistrée cette semaine.',
      );
    }

    final barGroups = List.generate(7, (i) {
      final isToday = i == DateTime.now().weekday - 1;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: dailyTotals[i],
            // Gradient fill for bars
            gradient: LinearGradient(
              colors: isToday
                  ? [cs.primary, cs.primary.withValues(alpha: 0.7)]
                  : [
                      cs.primary.withValues(alpha: isDark ? 0.35 : 0.28),
                      cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 18,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      );
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 22, 16, 12),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF141524) : Colors.white).withValues(
              alpha: isDark ? 0.45 : 0.65,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? Colors.white : cs.primary).withValues(
                alpha: isDark ? 0.08 : 0.12,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2, // leave some headroom
                barGroups: barGroups,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: cs.outlineVariant.withValues(
                      alpha: isDark ? 0.15 : 0.35,
                    ),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '\$${value.toInt()}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final isToday =
                            value.toInt() == DateTime.now().weekday - 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _days[value.toInt()],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isToday
                                  ? cs.primary
                                  : cs.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    
                  ),
                  rightTitles: const AxisTitles(
                    
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        (isDark ? const Color(0xFF26283C) : cs.inverseSurface)
                            .withValues(alpha: 0.95),
                    tooltipRoundedRadius: 10,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    tooltipMargin: 8,
                    getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                      '\$${rod.toY.toStringAsFixed(2)}',
                      TextStyle(
                        color: isDark ? Colors.white : cs.onInverseSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.tertiary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _EmptyChartPlaceholder extends StatelessWidget {
  const _EmptyChartPlaceholder({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141524) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.05)),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
