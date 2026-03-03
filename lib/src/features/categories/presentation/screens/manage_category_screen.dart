// lib/src/features/categories/presentation/screens/manage_category_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';

import 'package:budgit/src/features/budget_hub/presentation/providers/overall_budget_summary_provider.dart';
import 'package:budgit/src/features/categories/presentation/widgets/income_context_bar.dart';
import 'package:budgit/src/features/categories/presentation/widgets/interactive_budget_gauge.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

// Controls
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/widgets/total_budget_controls.dart';
import 'package:budgit/src/features/categories/presentation/widgets/recurring_controls.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/add_transaction_controller.dart';

class ManageCategoryScreen extends ConsumerStatefulWidget {
  const ManageCategoryScreen({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<ManageCategoryScreen> createState() =>
      _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends ConsumerState<ManageCategoryScreen> {
  GaugeSegmentType _selectedSegment = GaugeSegmentType.center;

  void _onGaugeTapped(GaugeSegmentType segment) {
    if (segment != GaugeSegmentType.none) {
      setState(() {
        _selectedSegment = segment;
      });
    }
  }

  Future<void> _saveChanges() async {
    final notifier = ref.read(
      manageCategoryControllerProvider(widget.category.id).notifier,
    );
    await notifier.saveChanges();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // ... inside your _ManageCategoryScreenState class ...

  Future<void> _deleteCategory() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete the "${widget.category.name}" category? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // --- CHANGED THIS SECTION ---
      // We use addTransactionControllerProvider instead of categoryListProvider
      final controller = ref.read(addTransactionControllerProvider.notifier);
      await controller.deleteCategory(widget.category.id);
      // ----------------------------

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(
      manageCategoryControllerProvider(widget.category.id),
    );
    final notifier = ref.read(
      manageCategoryControllerProvider(widget.category.id).notifier,
    );
    final summaryAsync = ref.watch(overallBudgetSummaryProvider);
    final allCategoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Budget'),
        actions: [
          stateAsync.maybeWhen(
            data: (_) =>
                TextButton(onPressed: _saveChanges, child: const Text('Save')),
            orElse: () => const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  summaryAsync.when(
                    data: (summary) => allCategoriesAsync.when(
                      data: (allCategories) => IncomeContextBar(
                        summary: summary,
                        allCategories: allCategories,
                        thisCategory: state.initialCategory,
                      ),
                      loading: () => const SizedBox(height: 80),
                      error: (e, s) => const SizedBox(
                        height: 80,
                        child: Center(child: Text('Error loading categories')),
                      ),
                    ),
                    loading: () => const SizedBox(height: 80),
                    error: (e, s) => const SizedBox(
                      height: 80,
                      child: Center(child: Text('Error loading summary')),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 16.0,
                    ),
                    child: InteractiveBudgetGauge(
                      category: widget.category,
                      state: state,
                      selectedSegment: _selectedSegment,
                      onSegmentTapped: _onGaugeTapped,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. RECURRING TRANSACTIONS ---
                        Text(
                          'Recurring Bills',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fixed subscriptions or payments inside this category.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RecurringControls(state: state, notifier: notifier),

                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 24),

                        // --- 2. TOTAL BUDGET ---
                        Text(
                          'Monthly Budget',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set the total monthly allowance for this category.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TotalBudgetControls(state: state, notifier: notifier),

                        const SizedBox(height: 32),
                        const Divider(),

                        _VariableAllowanceInfoView(state: state),

                        const SizedBox(height: 32),

                        // --- NEW: DELETE BUTTON ---
                        Center(
                          child: TextButton.icon(
                            onPressed: _deleteCategory,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete Category'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _VariableAllowanceInfoView extends StatelessWidget {
  final ManageCategoryState state;
  const _VariableAllowanceInfoView({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weeklyAllowance = state.variableBudget / 4.333;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            "Dynamically Calculated",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your variable allowance is automatically derived from the funds remaining after your fixed bills are paid.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _MathRow(
                  label: "Total Monthly Budget",
                  amount: state.totalBudget,
                  isPositive: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                _MathRow(
                  label: "Fixed Monthly Bills",
                  amount: state.recurringSum,
                  isPositive: false,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                _MathRow(
                  label: "Remaining Variable Funds",
                  amount: state.variableBudget,
                  isPositive: true,
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "~ \$${weeklyAllowance.toStringAsFixed(0)} / week",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This is your safe weekly spending limit.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MathRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;
  final bool isBold;

  const _MathRow({
    required this.label,
    required this.amount,
    required this.isPositive,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 16 : 14,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          "${isPositive ? '' : '- '}\$${amount.toStringAsFixed(2)}",
          style: style.copyWith(
            color: isPositive ? null : Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }
}
