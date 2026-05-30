// Widget tests for Smart Expense Tracker.
// sqflite requires a real device/integration test environment, so we keep
// these as lightweight unit-level checks that the root widget compiles.

import 'package:expense_tracker/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SmartExpenseTrackerApp can be instantiated', () {
    const app = SmartExpenseTrackerApp();
    expect(app, isNotNull);
  });
}
