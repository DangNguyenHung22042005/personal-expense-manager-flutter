import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/transactions/data/repositories/in_memory_transaction_repository.dart';
import '../features/transactions/data/seeds/sample_transactions.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import 'app_config.dart';

/// Composition root for application dependencies.
///
/// Repositories and controllers will be registered here in the next phases.
class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: const AppConfig()),
        Provider<TransactionRepository>(
          create: (_) => InMemoryTransactionRepository(
            initialTransactions: SampleTransactions.create(),
          ),
        ),
      ],
      child: child,
    );
  }
}
