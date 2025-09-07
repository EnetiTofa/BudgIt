import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/budgets/presentation/budget_card.dart';
import 'package:budgit/src/features/budgets/presentation/budget_progress_provider.dart';

// An enum to represent the different views, used by the provider.
enum BudgetView { monthly, threeMonthly, sixMonthly, yearly }

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  // This state variable controls which timeframe is selected.
  BudgetView _selectedView = BudgetView.monthly;

  @override
  Widget build(BuildContext context) {
    // The provider is watched with the selected view, so it recalculates when the view changes.
    final budgetProgressAsync = ref.watch(budgetProgressProvider(_selectedView));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: CustomToggle(
            options: const ['Monthly', '3-Monthly', '6-Monthly', 'Yearly'],
            // The selectedValue for the toggle needs to be a string.
            selectedValue: _mapViewToSelectedValue(_selectedView),
            onChanged: (value) {
              setState(() {
                _selectedView = _mapSelectedValueToView(value);
              });
            },
          ),
        ),
        Expanded(
          child: switch (budgetProgressAsync) {
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
            AsyncError(:final error) => Center(child: Text('Error: $error')),
            AsyncData(:final value) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return BudgetCard(progress: value[index]);
                },
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  // Helper methods to convert between the enum and the string values for the toggle.
  String _mapViewToSelectedValue(BudgetView view) {
    switch (view) {
      case BudgetView.monthly:
        return 'Monthly';
      case BudgetView.threeMonthly:
        return '3-Monthly';
      case BudgetView.sixMonthly:
        return '6-Monthly';
      case BudgetView.yearly:
        return 'Yearly';
    }
  }

  BudgetView _mapSelectedValueToView(String value) {
    switch (value) {
      case '3-Monthly':
        return BudgetView.threeMonthly;
      case '6-Monthly':
        return BudgetView.sixMonthly;
      case 'Yearly':
        return BudgetView.yearly;
      default:
        return BudgetView.monthly;
    }
  }
}