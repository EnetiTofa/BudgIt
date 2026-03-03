// lib/src/features/budget_hub/wallet/presentation/widgets/active_transfers_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/transfer_form.dart';
import 'package:budgit/src/utils/clock_provider.dart';

// FIX 1: Point to the correct transfer controller
import 'package:budgit/src/features/budget_hub/presentation/controllers/transfer_controller.dart';

class ActiveTransfersSection extends ConsumerWidget {
  final Category category;

  const ActiveTransfersSection({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // FIX 2: Use the renamed transferControllerProvider
    final transferStateAsync = ref.watch(transferControllerProvider(category));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Active Transfers", // Renamed for consistency
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        transferStateAsync.when(
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: LinearProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (state) {
            // FIX 3: Point to initialTransfers instead of initialTransfers
            final transfersMap = state.initialTransfers;
            if (transfersMap.isEmpty) return const SizedBox.shrink();

            return Column(
              children: transfersMap.entries.map((entry) {
                final fromCategoryId = entry.key;
                final amount = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Dismissible(
                    key: Key('transfer_$fromCategoryId'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.delete,
                        color: theme.colorScheme.onError,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Transfer?"),
                          content: const Text(
                            "Are you sure you want to remove this transfer? Funds will return to the source category.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      final controller = ref.read(
                        transferControllerProvider(category).notifier,
                      );
                      controller.updateAmount(fromCategoryId, 0.0);
                      controller.confirmTransfers();
                    },
                    child: _ExistingTransferCard(
                      fromCategoryId: fromCategoryId,
                      amount: amount,
                      targetCategory: category,
                      onTap: () {
                        final now = ref.read(clockNotifierProvider).now();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          // FIX 4: Use TransferForm instead of TransferForm
                          builder: (_) => TransferForm(
                            targetCategory: category,
                            initialTransfer: BudgetTransfer(
                              id: 'temp_edit',
                              fromCategoryId: fromCategoryId,
                              toCategoryId: category.id,
                              amount: amount,
                              date: now,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 4),
        _AddTransferButton(category: category),
      ],
    );
  }
}

class _AddTransferButton extends StatelessWidget {
  final Category category;
  const _AddTransferButton({required this.category});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          // FIX 5: Use TransferForm instead of TransferForm
          builder: (_) => TransferForm(targetCategory: category),
        );
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text("Add Transfer"),
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _ExistingTransferCard extends ConsumerWidget {
  final String fromCategoryId;
  final double amount;
  final Category targetCategory;
  final VoidCallback onTap;

  const _ExistingTransferCard({
    required this.fromCategoryId,
    required this.amount,
    required this.targetCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    final source = categories.firstWhere(
      (c) => c.id == fromCategoryId,
      orElse: () => Category(
        id: 'unknown',
        name: 'Unknown',
        iconCodePoint: Icons.help_outline.codePoint,
        colorValue: Colors.grey.value,
        budgetAmount: 0,
      ),
    );

    final sourceColor = Color(source.colorValue);
    final contentColor = source.contentColor;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: sourceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        leading: Icon(
          IconData(source.iconCodePoint, fontFamily: 'MaterialIcons'),
          color: contentColor,
          size: 24,
        ),
        title: Text(
          "From ${source.name}",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: contentColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "+\$${amount.toStringAsFixed(0)}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 16, color: contentColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
