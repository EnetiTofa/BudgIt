// lib/src/features/categories/presentation/widgets/wizard_steps/budget_step_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_dropdown_field.dart';
import 'package:budgit/src/features/categories/domain/budget_enum.dart';
import 'package:budgit/src/features/categories/presentation/controllers/add_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/providers/add_category_providers.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';

class BudgetStepView extends ConsumerWidget {
  const BudgetStepView({super.key});

  // Helper methods are now top-level or moved into the build method's scope
  double _convertToMonthly(double amount, RecurrencePeriod period) {
    switch (period) {
      case RecurrencePeriod.daily: return amount * 30.44;
      case RecurrencePeriod.weekly: return amount * 4.33;
      case RecurrencePeriod.monthly: return amount;
      case RecurrencePeriod.yearly: return amount / 12;
    }
  }

  double _convertAmountToMonthly(double amount, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly: return amount * 4.33;
      case BudgetPeriod.monthly: return amount;
      case BudgetPeriod.yearly: return amount / 12;
    }
  }

  double _convertAmountFromMonthly(double monthlyAmount, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly: return monthlyAmount / 4.33;
      case BudgetPeriod.monthly: return monthlyAmount;
      case BudgetPeriod.yearly: return monthlyAmount * 12;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addCategoryControllerProvider);
    final notifier = ref.read(addCategoryControllerProvider.notifier);
    final tempPayments = ref.watch(tempRecurringPaymentsProvider);
    final theme = Theme.of(context);

    final totalRecurringMonthly = tempPayments.fold<double>(0, (sum, p) => sum + _convertToMonthly(p.amount, p.recurrence));
    final walletMonthly = (state.walletAmount ?? 0) * 4.33;
    final minimumMonthlyBudget = totalRecurringMonthly + walletMonthly;
    final minInCurrentPeriod = _convertAmountFromMonthly(minimumMonthlyBudget, state.budgetPeriod);

    // This ensures the budget is pre-loaded with the minimum if not set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double currentBudgetMonthly = _convertAmountToMonthly(state.budgetAmount ?? 0, state.budgetPeriod);
      if (state.budgetAmount == null || currentBudgetMonthly < minimumMonthlyBudget) {
        notifier.setFinalBudget(amount: minInCurrentPeriod, period: state.budgetPeriod);
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Set your budget goal", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "This is the total amount for this category. You can set it as a weekly, monthly, or yearly figure.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CurrencyInputField(
                  labelText: 'Budget Amount',
                  initialValue: state.budgetAmount ?? 0.0,
                  onChanged: (value) {
                    // Schedule the provider update to run after the build is complete.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final monthlyValue = _convertAmountToMonthly(value, state.budgetPeriod);
                      if (monthlyValue < minimumMonthlyBudget) {
                        notifier.setFinalBudget(amount: minInCurrentPeriod, period: state.budgetPeriod);
                      } else {
                        notifier.setFinalBudget(amount: value, period: state.budgetPeriod);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: CustomDropdownField<BudgetPeriod>(
                  labelText: '',
                  value: state.budgetPeriod,
                  items: BudgetPeriod.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(toBeginningOfSentenceCase(p.name)!),
                          ))
                      .toList(),
                  onChanged: (newPeriod) {
                    if (newPeriod == null || newPeriod == state.budgetPeriod) return;
                    final currentMonthly = _convertAmountToMonthly(state.budgetAmount ?? 0.0, state.budgetPeriod);
                    
                    if (currentMonthly < minimumMonthlyBudget) {
                      final newMin = _convertAmountFromMonthly(minimumMonthlyBudget, newPeriod);
                      notifier.setFinalBudget(amount: newMin, period: newPeriod);
                    } else {
                      final newAmountForPeriod = _convertAmountFromMonthly(currentMonthly, newPeriod);
                      notifier.setFinalBudget(amount: newAmountForPeriod, period: newPeriod);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              "Minimum: \$${minInCurrentPeriod.toStringAsFixed(2)} / ${state.budgetPeriod.name}",
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        ],
      ),
    );
  }
}