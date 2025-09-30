// lib/src/features/categories/presentation/widgets/wizard_steps/summary_step_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/categories/presentation/providers/add_category_providers.dart';
import 'package:budgit/src/features/categories/presentation/controllers/add_category_controller.dart';

class SummaryStepView extends ConsumerWidget {
  const SummaryStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addCategoryControllerProvider);
    final tempPayments = ref.watch(tempRecurringPaymentsProvider);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Confirm your new category",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Review the details below. You can go back to make changes or press 'Finish' to save.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // --- Budget & Wallet Summary Card ---
          _buildSummaryCard(
            context,
            title: 'Budget & Wallet',
            children: [
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined, size: 28),
                title: const Text('Weekly Wallet'),
                trailing: Text(
                  currencyFormat.format(state.walletAmount ?? 0),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.track_changes_outlined, size: 28),
                title: const Text('Budget Goal'),
                trailing: Text(
                  '${currencyFormat.format(state.budgetAmount ?? 0)} / ${toBeginningOfSentenceCase(state.budgetPeriod.name)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Recurring Payments Summary Card ---
          _buildSummaryCard(
            context,
            title: 'Recurring Payments',
            children: tempPayments.isEmpty
                ? [const ListTile(title: Text('No recurring payments added.'))]
                : tempPayments
                    .map((p) => ListTile(
                          leading: const Icon(Icons.replay_circle_filled_outlined, size: 28),
                          title: Text(p.paymentName),
                          trailing: Text(
                            currencyFormat.format(p.amount),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ))
                    .toList(),
          ),
        ],
      ),
    );
  }

  // Helper method to create consistent cards for the summary
  Widget _buildSummaryCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}