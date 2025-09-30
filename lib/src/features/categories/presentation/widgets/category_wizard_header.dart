// lib/src/features/categories/presentation/widgets/category_wizard_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/categories/presentation/controllers/add_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/providers/add_category_providers.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/domain/budget_enum.dart';


class CategoryWizardHeader extends ConsumerWidget {
  const CategoryWizardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addCategoryControllerProvider);
    final tempPayments = ref.watch(tempRecurringPaymentsProvider);
    
    double displayBudgetMonthly;

    // --- NEW CONDITIONAL LOGIC ---
    // If we are on the budget or summary step, display the user's chosen budget.
    // Otherwise, display the running total of fixed costs.
    if ((state.step == AddCategoryStep.budget || state.step == AddCategoryStep.summary) && state.budgetAmount != null) {
      // Convert the user's entered budget (which could be weekly/yearly) to a monthly equivalent.
      switch (state.budgetPeriod) {
        case BudgetPeriod.weekly:
          displayBudgetMonthly = state.budgetAmount! * 4.33;
          break;
        case BudgetPeriod.monthly:
          displayBudgetMonthly = state.budgetAmount!;
          break;
        case BudgetPeriod.yearly:
          displayBudgetMonthly = state.budgetAmount! / 12;
          break;
      }
    } else {
      // On earlier steps, calculate and display the "running total".
      final totalRecurringMonthly = tempPayments.fold<double>(
          0, (sum, p) => sum + _convertToMonthly(p.amount, p.recurrence));
      final walletMonthly = (state.walletAmount ?? 0) * 4.33;
      displayBudgetMonthly = totalRecurringMonthly + walletMonthly;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildCollapsedView(context, state, displayBudgetMonthly),
    );
  }

  double _convertToMonthly(double amount, RecurrencePeriod period) {
    switch (period) {
      case RecurrencePeriod.daily:
        return amount * 30.44;
      case RecurrencePeriod.weekly:
        return amount * 4.33;
      case RecurrencePeriod.monthly:
        return amount;
      case RecurrencePeriod.yearly:
        return amount / 12;
    }
  }

  Widget _buildCollapsedView(
      BuildContext context, AddCategoryState state, double displayBudgetMonthly) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: state.color,
                child: Icon(state.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.name.isEmpty ? 'New Category' : state.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BudgetDisplay(
                  label: 'Weekly', amount: displayBudgetMonthly / 4.33),
              _BudgetDisplay(label: 'Monthly', amount: displayBudgetMonthly),
              _BudgetDisplay(
                  label: 'Yearly', amount: displayBudgetMonthly * 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetDisplay extends StatelessWidget {
  final String label;
  final double amount;
  const _BudgetDisplay({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text('\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}