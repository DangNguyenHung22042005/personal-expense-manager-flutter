import 'package:flutter/services.dart';

import 'currency_formatter.dart';

class VndInputFormatter extends TextInputFormatter {
  const VndInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final amount = CurrencyFormatter.parseVnd(newValue.text);
    if (amount == null) return oldValue;

    final formatted = CurrencyFormatter.formatNumber(amount);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
