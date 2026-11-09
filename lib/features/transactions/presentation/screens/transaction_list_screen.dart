import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.transactionHistory)),
      body: const Center(
        child: AppEmptyState(
          title: AppStrings.noTransactionsTitle,
          message: AppStrings.noTransactionsMessage,
        ),
      ),
    );
  }
}
