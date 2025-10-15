// lib/src/features/budgets/presentation/widgets/upcoming_transaction_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/transactions/presentation/providers/next_recurring_payment_provider.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/app/navigation_provider.dart';

class UpcomingTransactionCard extends ConsumerWidget {
  final String categoryId;
  const UpcomingTransactionCard({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPaymentAsync = ref.watch(nextRecurringPaymentProvider(categoryId: categoryId));
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: () {
          // 1. Pop the current detail screen to return to the overview
          Navigator.of(context).pop();
          
          // 2. Set the data filters for the recurring screen
          final filterNotifier = ref.read(logFilterProvider.notifier);
          filterNotifier.setTransactionType(TransactionTypeFilter.payment);
          filterNotifier.setSelectedCategoryIds({categoryId});
          
          // 3. Set the navigation state to switch main app tabs
          ref.read(transactionHubTabIndexProvider.notifier).setIndex(1);
          ref.read(mainPageIndexProvider.notifier).setIndex(1); // Or 2, etc.
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // ...rest of the widget code is unchanged...
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Transactions',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              nextPaymentAsync.when(
                skipLoadingOnRefresh: true,
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )),
                error: (err, stack) => Text('Could not load data.', style: TextStyle(color: colorScheme.error)),
                data: (nextPayment) {
                  if (nextPayment == null) {
                    return Text(
                      'No upcoming recurring payments found for this category.',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    );
                  }
                  return Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 32, color: colorScheme.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nextPayment.itemName, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                            Text(DateFormat.yMMMd().format(nextPayment.date), style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Text(
                        '-\$${nextPayment.amount.toStringAsFixed(2)}',
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}