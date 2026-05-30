import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BudgetScreen — Tab 3 in the bottom navigation bar.
//
// Shows:
//   • Current monthly budget
//   • Total spent vs remaining this month
//   • Custom animated progress gauge
//   • Elegant over-budget warning card
//   • Button to set / update the budget
// ─────────────────────────────────────────────────────────────────────────────

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  static final _currency = NumberFormat.currency(symbol: '€');

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final expenses = context.watch<ExpenseProvider>();

    final spent = expenses.totalThisMonth;
    final currency = _currency;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient hero SliverAppBar ──────────────────────
          SliverAppBar(
            expandedHeight: budget.hasBudget ? 255 : 140,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0C0D14) : cs.primary,
            foregroundColor: isDark ? cs.onSurface : cs.onPrimary,
            elevation: 0,
            title: const Text(
              'Budget Mensuel',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            actions: [
              if (budget.hasBudget)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: (isDark ? cs.primary : Colors.white)
                          .withValues(alpha: 0.18),
                      foregroundColor: isDark ? cs.primary : Colors.white,
                    ),
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => _showBudgetDialog(context, budget),
                    tooltip: 'Modifier le budget',
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _BudgetHero(
                budget: budget,
                spent: spent,
                currency: currency,
              ),
            ),
          ),

          // ── Body content ────────────────────────────────
          budget.hasBudget
              ? SliverFillRemaining(
                  child: _BudgetBody(
                    budget: budget,
                    spent: spent,
                    currency: currency,
                  ),
                )
              : SliverFillRemaining(
                  child: _NoBudgetState(
                    onSet: () => _showBudgetDialog(context, budget),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Budget input dialog ───────────────────────────────────────────────────

  void _showBudgetDialog(BuildContext context, BudgetProvider budget) {
    final controller = TextEditingController(
      text: budget.hasBudget ? budget.monthlyBudget.toStringAsFixed(2) : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Définir le budget mensuel'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              prefixText: '€ ',
              labelText: 'Montant du budget',
              hintText: '1000.00',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Veuillez saisir un montant';
              }
              final n = double.tryParse(v.trim());
              if (n == null || n <= 0) {
                return 'Entrez un montant positif valide';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amount = double.parse(controller.text.trim());
              await budget.setBudget(amount);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BudgetHero — gradient banner shown in the expanded SliverAppBar
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetHero extends StatelessWidget {
  const _BudgetHero({
    required this.budget,
    required this.spent,
    required this.currency,
  });

  final BudgetProvider budget;
  final double spent;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOver = budget.hasBudget && budget.isOverBudget(spent);

    final gradientColors = isOver
        ? [cs.error, cs.error.withValues(alpha: 0.7)]
        : isDark
        ? [const Color(0xFF0C0D14), const Color(0xFF191B29)]
        : [cs.primary, cs.tertiary];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
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
                color: (isOver ? cs.errorContainer : cs.secondary).withValues(
                  alpha: 0.15,
                ),
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
                if (budget.hasBudget) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.08 : 0.14),
                          Colors.white.withValues(alpha: isDark ? 0.03 : 0.06),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isOver ? 'BUDGET DÉPASSÉ' : 'BUDGET MENSUEL',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Icon(
                              isOver
                                  ? Icons.warning_rounded
                                  : Icons.account_balance_wallet_outlined,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currency.format(budget.monthlyBudget),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isOver
                                  ? 'Dépassement de ${currency.format(spent - budget.monthlyBudget)}'
                                  : '${currency.format(spent)} dépensés  ·  ${currency.format(budget.remaining(spent))} restants',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
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
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isOver ? 'Alerte' : 'Actif',
                                style: const TextStyle(
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
                  const SizedBox(height: 38), // aligns expanded height spacing
                ] else ...[
                  Text(
                    'AUCUN BUDGET DÉFINI',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BudgetBody — progress ring and interactive stats grid.
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetBody extends StatelessWidget {
  const _BudgetBody({
    required this.budget,
    required this.spent,
    required this.currency,
  });

  final BudgetProvider budget;
  final double spent;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = budget.progress(spent);
    final remaining = budget.remaining(spent);
    final isOver = budget.isOverBudget(spent);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final progressColor = isOver ? cs.error : const Color(0xFF00C9A7);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CircularBudgetRing(
            progress: progress,
            spent: spent,
            budget: budget.monthlyBudget,
            currency: currency,
            color: progressColor,
            isOver: isOver,
          ),

          const SizedBox(height: 32),

          if (isOver) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(
                  alpha: isDark ? 0.16 : 0.65,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.error.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: cs.error, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alerte : Budget dépassé !',
                          style: TextStyle(
                            color: isDark ? Colors.redAccent : cs.error,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vous avez dépassé votre limite mensuelle de ${currency.format(spent - budget.monthlyBudget)}.',
                          style: TextStyle(
                            color: cs.onErrorContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          _StatRow(
            items: [
              _StatItem(
                label: 'Limite Budget',
                value: currency.format(budget.monthlyBudget),
                icon: Icons.account_balance_wallet_rounded,
                color: cs.primary,
              ),
              _StatItem(
                label: 'Total Dépensé',
                value: currency.format(spent),
                icon: Icons.shopping_cart_rounded,
                color: isOver ? cs.error : cs.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatRow(
            items: [
              _StatItem(
                label: isOver ? 'Excédent' : 'Solde Restant',
                value: currency.format(remaining.abs()),
                icon: isOver
                    ? Icons.trending_up_rounded
                    : Icons.savings_rounded,
                color: isOver ? cs.error : const Color(0xFF00C9A7),
              ),
              _StatItem(
                label: 'Budget Utilisé',
                value: '${(progress * 100).toStringAsFixed(1)}%',
                icon: Icons.pie_chart_rounded,
                color: cs.tertiary,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _HorizontalProgressBar(
            progress: progress,
            color: progressColor,
            label: isOver ? 'Budget dépassé !' : 'Progression globale ce mois',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CircularBudgetRing — Custom painted progress gauge.
// ─────────────────────────────────────────────────────────────────────────────

class _CircularBudgetRing extends StatelessWidget {
  const _CircularBudgetRing({
    required this.progress,
    required this.spent,
    required this.budget,
    required this.currency,
    required this.color,
    required this.isOver,
  });

  final double progress;
  final double spent;
  final double budget;
  final NumberFormat currency;
  final Color color;
  final bool isOver;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _BudgetCircularPainter(
                      progress: value,
                      color: color,
                      trackColor: isDark
                          ? const Color(0xFF1E1F30)
                          : cs.primary.withValues(alpha: 0.06),
                    ),
                  );
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currency.format(spent),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isOver
                        ? cs.error
                        : isDark
                        ? Colors.white
                        : cs.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'sur ${currency.format(budget)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCircularPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _BudgetCircularPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    const strokeWidth = 14.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * 3.141592653589793 * progress.clamp(0.0, 1.0);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BudgetCircularPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HorizontalProgressBar
// ─────────────────────────────────────────────────────────────────────────────

class _HorizontalProgressBar extends StatelessWidget {
  const _HorizontalProgressBar({
    required this.progress,
    required this.color,
    required this.label,
  });

  final double progress;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (_, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: cs.brightness == Brightness.dark
                  ? const Color(0xFF1E1F30)
                  : cs.primary.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat grid helpers
// ─────────────────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({required this.items});
  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(children: items.map((item) => Expanded(child: item)).toList());
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141524) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.12 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isDark ? Colors.white : cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoBudgetState
// ─────────────────────────────────────────────────────────────────────────────

class _NoBudgetState extends StatelessWidget {
  const _NoBudgetState({required this.onSet});
  final VoidCallback onSet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 48,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun budget défini',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Définissez un budget mensuel pour suivre vos dépenses et recevoir une alerte si vous le dépassez.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Définir un budget'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
