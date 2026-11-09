import 'package:flutter/material.dart';

class TransactionCategoryVisual {
  const TransactionCategoryVisual({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

abstract final class TransactionCategoryVisuals {
  static TransactionCategoryVisual resolve(
    BuildContext context,
    String category,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (category) {
      'Ăn uống' => TransactionCategoryVisual(
        icon: Icons.restaurant_rounded,
        color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
      ),
      'Di chuyển' => TransactionCategoryVisual(
        icon: Icons.directions_car_filled_rounded,
        color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
      ),
      'Mua sắm' => TransactionCategoryVisual(
        icon: Icons.shopping_bag_rounded,
        color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
      ),
      'Hóa đơn' => TransactionCategoryVisual(
        icon: Icons.receipt_long_rounded,
        color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
      ),
      'Giải trí' => TransactionCategoryVisual(
        icon: Icons.movie_rounded,
        color: isDark ? Colors.pink.shade200 : Colors.pink.shade700,
      ),
      'Học tập' => TransactionCategoryVisual(
        icon: Icons.school_rounded,
        color: isDark ? Colors.teal.shade200 : Colors.teal.shade700,
      ),
      'Sức khỏe' => TransactionCategoryVisual(
        icon: Icons.favorite_rounded,
        color: isDark ? Colors.red.shade200 : Colors.red.shade700,
      ),
      'Lương' => TransactionCategoryVisual(
        icon: Icons.account_balance_wallet_rounded,
        color: isDark ? Colors.green.shade300 : Colors.green.shade700,
      ),
      'Thưởng' => TransactionCategoryVisual(
        icon: Icons.emoji_events_rounded,
        color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
      ),
      'Làm thêm' => TransactionCategoryVisual(
        icon: Icons.work_rounded,
        color: isDark ? Colors.cyan.shade300 : Colors.cyan.shade800,
      ),
      'Đầu tư' => TransactionCategoryVisual(
        icon: Icons.trending_up_rounded,
        color: isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade700,
      ),
      'Quà tặng' => TransactionCategoryVisual(
        icon: Icons.card_giftcard_rounded,
        color: isDark ? Colors.pink.shade200 : Colors.pink.shade700,
      ),
      _ => TransactionCategoryVisual(
        icon: Icons.category_rounded,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
      ),
    };
  }
}
