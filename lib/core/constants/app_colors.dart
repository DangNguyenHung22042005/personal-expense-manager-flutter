import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF0F9D72);
  static const Color income = Color(0xFF168C5B);
  static const Color expense = Color(0xFFE05252);
  static const Color incomeDark = Color(0xFF72D7A8);
  static const Color expenseDark = Color(0xFFFFA0A0);
  static const Color background = Color(0xFFF6F8F7);

  static Color incomeFor(Brightness brightness) {
    return brightness == Brightness.dark ? incomeDark : income;
  }

  static Color expenseFor(Brightness brightness) {
    return brightness == Brightness.dark ? expenseDark : expense;
  }
}
