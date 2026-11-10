import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/transaction_controller.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransactionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại dữ liệu',
            onPressed: controller.isLoading
                ? null
                : controller.loadTransactions,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            key: const Key('logout-button'),
            tooltip: AppStrings.signOut,
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _HomeBody(controller: controller),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-transaction-button'),
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.transactionForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addTransaction),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.signOut),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi FinTrack không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('confirm-logout-button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthController>().signOut();
    }
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.controller});

  final TransactionController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.transactions.isEmpty) {
      return const AppLoading();
    }

    if (controller.errorMessage != null && controller.transactions.isEmpty) {
      return Center(
        child: AppErrorState(
          message: controller.errorMessage!,
          onRetry: controller.loadTransactions,
        ),
      );
    }

    final recentTransactions = controller.transactions.take(5).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceMd,
            AppSizes.spaceSm,
            AppSizes.spaceMd,
            96,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.appTagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  _BalanceCard(amount: controller.currentBalance),
                  const SizedBox(height: AppSizes.spaceMd),
                  _SummaryCards(
                    income: controller.totalIncome,
                    expense: controller.totalExpense,
                  ),
                  if (controller.errorMessage != null) ...[
                    const SizedBox(height: AppSizes.spaceMd),
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(controller.errorMessage!),
                        trailing: IconButton(
                          tooltip: AppStrings.retry,
                          onPressed: controller.loadTransactions,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spaceXl),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSizes.spaceMd,
                    runSpacing: AppSizes.spaceSm,
                    children: [
                      Text(
                        AppStrings.recentTransactions,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.transactions,
                        ),
                        child: const Text(AppStrings.viewTransactions),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  if (recentTransactions.isEmpty)
                    Card(
                      child: AppEmptyState(
                        title: AppStrings.noTransactionsTitle,
                        message: AppStrings.noTransactionsMessage,
                        actionLabel: AppStrings.addTransaction,
                        onAction: () => Navigator.pushNamed(
                          context,
                          AppRoutes.transactionForm,
                        ),
                      ),
                    )
                  else
                    for (final transaction in recentTransactions)
                      TransactionCard(
                        key: Key('transaction-card-${transaction.id}'),
                        transaction: transaction,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.transactionDetail,
                          arguments: transaction.id,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.income, required this.expense});

  final int income;
  final int expense;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final incomeCard = _SummaryCard(
      title: AppStrings.totalIncome,
      amount: income,
      icon: Icons.south_west_rounded,
      color: AppColors.incomeFor(brightness),
    );
    final expenseCard = _SummaryCard(
      title: AppStrings.totalExpense,
      amount: expense,
      icon: Icons.north_east_rounded,
      color: AppColors.expenseFor(brightness),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              incomeCard,
              const SizedBox(height: AppSizes.spaceSm),
              expenseCard,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: incomeCard),
            const SizedBox(width: AppSizes.spaceMd),
            Expanded(child: expenseCard),
          ],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.currentBalance,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              CurrencyFormatter.formatVnd(amount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final int amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppSizes.spaceMd),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSizes.spaceXs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.formatVnd(amount),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
