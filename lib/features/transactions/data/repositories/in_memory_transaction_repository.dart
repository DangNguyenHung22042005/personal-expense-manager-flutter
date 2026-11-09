import '../../domain/errors/transaction_repository_exception.dart';
import '../../domain/models/transaction_entry.dart';
import '../../domain/repositories/transaction_repository.dart';

class InMemoryTransactionRepository implements TransactionRepository {
  InMemoryTransactionRepository({
    Iterable<TransactionEntry> initialTransactions = const [],
  }) : _transactions = {
         for (final transaction in initialTransactions)
           transaction.id: transaction,
       };

  final Map<String, TransactionEntry> _transactions;

  @override
  Future<List<TransactionEntry>> getTransactions() async {
    return List<TransactionEntry>.unmodifiable(_transactions.values);
  }

  @override
  Future<TransactionEntry?> getTransactionById(String id) async {
    return _transactions[id];
  }

  @override
  Future<TransactionEntry> createTransaction(
    TransactionEntry transaction,
  ) async {
    if (_transactions.containsKey(transaction.id)) {
      throw TransactionAlreadyExistsException(transaction.id);
    }

    _transactions[transaction.id] = transaction;
    return transaction;
  }

  @override
  Future<TransactionEntry> updateTransaction(
    TransactionEntry transaction,
  ) async {
    if (!_transactions.containsKey(transaction.id)) {
      throw TransactionNotFoundException(transaction.id);
    }

    _transactions[transaction.id] = transaction;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final removedTransaction = _transactions.remove(id);
    if (removedTransaction == null) {
      throw TransactionNotFoundException(id);
    }
  }
}
