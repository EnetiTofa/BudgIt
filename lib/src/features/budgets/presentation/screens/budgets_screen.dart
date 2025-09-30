// lib/src/features/budgets/presentation/screens/budgets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/presentation/providers/budget_screen_data_provider.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/budget_gauge.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/budget_list.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/budget_timeline.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/monthly_summary_card.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/category_detail_view.dart';

final selectedCategoryProvider = StateProvider.autoDispose<Category?>((ref) => null);
final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetDataAsync = ref.watch(budgetScreenDataProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: budgetDataAsync.when(
        skipLoadingOnReload: true,
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (screenData) {
          final selectedMonth = ref.watch(selectedMonthProvider) ??
              (screenData.historicalSpending.isNotEmpty
                  ? screenData.historicalSpending.last.date
                  : DateTime.now());
          
          return AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              // --- THE FIX IS HERE ---
              child: selectedCategory == null
                // 1. Pass a key to the overview widget.
                ? _buildOverview(context, ref, screenData, selectedMonth, key: const ValueKey('overview'))
                // 2. Pass a unique key and the categoryId to the detail view.
                : CategoryDetailView(
                    key: ValueKey(selectedCategory.id),
                    categoryId: selectedCategory.id,
                  ),
              // --- END OF FIX ---
            ),
          );
        },
      ),
    );
  }

  // MODIFIED: Add the optional Key parameter to the method signature.
  Widget _buildOverview(BuildContext context, WidgetRef ref, BudgetScreenData screenData, DateTime selectedMonth, {Key? key}) {
    // Pass the key to the root widget of this build method.
    return SingleChildScrollView(
      key: key,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(62.0, 0.0, 62.0, 0.0),
            child: BudgetGauge(
              progressList: screenData.budgetProgress,
              selectedDate: selectedMonth,
            ),
          ),
          const SizedBox(height: 0),
          BudgetTimeline(
            spendingData: screenData.historicalSpending,
            selectedMonth: selectedMonth,
            onMonthSelected: (newMonth) {
              ref.read(selectedMonthProvider.notifier).state =
                  newMonth;
            },
          ),
          const SizedBox(height: 12),
          BudgetList(
            progressList: screenData.budgetProgress,
            onCategoryTap: (category) {
              ref.read(selectedCategoryProvider.notifier).state = category;
            },
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: MonthlySummaryCard(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}