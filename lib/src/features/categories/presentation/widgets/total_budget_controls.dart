import 'package:flutter/material.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_dropdown_field.dart';
import 'package:budgit/src/core/domain/enums/budget_enum.dart';
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';

class TotalBudgetControls extends StatelessWidget {
  const TotalBudgetControls({
    super.key,
    required this.state,
    required this.notifier,
  });

  final ManageCategoryState state;
  final ManageCategoryController notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Total Ceiling',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: () => notifier.resetTotalBudget(),
                tooltip: 'Reset to original amount',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CurrencyInputField(
                  labelText: 'Amount',
                  initialValue: state.displayTotalBudget,
                  onChanged: (value) => notifier.setTotalBudget(value),
                  minValue: state.minimumBudget,
                  // Safety hint: Let them know they can't go lower than their bills
                  helperText:
                      "Cannot be lower than fixed bills (\$${state.minimumBudget.toStringAsFixed(0)})",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: CustomDropdownField<BudgetPeriod>(
                  labelText: 'Period',
                  value: state.budgetPeriod,
                  items: BudgetPeriod.values.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(
                        period.name.substring(0, 1).toUpperCase() +
                            period.name.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      notifier.setBudgetPeriod(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => notifier.minimizeBudget(),
              child: const Text('Minimize to Match Fixed Bills'),
            ),
          ),
        ],
      ),
    );
  }
}
