class TransactionAlreadyExistsException implements Exception {
  const TransactionAlreadyExistsException(this.id);

  final String id;

  @override
  String toString() => 'A transaction with id "$id" already exists.';
}

class TransactionNotFoundException implements Exception {
  const TransactionNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'Transaction with id "$id" was not found.';
}
