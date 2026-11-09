import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/core/utils/currency_formatter.dart';
import 'package:personal_expense_manager/core/utils/date_formatter.dart';
import 'package:personal_expense_manager/core/utils/vnd_input_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats positive, negative, and zero VND values', () {
      expect(CurrencyFormatter.formatVnd(1234567), '1.234.567 ₫');
      expect(CurrencyFormatter.formatVnd(-50000), '-50.000 ₫');
      expect(CurrencyFormatter.formatVnd(0), '0 ₫');
    });

    test('parses formatted VND input', () {
      expect(CurrencyFormatter.parseVnd('1.234.567'), 1234567);
      expect(CurrencyFormatter.parseVnd('250.000 ₫'), 250000);
      expect(CurrencyFormatter.parseVnd(''), isNull);
    });
  });

  test('DateFormatter uses the Vietnamese day/month/year order', () {
    expect(
      DateFormatter.formatDayMonthYear(DateTime(2026, 11, 9)),
      '09/11/2026',
    );
  });

  test('VndInputFormatter groups digits while typing', () {
    const formatter = VndInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '1234567',
        selection: TextSelection.collapsed(offset: 7),
      ),
    );

    expect(result.text, '1.234.567');
    expect(result.selection.baseOffset, result.text.length);
  });
}
