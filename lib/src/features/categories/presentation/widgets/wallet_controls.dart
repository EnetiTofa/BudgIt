// lib/src/features/categories/presentation/widgets/wallet_controls.dart

import 'package:flutter/material.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';

class WalletControls extends StatelessWidget {
  const WalletControls({
    super.key,
    required this.state,
    required this.notifier,
  });

  final ManageCategoryState state;
  final ManageCategoryController notifier;

  @override
  Widget build(BuildContext context) {
    final maxWeeklyAllocation = state.availableForAllocation / 4.33;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Weekly Wallet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: () => notifier.resetWalletAmount(),
                tooltip: 'Reset to original amount',
              ),
              IconButton(
                icon: Icon(
                  state.isBudgetLocked ? Icons.lock : Icons.lock_open,
                  color: state.isBudgetLocked 
                    ? Theme.of(context).colorScheme.secondary 
                    : Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => notifier.toggleBudgetLock(),
                tooltip: state.isBudgetLocked ? 'Unlock to expand budget' : 'Lock budget',
              ),
            ],
          ),
          const SizedBox(height: 16),
          CurrencyInputField(
            labelText: 'Weekly Wallet Amount',
            initialValue: state.walletAmount,
            onChanged: (value) => notifier.setWalletAmount(value),
            helperText: state.isBudgetLocked
                ? 'Budget is locked.'
                : 'Budget will expand if needed.',
          ),
          if (state.isBudgetLocked) ...[
            const SizedBox(height: 8),
            Slider(
              value: state.walletAmount.clamp(0.0, maxWeeklyAllocation),
              min: 0.0,
              max: maxWeeklyAllocation > 0 ? maxWeeklyAllocation : 1.0,
              onChanged: (value) => notifier.setWalletAmount(value),
            ),
          ],
        ],
      ),
    );
  }
}