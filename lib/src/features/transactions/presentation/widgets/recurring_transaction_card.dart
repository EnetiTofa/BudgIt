import 'package:flutter/material.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_income_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_payment_screen.dart';

class RecurringTransactionCard extends StatelessWidget {
  final Transaction transaction;

  const RecurringTransactionCard({super.key, required this.transaction});

  // Helper function to build the recurrence string correctly
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

    if (frequency == 1) {
      return 'Every $periodUnit';
    } else {
      return 'Every $frequency ${periodUnit}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget listTile;
    final theme = Theme.of(context);
    final item = transaction;

    if (item is RecurringPayment) {
      final recurrenceText = _getRecurrenceText(item.recurrenceFrequency, item.recurrence);
      listTile = ListTile(
        leading: CircleAvatar(
          backgroundColor: item.category.color,
          child: Icon(item.category.icon, color: theme.colorScheme.surfaceContainerLow),
        ),
        title: Text(
          item.paymentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(item.payee),
        trailing: RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style, // Use default text style
            children: <TextSpan>[
              TextSpan(
                text: '-\$${item.amount.toStringAsFixed(2)}\n',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              TextSpan(
                text: recurrenceText,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EditPaymentScreen(transaction: item),
          ));
        },
      );
    } else if (item is RecurringIncome) {
      final recurrenceText = _getRecurrenceText(item.recurrenceFrequency, item.recurrence);
      listTile = ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[600],
          child: Icon(
            IconData(item.iconCodePoint, fontFamily: item.iconFontFamily),
            color: theme.colorScheme.surfaceContainerLow
          ),
        ),
        title: Text(
          item.source,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(item.reference ?? ''),
        trailing: RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style, // Use default text style
            children: <TextSpan>[
              TextSpan(
                text: '+\$${item.amount.toStringAsFixed(2)}\n',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              TextSpan(
                text: recurrenceText,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EditIncomeScreen(transaction: item),
          ));
        },
      );
    } else {
      listTile = const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 0,
      child: listTile,
    );
  }
}