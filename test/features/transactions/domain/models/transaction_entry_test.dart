import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/features/transactions/domain/models/transaction_entry.dart';
import 'package:personal_expense_manager/features/transactions/domain/models/transaction_type.dart';

void main() {
  final timestamp = DateTime(2026, 11, 9, 8, 30);
  final transaction = TransactionEntry(
    id: 'transaction-1',
    title: 'Lương tháng 11',
    amount: 12000000,
    type: TransactionType.income,
    category: 'Lương',
    transactionDate: timestamp,
    note: 'Lương chính thức',
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  group('TransactionEntry', () {
    test('returns a signed amount based on transaction type', () {
      expect(transaction.signedAmount, 12000000);
      expect(
        transaction.copyWith(type: TransactionType.expense).signedAmount,
        -12000000,
      );
    });

    test('copyWith updates selected values and keeps the others', () {
      final updatedAt = timestamp.add(const Duration(hours: 1));
      final updated = transaction.copyWith(
        title: 'Lương và thưởng tháng 11',
        amount: 13500000,
        updatedAt: updatedAt,
      );

      expect(updated.id, transaction.id);
      expect(updated.title, 'Lương và thưởng tháng 11');
      expect(updated.amount, 13500000);
      expect(updated.category, transaction.category);
      expect(updated.note, transaction.note);
      expect(updated.updatedAt, updatedAt);
    });

    test('copyWith can explicitly clear a nullable note', () {
      final updated = transaction.copyWith(note: null);

      expect(updated.note, isNull);
    });

    test('uses value equality', () {
      final sameTransaction = transaction.copyWith();

      expect(sameTransaction, transaction);
      expect(sameTransaction.hashCode, transaction.hashCode);
    });
  });
}
