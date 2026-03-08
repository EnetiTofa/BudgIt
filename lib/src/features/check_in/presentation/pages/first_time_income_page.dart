import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/add_income_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/edit_income_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/add_transaction_controller.dart';

class FirstTimeIncomePage extends ConsumerStatefulWidget {
  const FirstTimeIncomePage({super.key});

  @override
  ConsumerState<FirstTimeIncomePage> createState() =>
      _FirstTimeIncomePageState();
}

class _FirstTimeIncomePageState extends ConsumerState<FirstTimeIncomePage> {
  // Keeps track of root IDs currently being deleted so Flutter doesn't panic
  final Set<String> _pendingDeletions = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(transactionLogProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "Add Income Sources",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Let's figure out how much money you have to work with. Add your regular paychecks or initial bank balance.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                // 1. Group occurrences by their true root ID so we only show sources
                final Map<String, Transaction> uniqueSources = {};

                for (final t in transactions) {
                  if (t is OneOffIncome || t is RecurringIncome) {
                    // Find the true parent ID
                    final trueId =
                        (t is OneOffIncome && t.parentRecurringId != null)
                        ? t.parentRecurringId!
                        : t.id;

                    // Only add if we haven't already added this source, AND it's not pending deletion
                    if (!uniqueSources.containsKey(trueId) &&
                        !_pendingDeletions.contains(trueId)) {
                      uniqueSources[trueId] = t;
                    }
                  }
                }

                final incomes = uniqueSources.values.toList();

                if (incomes.isEmpty) {
                  return Center(
                    child: Text(
                      "No income sources added yet.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: incomes.length,
                  itemBuilder: (context, index) {
                    final income = incomes[index];

                    // 2. Grab the correct True ID for database operations
                    final String trueId =
                        (income is OneOffIncome &&
                            income.parentRecurringId != null)
                        ? income.parentRecurringId!
                        : income.id;

                    final String incomeName = income is OneOffIncome
                        ? income.source
                        : (income as RecurringIncome).source;

                    return Dismissible(
                      key: Key(trueId), // Use True ID here!
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) {
                        // Hide instantly, then delete the True Root ID from DB
                        setState(() {
                          _pendingDeletions.add(trueId);
                        });
                        ref
                            .read(addTransactionControllerProvider.notifier)
                            .deleteTransaction(trueId);
                      },
                      child: Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerLow,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditIncomeScreen(transaction: income),
                              ),
                            );
                          },
                          child: ListTile(
                            minTileHeight: 70,
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.attach_money,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              incomeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              "+\$${income.amount.toStringAsFixed(0)}",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green.shade400,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) =>
                  const Center(child: Text("Error loading incomes")),
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              "Add an Income Source",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tap an item to edit it, or swipe left to delete.",
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
