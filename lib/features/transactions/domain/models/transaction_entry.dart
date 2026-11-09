import 'transaction_type.dart';

const Object _unsetNote = Object();

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  final String id;
  final String title;
  final int amount;
  final TransactionType type;
  final String category;
  final DateTime transactionDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get signedAmount => type.applySign(amount);

  TransactionEntry copyWith({
    String? id,
    String? title,
    int? amount,
    TransactionType? type,
    String? category,
    DateTime? transactionDate,
    Object? note = _unsetNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      transactionDate: transactionDate ?? this.transactionDate,
      note: identical(note, _unsetNote) ? this.note : note as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TransactionEntry &&
            id == other.id &&
            title == other.title &&
            amount == other.amount &&
            type == other.type &&
            category == other.category &&
            transactionDate == other.transactionDate &&
            note == other.note &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amount,
    type,
    category,
    transactionDate,
    note,
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'TransactionEntry(id: $id, title: $title, amount: $amount, '
        'type: $type, category: $category, transactionDate: $transactionDate)';
  }
}
