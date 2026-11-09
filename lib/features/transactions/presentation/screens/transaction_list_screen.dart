import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../application/transaction_controller.dart';
import '../../domain/models/transaction_type.dart';
import '../widgets/transaction_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();
  bool _initializedSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedSearch) {
      _searchController.text = context
          .read<TransactionController>()
          .searchQuery;
      _initializedSearch = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransactionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionHistory),
        actions: [
          IconButton(
            tooltip: 'Tải lại dữ liệu',
            onPressed: controller.isLoading
                ? null
                : controller.loadTransactions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.spaceMd,
                AppSizes.spaceSm,
                AppSizes.spaceMd,
                AppSizes.spaceSm,
              ),
              child: TextField(
                key: const Key('transaction-search-field'),
                controller: _searchController,
                onChanged: controller.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Tìm tên, danh mục hoặc ghi chú',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Xóa từ khóa',
                          onPressed: () {
                            _searchController.clear();
                            controller.setSearchQuery('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            _FilterBar(controller: controller),
            Expanded(child: _TransactionListBody(controller: controller)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-transaction-list-button'),
        tooltip: AppStrings.addTransaction,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.transactionForm),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final TransactionController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMd),
        children: [
          ChoiceChip(
            label: const Text(AppStrings.all),
            selected: controller.selectedType == null,
            onSelected: (_) => controller.setTypeFilter(null),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          ChoiceChip(
            label: const Text(AppStrings.income),
            selected: controller.selectedType == TransactionType.income,
            onSelected: (_) => controller.setTypeFilter(TransactionType.income),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          ChoiceChip(
            label: const Text(AppStrings.expense),
            selected: controller.selectedType == TransactionType.expense,
            onSelected: (_) =>
                controller.setTypeFilter(TransactionType.expense),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          DropdownButton<String?>(
            key: const Key('category-filter'),
            value: controller.selectedCategory,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Mọi danh mục'),
              ),
              for (final category in controller.categories)
                DropdownMenuItem<String?>(
                  value: category,
                  child: Text(category),
                ),
            ],
            onChanged: controller.setCategoryFilter,
          ),
          if (controller.hasActiveFilters) ...[
            const SizedBox(width: AppSizes.spaceSm),
            TextButton.icon(
              onPressed: controller.clearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Xóa lọc'),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionListBody extends StatelessWidget {
  const _TransactionListBody({required this.controller});

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

    if (controller.transactions.isEmpty) {
      return Center(
        child: AppEmptyState(
          title: AppStrings.noTransactionsTitle,
          message: AppStrings.noTransactionsMessage,
          actionLabel: AppStrings.addTransaction,
          onAction: () =>
              Navigator.pushNamed(context, AppRoutes.transactionForm),
        ),
      );
    }

    final transactions = controller.filteredTransactions;
    if (transactions.isEmpty) {
      return const Center(
        child: AppEmptyState(
          title: AppStrings.noSearchResultsTitle,
          message: AppStrings.noSearchResultsMessage,
          icon: Icons.search_off_rounded,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spaceMd,
          AppSizes.spaceSm,
          AppSizes.spaceMd,
          96,
        ),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return TransactionCard(
            key: Key('transaction-card-${transaction.id}'),
            transaction: transaction,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.transactionDetail,
              arguments: transaction.id,
            ),
          );
        },
      ),
    );
  }
}
