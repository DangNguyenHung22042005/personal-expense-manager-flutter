import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:personal_expense_manager/features/transactions/domain/errors/transaction_repository_exception.dart';
import 'package:personal_expense_manager/features/transactions/domain/models/transaction_entry.dart';
import 'package:personal_expense_manager/features/transactions/domain/models/transaction_type.dart';

void main() {
  late InMemoryTransactionRepository repository;
  late TransactionEntry transaction;

  setUp(() {
    final timestamp = DateTime(2026, 11, 9, 9);
    transaction = TransactionEntry(
      id: 'transaction-1',
      title: 'Ăn sáng',
      amount: 35000,
      type: TransactionType.expense,
      category: 'Ăn uống',
      transactionDate: timestamp,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    repository = InMemoryTransactionRepository();
  });

  group('InMemoryTransactionRepository', () {
    test('reads seeded transactions and finds one by id', () async {
      repository = InMemoryTransactionRepository(
        initialTransactions: [transaction],
      );

      final transactions = await repository.getTransactions();
      final found = await repository.getTransactionById(transaction.id);

      expect(transactions, [transaction]);
      expect(found, transaction);
      expect(await repository.getTransactionById('missing-id'), isNull);
    });

    test('returns an unmodifiable transaction list', () async {
      repository = InMemoryTransactionRepository(
        initialTransactions: [transaction],
      );
      final transactions = await repository.getTransactions();

      expect(() => transactions.add(transaction), throwsUnsupportedError);
    });

    test('creates a transaction', () async {
      final created = await repository.createTransaction(transaction);

      expect(created, transaction);
      expect(await repository.getTransactions(), [transaction]);
    });

    test('rejects a duplicate transaction id', () async {
      await repository.createTransaction(transaction);

      await expectLater(
        repository.createTransaction(transaction),
        throwsA(isA<TransactionAlreadyExistsException>()),
      );
    });

    test('updates an existing transaction', () async {
      await repository.createTransaction(transaction);
      final updated = transaction.copyWith(
        title: 'Ăn sáng cùng bạn',
        amount: 50000,
        updatedAt: transaction.updatedAt.add(const Duration(minutes: 30)),
      );

      final result = await repository.updateTransaction(updated);

      expect(result, updated);
      expect(await repository.getTransactionById(transaction.id), updated);
    });

    test('rejects an update for a missing transaction', () async {
      await expectLater(
        repository.updateTransaction(transaction),
        throwsA(isA<TransactionNotFoundException>()),
      );
    });

    test('deletes an existing transaction', () async {
      await repository.createTransaction(transaction);

      await repository.deleteTransaction(transaction.id);

      expect(await repository.getTransactions(), isEmpty);
      expect(await repository.getTransactionById(transaction.id), isNull);
    });

    test('rejects deletion of a missing transaction', () async {
      await expectLater(
        repository.deleteTransaction('missing-id'),
        throwsA(isA<TransactionNotFoundException>()),
      );
    });
  });
}
