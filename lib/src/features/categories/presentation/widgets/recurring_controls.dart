// lib/src/features/categories/presentation/widgets/recurring_controls.dart

import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/widgets/add_recurring_payment_form.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';

class RecurringControls extends StatelessWidget {
  const RecurringControls({
    super.key,
    required this.state,
    required this.notifier,
  });

  final ManageCategoryState state;
  final ManageCategoryController notifier;

  @override
  Widget build(BuildContext context) {
    final payments = state.recurringTransactions;
    final hasPayments = payments.isNotEmpty;

    // Removed the outer padding so it matches the parent screen's width exactly
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasPayments)
          Column(
            children: [
              for (final payment in payments)
                Dismissible(
                  key: ValueKey(payment.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) =>
                      notifier.removeRecurringPayment(payment.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: RecurringPaymentCard(
                    payment: payment,
                    category: state.initialCategory,
                    onTap: () async {
                      final result = await Navigator.of(context)
                          .push<RecurringPayment>(
                            MaterialPageRoute(
                              builder: (context) => AddRecurringPaymentForm(
                                category: state.initialCategory,
                                initialPayment: payment,
                              ),
                            ),
                          );
                      if (result != null) {
                        notifier.updateRecurringPayment(result);
                      }
                    },
                  ),
                ),
            ],
          )
        else
          const SizedBox(
            height: 48,
            child: Center(child: Text('No recurring payments added yet.')),
          ),

        const SizedBox(height: 16),

        // Made the button full width to match the rest of the UI
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Recurring Payment'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push<RecurringPayment>(
                MaterialPageRoute(
                  builder: (context) =>
                      AddRecurringPaymentForm(category: state.initialCategory),
                ),
              );
              if (result != null) {
                notifier.addRecurringPayment(result);
              }
            },
          ),
        ),
      ],
    );
  }
}

class RecurringPaymentCard extends StatelessWidget {
  final RecurringPayment payment;
  final Category category;
  final VoidCallback onTap;

  const RecurringPaymentCard({
    super.key,
    required this.payment,
    required this.category,
    required this.onTap,
  });

  String _getRecurrenceText() {
    if (payment.recurrence == RecurrencePeriod.monthly) {
      final day = payment.startDate.day;
      String suffix;
      if (day >= 11 && day <= 13) {
        suffix = 'th';
      } else {
        switch (day % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      return 'Monthly on the $day$suffix';
    }
    return 'Repeats ${payment.recurrence.name}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // Changed vertical margins to match a full-width flat list look
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(category.icon, color: theme.colorScheme.secondary),
        title: Text(
          payment.paymentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_getRecurrenceText()),
        trailing: Text(
          '-\$${payment.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
