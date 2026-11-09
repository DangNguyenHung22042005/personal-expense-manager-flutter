import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/features/transactions/application/transaction_controller.dart';
import 'package:personal_expense_manager/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:personal_expense_manager/features/transactions/domain/models/transaction_entry.dart';
import 'package:personal_expense_manager/features/transactions/domain/models/transaction_type.dart';

void main() {
  final referenceDate = DateTime(2026, 11, 9, 10);

  TransactionEntry createTransaction({
    required String id,
    required String title,
    required int amount,
    required TransactionType type,
    required String category,
    required int daysAgo,
    String? note,
  }) {
    final timestamp = referenceDate.subtract(Duration(days: daysAgo));
    return TransactionEntry(
      id: id,
      title: title,
      amount: amount,
      type: type,
      category: category,
      transactionDate: timestamp,
      note: note,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  final salary = createTransaction(
    id: 'salary',
    title: 'Lương tháng 11',
    amount: 10000000,
    type: TransactionType.income,
    category: 'Lương',
    daysAgo: 3,
  );
  final coffee = createTransaction(
    id: 'coffee',
    title: 'Cà phê sáng',
    amount: 50000,
    type: TransactionType.expense,
    category: 'Ăn uống',
    daysAgo: 0,
    note: 'Gặp nhóm thiết kế',
  );
  final book = createTransaction(
    id: 'book',
    title: 'Sách lập trình',
    amount: 200000,
    type: TransactionType.expense,
    category: 'Mua sắm',
    daysAgo: 1,
  );

  late InMemoryTransactionRepository repository;
  late TransactionController controller;

  setUp(() async {
    repository = InMemoryTransactionRepository(
      initialTransactions: [salary, book, coffee],
    );
    controller = TransactionController(repository: repository);
    await controller.loadTransactions();
  });

  tearDown(() {
    controller.dispose();
  });

  group('TransactionController', () {
    test('loads and sorts transactions from newest to oldest', () {
      expect(controller.isLoading, isFalse);
      expect(controller.transactions.map((transaction) => transaction.id), [
        'coffee',
        'book',
        'salary',
      ]);
      expect(controller.categories, hasLength(3));
      expect(
        controller.categories,
        containsAll(['Ăn uống', 'Lương', 'Mua sắm']),
      );
    });

    test('calculates income, expense, and current balance', () {
      expect(controller.totalIncome, 10000000);
      expect(controller.totalExpense, 250000);
      expect(controller.currentBalance, 9750000);
    });

    test('searches title, category, and note without case sensitivity', () {
      controller.setSearchQuery('SÁCH');
      expect(controller.filteredTransactions, [book]);

      controller.setSearchQuery('ăn uống');
      expect(controller.filteredTransactions, [coffee]);

      controller.setSearchQuery('THIẾT KẾ');
      expect(controller.filteredTransactions, [coffee]);
    });

    test('combines type and category filters and can clear them', () {
      controller.setTypeFilter(TransactionType.expense);
      expect(controller.filteredTransactions, [coffee, book]);

      controller.setCategoryFilter('Ăn uống');
      expect(controller.filteredTransactions, [coffee]);
      expect(controller.hasActiveFilters, isTrue);

      controller.clearFilters();
      expect(controller.filteredTransactions, controller.transactions);
      expect(controller.searchQuery, isEmpty);
      expect(controller.selectedType, isNull);
      expect(controller.selectedCategory, isNull);
      expect(controller.hasActiveFilters, isFalse);
    });

    test('adds a transaction and updates calculated totals', () async {
      final bonus = createTransaction(
        id: 'bonus',
        title: 'Tiền thưởng',
        amount: 1000000,
        type: TransactionType.income,
        category: 'Thưởng',
        daysAgo: 0,
      ).copyWith(createdAt: referenceDate.add(const Duration(minutes: 1)));

      final succeeded = await controller.addTransaction(bonus);

      expect(succeeded, isTrue);
      expect(controller.transactions.first, bonus);
      expect(controller.totalIncome, 11000000);
      expect(controller.errorMessage, isNull);
    });

    test('updates a transaction and recalculates totals', () async {
      final updatedSalary = salary.copyWith(
        amount: 11000000,
        updatedAt: referenceDate,
      );

      final succeeded = await controller.updateTransaction(updatedSalary);

      expect(succeeded, isTrue);
      expect(
        controller.transactions.singleWhere(
          (transaction) => transaction.id == salary.id,
        ),
        updatedSalary,
      );
      expect(controller.totalIncome, 11000000);
      expect(controller.currentBalance, 10750000);
    });

    test('deletes a transaction and recalculates totals', () async {
      final succeeded = await controller.deleteTransaction(coffee.id);

      expect(succeeded, isTrue);
      expect(
        controller.transactions.any(
          (transaction) => transaction.id == coffee.id,
        ),
        isFalse,
      );
      expect(controller.totalExpense, 200000);
    });

    test('exposes loading state while the repository is pending', () async {
      final completer = Completer<List<TransactionEntry>>();
      final pendingController = TransactionController(
        repository: _PendingLoadRepository(completer.future),
      );
      addTearDown(pendingController.dispose);

      final loadFuture = pendingController.loadTransactions();
      expect(pendingController.isLoading, isTrue);

      completer.complete([coffee]);
      await loadFuture;

      expect(pendingController.isLoading, isFalse);
      expect(pendingController.transactions, [coffee]);
    });

    test('exposes mutating state while a write is pending', () async {
      final completer = Completer<TransactionEntry>();
      final pendingController = TransactionController(
        repository: _PendingCreateRepository(completer.future),
      );
      addTearDown(pendingController.dispose);

      final createFuture = pendingController.addTransaction(coffee);
      expect(pendingController.isMutating, isTrue);

      completer.complete(coffee);
      expect(await createFuture, isTrue);

      expect(pendingController.isMutating, isFalse);
      expect(pendingController.transactions, [coffee]);
    });

    test('stores and clears a load error without throwing to the UI', () async {
      final failingController = TransactionController(
        repository: _FailingLoadRepository(),
      );
      addTearDown(failingController.dispose);

      await failingController.loadTransactions();

      expect(failingController.isLoading, isFalse);
      expect(failingController.errorMessage, contains('Mất kết nối'));

      failingController.clearError();
      expect(failingController.errorMessage, isNull);
    });

    test('reports a mutation error and keeps existing data intact', () async {
      final succeeded = await controller.addTransaction(coffee);

      expect(succeeded, isFalse);
      expect(controller.isMutating, isFalse);
      expect(controller.transactions, hasLength(3));
      expect(controller.errorMessage, contains('Không thể thêm giao dịch'));
    });
  });
}

class _PendingLoadRepository extends InMemoryTransactionRepository {
  _PendingLoadRepository(this.pendingResult);

  final Future<List<TransactionEntry>> pendingResult;

  @override
  Future<List<TransactionEntry>> getTransactions() => pendingResult;
}

class _FailingLoadRepository extends InMemoryTransactionRepository {
  @override
  Future<List<TransactionEntry>> getTransactions() {
    throw Exception('Mất kết nối');
  }
}

class _PendingCreateRepository extends InMemoryTransactionRepository {
  _PendingCreateRepository(this.pendingResult);

  final Future<TransactionEntry> pendingResult;

  @override
  Future<TransactionEntry> createTransaction(TransactionEntry transaction) {
    return pendingResult;
  }
}
