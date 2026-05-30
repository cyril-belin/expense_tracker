import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────
// Category enum — maps to the five user-facing
// categories plus a catch-all "Other".
// ─────────────────────────────────────────────
enum ExpenseCategory { food, travel, shopping, bills, other }

/// Adds display helpers to [ExpenseCategory].
extension ExpenseCategoryX on ExpenseCategory {
  /// Human-readable name shown in the UI.
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Alimentation';
      case ExpenseCategory.travel:
        return 'Transport';
      case ExpenseCategory.shopping:
        return 'Achats';
      case ExpenseCategory.bills:
        return 'Factures';
      case ExpenseCategory.other:
        return 'Divers';
    }
  }

  /// Emoji icon used on expense tiles.
  String get emoji {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.travel:
        return '✈️';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.bills:
        return '🧾';
      case ExpenseCategory.other:
        return '📦';
    }
  }

  /// Accent colour for chart segments and category chips.
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFFF5E5E);
      case ExpenseCategory.travel:
        return const Color(0xFF00C9A7);
      case ExpenseCategory.shopping:
        return const Color(0xFFFF9F43);
      case ExpenseCategory.bills:
        return const Color(0xFF6C5CE7);
      case ExpenseCategory.other:
        return const Color(0xFF8395A7);
    }
  }

  /// Converts enum to a string stored in the database.
  String get dbValue => name;

  /// Recreates enum from the string stored in the database.
  static ExpenseCategory fromDb(String value) => ExpenseCategory.values
      .firstWhere((c) => c.name == value, orElse: () => ExpenseCategory.other);
}

// ─────────────────────────────────────────────
// Expense model
// ─────────────────────────────────────────────

/// A single spending record entered by the user.
class Expense {
  /// Unique identifier (UUID v4). Auto-generated when not provided.
  final String id;

  /// Short name, e.g. "Lunch at cafe".
  final String name;

  /// Positive monetary value.
  final double amount;

  /// Calendar day the expense occurred.
  final DateTime date;

  /// Which spending bucket this belongs to.
  final ExpenseCategory category;

  Expense({
    String? id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  // ── SQLite helpers ────────────────────────

  /// Converts to a flat map that SQLite can store.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    // Store date as ISO-8601 string: "2025-05-30"
    'date': date.toIso8601String(),
    'category': category.dbValue,
  };

  /// Recreates an [Expense] from a SQLite row.
  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] as String,
    name: map['name'] as String,
    amount: (map['amount'] as num).toDouble(),
    date: DateTime.parse(map['date'] as String),
    category: ExpenseCategoryX.fromDb(map['category'] as String),
  );

  // ── Immutable update helper ───────────────

  /// Returns a new [Expense] with selected fields replaced.
  Expense copyWith({
    String? name,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
  }) => Expense(
    id: id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    category: category ?? this.category,
  );
}
