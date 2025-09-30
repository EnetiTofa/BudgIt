import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budgit/src/features/categories/presentation/providers/add_category_providers.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/widgets/add_recurring_payment_form.dart';

class RecurringStepView extends ConsumerWidget {
  const RecurringStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tempPayments = ref.watch(tempRecurringPaymentsProvider);
    final hasPayments = tempPayments.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Include recurring costs?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Add any regular payments for this category, like subscriptions or bills.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (hasPayments)
            Expanded(
              child: ListView.builder(
                itemCount: tempPayments.length,
                itemBuilder: (context, index) {
                  final payment = tempPayments[index];
                  return Dismissible(
                    key: ValueKey(payment.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      ref
                          .read(tempRecurringPaymentsProvider.notifier)
                          .removePayment(payment.id);
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text('${payment.paymentName} removed')));
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: _TempPaymentCard(
                      payment: payment,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddRecurringPaymentForm(initialPayment: payment),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          else
            const Expanded(
                child: Center(child: Text('No recurring payments added yet.'))),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Recurring Payment'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AddRecurringPaymentForm()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TempPaymentCard extends StatelessWidget {
  final RecurringPayment payment;
  final VoidCallback onTap;

  const _TempPaymentCard({required this.payment, required this.onTap});

  String _getRecurrenceText(int frequency, RecurrencePeriod period) {
    String periodUnit;
    switch (period) {
      case RecurrencePeriod.daily:
        periodUnit = 'Day';
        break;
      case RecurrencePeriod.weekly:
        periodUnit = 'Week';
        break;
      case RecurrencePeriod.monthly:
        periodUnit = 'Month';
        break;
      case RecurrencePeriod.yearly:
        periodUnit = 'Year';
        break;
    }
    if (frequency == 1) return 'Every $periodUnit';
    return 'Every $frequency ${periodUnit}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recurrenceText =
        _getRecurrenceText(payment.recurrenceFrequency, payment.recurrence);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        title: Text(payment.paymentName,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(payment.payee),
        trailing: RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: '-\$${payment.amount.toStringAsFixed(2)}\n',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
              TextSpan(
                text: recurrenceText,
                style: TextStyle(
                    fontSize: 12, color: theme.colorScheme.secondary),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}