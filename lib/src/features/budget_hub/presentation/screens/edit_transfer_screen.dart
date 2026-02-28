import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/transfer_form.dart';

// FIX 1: Point to the updated transfer controller location
import 'package:budgit/src/features/budget_hub/presentation/controllers/transfer_controller.dart';

// FIX 2: Renamed class to EditTransferScreen
class EditTransferScreen extends ConsumerWidget {
  final Category targetCategory;
  final BudgetTransfer transfer; // Renamed from boost

  const EditTransferScreen({
    super.key,
    required this.targetCategory,
    required this.transfer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transfer'), // Renamed text
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmAndDelete(context, ref),
          ),
        ],
      ),
      // FIX 3: Call TransferForm and pass initialTransfer
      body: TransferForm(
        targetCategory: targetCategory,
        initialTransfer: transfer,
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Transfer?"), // Renamed text
          content: const Text(
            "Are you sure you want to remove this transfer? The funds will remain in the source category.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      // FIX 4: Use transferControllerProvider and its correct methods
      final controller = ref.read(
        transferControllerProvider(targetCategory).notifier,
      );
      controller.updateAmount(transfer.fromCategoryId, 0.0);
      controller.confirmTransfers();

      Navigator.pop(context);
    }
  }
}
