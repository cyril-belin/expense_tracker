import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';

// ─────────────────────────────────────────────────────────────
// DatabaseHelper — singleton wrapper around the SQLite database.
// All CRUD operations (create, read, update, delete) live here.
// ─────────────────────────────────────────────────────────────

class DatabaseHelper {
  // Private constructor — use [instance] to access the singleton.
  DatabaseHelper._();

  /// The single shared instance used across the whole app.
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  // ── Lazy initialisation ───────────────────────────────────

  /// Opens the database on first access; returns the cached
  /// [Database] on subsequent calls.
  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    // getDatabasesPath() returns the platform-specific folder
    // where SQLite files should be stored.
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_expenses.db');

    return openDatabase(
      path,
      version: 1,
      // onCreate runs only the very first time the DB is created.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id       TEXT PRIMARY KEY,
            name     TEXT    NOT NULL,
            amount   REAL    NOT NULL,
            date     TEXT    NOT NULL,
            category TEXT    NOT NULL
          )
        ''');
      },
    );
  }

  // ── CRUD operations ───────────────────────────────────────

  /// Inserts a new expense row. Throws if [id] already exists.
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      // REPLACE would silently overwrite; FAIL surfaces duplicates early.
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  /// Returns all rows ordered newest-first.
  Future<List<Expense>> fetchAllExpenses() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    // Convert each raw map into a typed Expense object.
    return rows.map(Expense.fromMap).toList();
  }

  /// Updates every column for the expense matching [expense.id].
  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Permanently removes the row with the given [id].
  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns the total number of stored expenses.
  /// Used on first launch to decide whether to seed sample data.
  Future<int> countExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM expenses');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
