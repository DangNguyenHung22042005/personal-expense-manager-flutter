enum TransactionType {
  income,
  expense;

  bool get isIncome => this == TransactionType.income;

  bool get isExpense => this == TransactionType.expense;

  int applySign(int amount) => isIncome ? amount : -amount;
}
