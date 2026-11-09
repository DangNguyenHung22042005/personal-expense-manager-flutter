import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(
         (actionLabel == null && onAction == null) ||
             (actionLabel != null && onAction != null),
         'actionLabel and onAction must be provided together.',
       );

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: colorScheme.primary),
          const SizedBox(height: AppSizes.spaceMd),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          if (onAction != null) ...[
            const SizedBox(height: AppSizes.spaceMd),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
