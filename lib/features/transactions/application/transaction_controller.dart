import 'package:flutter/foundation.dart';

import '../domain/models/transaction_entry.dart';
import '../domain/models/transaction_type.dart';
import '../domain/repositories/transaction_repository.dart';

class TransactionController extends ChangeNotifier {
  TransactionController({required this.repository});

  final TransactionRepository repository;
  final List<TransactionEntry> _transactions = [];

  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;
  String _searchQuery = '';
  TransactionType? _selectedType;
  String? _selectedCategory;

  bool get isLoading => _isLoading;

  bool get isMutating => _isMutating;

  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;

  TransactionType? get selectedType => _selectedType;

  String? get selectedCategory => _selectedCategory;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedType != null ||
      _selectedCategory != null;

  List<TransactionEntry> get transactions =>
      List<TransactionEntry>.unmodifiable(_transactions);

  TransactionEntry? getTransactionById(String id) {
    for (final transaction in _transactions) {
      if (transaction.id == id) return transaction;
    }
    return null;
  }

  List<String> get categories {
    final values =
        _transactions
            .map((transaction) => transaction.category)
            .toSet()
            .toList()
          ..sort();
    return List<String>.unmodifiable(values);
  }

  List<TransactionEntry> get filteredTransactions {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filtered = _transactions.where((transaction) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          transaction.title.toLowerCase().contains(normalizedQuery) ||
          transaction.category.toLowerCase().contains(normalizedQuery) ||
          (transaction.note?.toLowerCase().contains(normalizedQuery) ?? false);
      final matchesType =
          _selectedType == null || transaction.type == _selectedType;
      final matchesCategory =
          _selectedCategory == null ||
          transaction.category == _selectedCategory;

      return matchesQuery && matchesType && matchesCategory;
    }).toList();

    return List<TransactionEntry>.unmodifiable(filtered);
  }

  int get totalIncome => _transactions
      .where((transaction) => transaction.type.isIncome)
      .fold(0, (total, transaction) => total + transaction.amount);

  int get totalExpense => _transactions
      .where((transaction) => transaction.type.isExpense)
      .fold(0, (total, transaction) => total + transaction.amount);

  int get currentBalance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedTransactions = await repository.getTransactions();
      _transactions
        ..clear()
        ..addAll(loadedTransactions);
      _sortTransactions();
    } catch (error) {
      _errorMessage = 'Không thể tải giao dịch: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(TransactionEntry transaction) {
    return _runMutation(
      action: () async {
        final created = await repository.createTransaction(transaction);
        _transactions.add(created);
        _sortTransactions();
      },
      errorPrefix: 'Không thể thêm giao dịch',
    );
  }

  Future<bool> updateTransaction(TransactionEntry transaction) {
    return _runMutation(
      action: () async {
        final updated = await repository.updateTransaction(transaction);
        final index = _transactions.indexWhere(
          (current) => current.id == updated.id,
        );

        if (index == -1) {
          _transactions.add(updated);
        } else {
          _transactions[index] = updated;
        }
        _sortTransactions();
      },
      errorPrefix: 'Không thể cập nhật giao dịch',
    );
  }

  Future<bool> deleteTransaction(String id) {
    return _runMutation(
      action: () async {
        await repository.deleteTransaction(id);
        _transactions.removeWhere((transaction) => transaction.id == id);
      },
      errorPrefix: 'Không thể xóa giao dịch',
    );
  }

  void setSearchQuery(String value) {
    final normalized = value.trim();
    if (_searchQuery == normalized) return;

    _searchQuery = normalized;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? value) {
    if (_selectedType == value) return;

    _selectedType = value;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    if (_selectedCategory == value) return;

    _selectedCategory = value;
    notifyListeners();
  }

  void clearFilters() {
    if (!hasActiveFilters) return;

    _searchQuery = '';
    _selectedType = null;
    _selectedCategory = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runMutation({
    required Future<void> Function() action,
    required String errorPrefix,
  }) async {
    if (_isMutating) return false;

    _isMutating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (error) {
      _errorMessage = '$errorPrefix: $error';
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  void _sortTransactions() {
    _transactions.sort((first, second) {
      final dateComparison = second.transactionDate.compareTo(
        first.transactionDate,
      );
      if (dateComparison != 0) return dateComparison;

      return second.createdAt.compareTo(first.createdAt);
    });
  }
}
