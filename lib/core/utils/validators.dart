abstract final class Validators {
  static String? required(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  static String? positiveInteger(String? value) {
    final requiredError = required(value, fieldName: 'Số tiền');
    if (requiredError != null) return requiredError;

    final normalized = value!.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(normalized);
    if (amount == null || amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }
    return null;
  }
}
