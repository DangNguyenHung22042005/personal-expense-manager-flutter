import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../application/transaction_controller.dart';
import '../../domain/models/transaction_entry.dart';
import '../widgets/transaction_category_visuals.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransactionController>();
    final transaction = controller.getTransactionById(transactionId);

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.transactionDetail)),
        body: const Center(
          child: AppErrorState(message: AppStrings.transactionNotFound),
        ),
      );
    }

    final isIncome = transaction.type.isIncome;
    final brightness = Theme.of(context).brightness;
    final color = isIncome
        ? AppColors.incomeFor(brightness)
        : AppColors.expenseFor(brightness);
    final categoryVisual = TransactionCategoryVisuals.resolve(
      context,
      transaction.category,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionDetail),
        actions: [
          IconButton(
            key: const Key('edit-transaction-button'),
            tooltip: AppStrings.editTransaction,
            onPressed: controller.isMutating
                ? null
                : () => _openEditForm(context, transaction),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: const Key('delete-transaction-button'),
            tooltip: AppStrings.deleteTransaction,
            onPressed: controller.isMutating
                ? null
                : () => _confirmDelete(context, transaction),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spaceLg),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: categoryVisual.color.withValues(
                            alpha: 0.16,
                          ),
                          foregroundColor: categoryVisual.color,
                          child: Icon(categoryVisual.icon, size: 30),
                        ),
                        const SizedBox(height: AppSizes.spaceMd),
                        Text(
                          transaction.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSizes.spaceSm),
                        Text(
                          '${isIncome ? '+' : '-'}'
                          '${CurrencyFormatter.formatVnd(transaction.amount)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.spaceMd),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.swap_vert_rounded,
                            label: 'Loại giao dịch',
                            value: isIncome
                                ? AppStrings.income
                                : AppStrings.expense,
                          ),
                          const Divider(),
                          _DetailRow(
                            icon: Icons.category_outlined,
                            label: 'Danh mục',
                            value: transaction.category,
                          ),
                          const Divider(),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Ngày giao dịch',
                            value: DateFormatter.formatDayMonthYear(
                              transaction.transactionDate,
                            ),
                          ),
                          if (transaction.note != null) ...[
                            const Divider(),
                            _DetailRow(
                              icon: Icons.notes_rounded,
                              label: 'Ghi chú',
                              value: transaction.note!,
                            ),
                          ],
                        ],
                      ),
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

  Future<void> _openEditForm(
    BuildContext context,
    TransactionEntry transaction,
  ) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.transactionForm,
      arguments: transaction,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TransactionEntry transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa giao dịch “${transaction.title}” không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final controller = context.read<TransactionController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final succeeded = await controller.deleteTransaction(transaction.id);
    if (!context.mounted) return;

    messenger.hideCurrentSnackBar();
    if (succeeded) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã xóa giao dịch thành công.')),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Không thể xóa giao dịch.'),
        ),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceXs),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
