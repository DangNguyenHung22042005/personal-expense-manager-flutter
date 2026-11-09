abstract final class CurrencyFormatter {
  static String formatNumber(int amount) {
    final isNegative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[index]);
    }

    return '${isNegative ? '-' : ''}$buffer';
  }

  static String formatVnd(int amount) => '${formatNumber(amount)} ₫';

  static int? parseVnd(String value) {
    final digits = value.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }
}
