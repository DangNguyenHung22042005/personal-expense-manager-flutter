import '../models/transaction_entry.dart';

abstract interface class TransactionRepository {
  Future<List<TransactionEntry>> getTransactions();

  Future<TransactionEntry?> getTransactionById(String id);

  Future<TransactionEntry> createTransaction(TransactionEntry transaction);

  Future<TransactionEntry> updateTransaction(TransactionEntry transaction);

  Future<void> deleteTransaction(String id);
}
