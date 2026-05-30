import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

// ─────────────────────────────────────────────────────────────
// AddEditExpenseScreen — Tab 1 (Add) and also opened from HomeScreen (Edit).
//
// When [expense] is null → "Add" mode.
// When [expense] is provided → "Edit" mode with pre-filled fields.
// ─────────────────────────────────────────────────────────────

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key, this.expense});

  /// Pass an existing expense to switch into edit mode.
  final Expense? expense;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  // ── Form state ────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields when editing an existing expense.
    final e = widget.expense;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController(
      text: e != null ? e.amount.toStringAsFixed(2) : '',
    );
    _selectedDate = e?.date ?? DateTime.now();
    _selectedCategory = e?.category ?? ExpenseCategory.food;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Submit ────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExpenseProvider>();

    final expense = Expense(
      id: widget.expense?.id,
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      date: _selectedDate,
      category: _selectedCategory,
    );

    if (_isEditing) {
      await provider.updateExpense(expense);
    } else {
      await provider.addExpense(expense);
    }

    if (!mounted) return;

    // Go back (or reset form if we're on the Add tab).
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Opened via bottom-nav tab: reset the form in place.
      _nameCtrl.clear();
      _amountCtrl.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedCategory = ExpenseCategory.food;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Dépense ajoutée avec succès !'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Consistent Gradient Header SliverAppBar ────────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? const Color(0xFF0C0D14) : cs.primary,
              foregroundColor: isDark ? cs.onSurface : cs.onPrimary,
              elevation: 0,
              centerTitle: true,
              title: Text(
                _isEditing ? 'Modifier la dépense' : 'Ajouter une dépense',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _AddEditHeader(
                  amountCtrl: _amountCtrl,
                  isDark: isDark,
                  cs: cs,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Veuillez saisir un montant';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) {
                      return 'Entrez un nombre positif valide';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // ── Form fields in SliverPadding ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 115),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Name field ──────────────────────────────────
                  _label(context, 'Nom de la dépense'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _decoration(
                      context,
                      hint: 'ex : Courses de la semaine, Essence, Netflix...',
                      icon: Icons.edit_note_rounded,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Veuillez saisir un nom'
                        : null,
                  ),

                  const SizedBox(height: 24),

                  // ── Category picker ─────────────────────────────
                  _label(context, 'Catégorie'),
                  const SizedBox(height: 10),
                  _CategoryChips(
                    selected: _selectedCategory,
                    onChanged: (cat) => setState(() => _selectedCategory = cat),
                  ),

                  const SizedBox(height: 24),

                  // ── Date picker ─────────────────────────────────
                  _label(context, 'Date de transaction'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _quickDateButton(
                        label: "Aujourd'hui",
                        isSelected: DateUtils.isSameDay(
                          _selectedDate,
                          DateTime.now(),
                        ),
                        onTap: () =>
                            setState(() => _selectedDate = DateTime.now()),
                      ),
                      const SizedBox(width: 8),
                      _quickDateButton(
                        label: 'Hier',
                        isSelected: DateUtils.isSameDay(
                          _selectedDate,
                          DateTime.now().subtract(const Duration(days: 1)),
                        ),
                        onTap: () => setState(
                          () => _selectedDate = DateTime.now().subtract(
                            const Duration(days: 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.12),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isDark
                                  ? const Color(0xFF141524)
                                  : Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat.yMMMd(
                                      'fr_FR',
                                    ).format(_selectedDate),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cs.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: cs.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── Save button ─────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _isEditing
                            ? 'Enregistrer les modifications'
                            : 'Ajouter la dépense',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _label(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            letterSpacing: 0.6,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _quickDateButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : (isDark ? const Color(0xFF141524) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: cs.primary),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _AddEditHeader — custom painted glow header + glass card amount
// ─────────────────────────────────────────────────────────────

class _AddEditHeader extends StatelessWidget {
  final TextEditingController amountCtrl;
  final bool isDark;
  final ColorScheme cs;
  final String? Function(String?)? validator;

  const _AddEditHeader({
    required this.amountCtrl,
    required this.isDark,
    required this.cs,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0C0D14), const Color(0xFF191B29)]
              : [cs.primary, cs.tertiary],
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
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
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
                    children: [
                      Text(
                        'MONTANT DE LA DÉPENSE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '€ ',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          prefixStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          errorStyle: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: validator,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _CategoryChips — grid style bouncy choice chips.
// ─────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onChanged});

  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ExpenseCategory.values.map((cat) {
        final isSelected = cat == selected;
        final catColor = cat.color;

        return GestureDetector(
          onTap: () => onChanged(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [catColor, catColor.withValues(alpha: 0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? const Color(0xFF141524) : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? catColor
                    : cs.primary.withValues(alpha: 0.08),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: catColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.15 : 0.01,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : cs.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
