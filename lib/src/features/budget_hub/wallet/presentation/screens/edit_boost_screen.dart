import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/boost_form.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/controllers/boost_controller.dart';

class EditBoostScreen extends ConsumerWidget {
  final Category targetCategory;
  final WalletAdjustment boost;

  const EditBoostScreen({
    super.key, 
    required this.targetCategory,
    required this.boost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Boost'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmAndDelete(context, ref),
          ),
        ],
      ),
      body: BoostForm(
        targetCategory: targetCategory,
        initialBoost: boost,
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Boost?"),
          content: const Text(
            "Are you sure you want to remove this boost? The funds will remain in the source category."
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
      // Logic: Set amount to 0 effectively removes it in the controller logic
      final controller = ref.read(boostStateProvider(targetCategory).notifier);
      controller.updateAmount(boost.fromCategoryId, 0.0);
      controller.confirmBoosts();
      
      Navigator.pop(context);
    }
  }
}