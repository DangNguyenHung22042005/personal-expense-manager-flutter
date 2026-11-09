import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../application/transaction_controller.dart';
import '../../domain/models/transaction_categories.dart';
import '../../domain/models/transaction_entry.dart';
import '../../domain/models/transaction_type.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({this.transaction, super.key});

  final TransactionEntry? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _selectedType = transaction?.type ?? TransactionType.expense;
    _selectedCategory =
        transaction?.category ??
        TransactionCategories.forType(_selectedType).first;
    _selectedDate = transaction?.transactionDate ?? DateTime.now();
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMutating = context.watch<TransactionController>().isMutating;
    final categories = TransactionCategories.forType(_selectedType);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? AppStrings.editTransaction : AppStrings.addTransaction,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Loại giao dịch',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSizes.spaceSm),
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text(AppStrings.expense),
                          icon: Icon(Icons.north_east_rounded),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text(AppStrings.income),
                          icon: Icon(Icons.south_west_rounded),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: isMutating
                          ? null
                          : (selection) {
                              final type = selection.single;
                              setState(() {
                                _selectedType = type;
                                _selectedCategory =
                                    TransactionCategories.forType(type).first;
                              });
                            },
                    ),
                    const SizedBox(height: AppSizes.spaceLg),
                    TextFormField(
                      key: const Key('transaction-title-field'),
                      controller: _titleController,
                      enabled: !isMutating,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Tên giao dịch',
                        hintText: 'Ví dụ: Ăn trưa',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                      validator: (value) => Validators.required(
                        value,
                        fieldName: 'Tên giao dịch',
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    TextFormField(
                      key: const Key('transaction-amount-field'),
                      controller: _amountController,
                      enabled: !isMutating,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Số tiền',
                        hintText: '0',
                        prefixIcon: Icon(Icons.payments_outlined),
                        suffixText: '₫',
                      ),
                      validator: Validators.positiveInteger,
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedType),
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        for (final category in categories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                      ],
                      onChanged: isMutating
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _selectedCategory = value);
                              }
                            },
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        enabled: !isMutating,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Ngày giao dịch'),
                        subtitle: Text(
                          DateFormatter.formatDayMonthYear(_selectedDate),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    TextFormField(
                      key: const Key('transaction-note-field'),
                      controller: _noteController,
                      enabled: !isMutating,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 250,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú (không bắt buộc)',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceLg),
                    FilledButton.icon(
                      key: const Key('save-transaction-button'),
                      onPressed: isMutating ? null : _saveTransaction,
                      icon: isMutating
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(isMutating ? 'Đang lưu...' : AppStrings.save),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _saveTransaction() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = context.read<TransactionController>();
    final now = DateTime.now();
    final existing = widget.transaction;
    final note = _noteController.text.trim();
    final transaction = TransactionEntry(
      id: existing?.id ?? 'transaction-${now.microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amount: int.parse(_amountController.text),
      type: _selectedType,
      category: _selectedCategory,
      transactionDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      note: note.isEmpty ? null : note,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final succeeded = existing == null
        ? await controller.addTransaction(transaction)
        : await controller.updateTransaction(transaction);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (succeeded) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Đã thêm giao dịch thành công.'
                : 'Đã cập nhật giao dịch thành công.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Không thể lưu giao dịch.'),
        ),
      );
    }
  }
}
