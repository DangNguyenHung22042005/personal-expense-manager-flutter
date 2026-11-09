import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/transactions/domain/models/transaction_entry.dart';
import '../features/transactions/presentation/screens/home_screen.dart';
import '../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../features/transactions/presentation/screens/transaction_form_screen.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/detail';
  static const String transactionForm = '/transactions/form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      home => MaterialPageRoute<void>(
        builder: (_) => const HomeScreen(),
        settings: settings,
      ),
      transactions => MaterialPageRoute<void>(
        builder: (_) => const TransactionListScreen(),
        settings: settings,
      ),
      transactionDetail => MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(
          transactionId: settings.arguments! as String,
        ),
        settings: settings,
      ),
      transactionForm => MaterialPageRoute<bool>(
        builder: (_) => TransactionFormScreen(
          transaction: settings.arguments as TransactionEntry?,
        ),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const _UnknownRouteScreen(),
        settings: settings,
      ),
    };
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.pageNotFound)),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (_) => false,
          ),
          child: const Text(AppStrings.backToHome),
        ),
      ),
    );
  }
}
