import '../../domain/models/transaction_entry.dart';
import '../../domain/models/transaction_type.dart';

abstract final class SampleTransactions {
  static List<TransactionEntry> create({DateTime? referenceDate}) {
    final reference = referenceDate ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);

    TransactionEntry transaction({
      required String id,
      required String title,
      required int amount,
      required TransactionType type,
      required String category,
      required int daysAgo,
      String? note,
    }) {
      final date = today.subtract(Duration(days: daysAgo));
      return TransactionEntry(
        id: id,
        title: title,
        amount: amount,
        type: type,
        category: category,
        transactionDate: date,
        note: note,
        createdAt: date,
        updatedAt: date,
      );
    }

    return [
      transaction(
        id: 'sample-coffee',
        title: 'Cà phê buổi sáng',
        amount: 45000,
        type: TransactionType.expense,
        category: 'Ăn uống',
        daysAgo: 0,
      ),
      transaction(
        id: 'sample-freelance',
        title: 'Thu nhập làm thêm',
        amount: 2500000,
        type: TransactionType.income,
        category: 'Làm thêm',
        daysAgo: 1,
        note: 'Thiết kế giao diện ứng dụng',
      ),
      transaction(
        id: 'sample-groceries',
        title: 'Mua thực phẩm',
        amount: 620000,
        type: TransactionType.expense,
        category: 'Ăn uống',
        daysAgo: 2,
      ),
      transaction(
        id: 'sample-fuel',
        title: 'Đổ xăng',
        amount: 150000,
        type: TransactionType.expense,
        category: 'Di chuyển',
        daysAgo: 3,
      ),
      transaction(
        id: 'sample-course',
        title: 'Khóa học Flutter',
        amount: 1200000,
        type: TransactionType.expense,
        category: 'Học tập',
        daysAgo: 5,
      ),
      transaction(
        id: 'sample-salary',
        title: 'Lương tháng này',
        amount: 12000000,
        type: TransactionType.income,
        category: 'Lương',
        daysAgo: 7,
      ),
      transaction(
        id: 'sample-rent',
        title: 'Tiền thuê nhà',
        amount: 3500000,
        type: TransactionType.expense,
        category: 'Hóa đơn',
        daysAgo: 8,
        note: 'Tiền nhà và phí dịch vụ',
      ),
    ];
  }
}
