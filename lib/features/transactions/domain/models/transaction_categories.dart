import 'transaction_type.dart';

abstract final class TransactionCategories {
  static const List<String> income = [
    'Lương',
    'Thưởng',
    'Làm thêm',
    'Đầu tư',
    'Quà tặng',
    'Khác',
  ];

  static const List<String> expense = [
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Hóa đơn',
    'Giải trí',
    'Học tập',
    'Sức khỏe',
    'Khác',
  ];

  static List<String> forType(TransactionType type) {
    return type.isIncome ? income : expense;
  }
}
