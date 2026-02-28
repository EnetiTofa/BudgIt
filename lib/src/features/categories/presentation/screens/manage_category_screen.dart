import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/overall_budget_summary_provider.dart';
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/widgets/interactive_budget_gauge.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/categories/presentation/widgets/income_context_bar.dart';
import 'package:budgit/src/features/categories/presentation/widgets/total_budget_controls.dart';
import 'package:budgit/src/features/categories/presentation/widgets/recurring_controls.dart';
// Note: We are replacing wallet_controls.dart with a new informative view below

class ManageCategoryScreen extends ConsumerStatefulWidget {
  const ManageCategoryScreen({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<ManageCategoryScreen> createState() =>
      _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends ConsumerState<ManageCategoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  GaugeSegmentType _selectedSegment = GaugeSegmentType.center;

  // REFACTORED: Mapped to the new Binary Paradigm
  final Map<int, GaugeSegmentType> _pageIndexToSegment = {
    0: GaugeSegmentType.center,
    1: GaugeSegmentType.fixed,
    2: GaugeSegmentType.variable,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newSegment = _pageIndexToSegment[_tabController.index];
        if (newSegment != null) {
          setState(() {
            _selectedSegment = newSegment;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onGaugeTapped(GaugeSegmentType segment) {
    if (segment == GaugeSegmentType.none) return;

    final pageIndex = _pageIndexToSegment.entries
        .firstWhere(
          (entry) => entry.value == segment,
          orElse: () => _pageIndexToSegment.entries.first,
        )
        .key;

    _tabController.animateTo(pageIndex);
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.category.icon, color: widget.category.color),
            const SizedBox(width: 8),
            Text('Manage ${widget.category.name}'),
          ],
        ),
        actions: [
          stateAsync.maybeWhen(
            data: (_) => TextButton(
              onPressed: () async {
                await notifier.saveChanges();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
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
                        child: Center(child: Text('Error')),
                      ),
                    ),
                    loading: () => const SizedBox(height: 80),
                    error: (e, s) => const SizedBox(
                      height: 80,
                      child: Center(child: Text('Error')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 0.0,
                    ),
                    child: InteractiveBudgetGauge(
                      category: widget.category,
                      state: state,
                      selectedSegment: _selectedSegment,
                      onSegmentTapped: _onGaugeTapped,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          // REFACTORED: Tab names map to our binary domains
                          tabs: const [
                            Tab(text: 'Total'),
                            Tab(text: 'Fixed'),
                            Tab(text: 'Variable'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        IndexedStack(
                          index: _tabController.index,
                          children: [
                            TotalBudgetControls(
                              state: state,
                              notifier: notifier,
                            ),
                            RecurringControls(state: state, notifier: notifier),
                            // REPLACED WalletControls WITH OUR NEW VIEW
                            _VariableAllowanceInfoView(state: state),
                          ],
                        ),
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

// --- NEW COMPONENT: Explains the implicit math to the user ---
// You can extract this into its own file (e.g., variable_allowance_info_view.dart) later.
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
