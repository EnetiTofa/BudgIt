// lib/src/features/settings/presentation/manage_payees_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/custom_payees_provider.dart';

class ManagePayeesScreen extends ConsumerWidget {
  const ManagePayeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customPayees = ref.watch(customPayeesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Custom Payees')),
      body: customPayees.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No custom payees saved yet.\n\nType a new store or payee name when adding a payment to automatically save it here.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    height: 1.5,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: customPayees.length,
              itemBuilder: (context, index) {
                final payee = customPayees[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    payee,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () {
                      ref
                          .read(customPayeesProvider.notifier)
                          .removePayee(payee);

                      // Show a quick confirmation snackbar
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed "$payee"'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Delete $payee',
                  ),
                );
              },
            ),
    );
  }
}
