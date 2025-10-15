// lib/src/features/categories/presentation/manage_category_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/budgets/presentation/providers/overall_budget_summary_provider.dart';
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/widgets/interactive_budget_gauge.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/categories/presentation/widgets/income_context_bar.dart';
import 'package:budgit/src/features/categories/presentation/widgets/total_budget_controls.dart';
import 'package:budgit/src/features/categories/presentation/widgets/wallet_controls.dart';
import 'package:budgit/src/features/categories/presentation/widgets/recurring_controls.dart';


class ManageCategoryScreen extends ConsumerStatefulWidget {
  const ManageCategoryScreen({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<ManageCategoryScreen> createState() =>
      _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends ConsumerState<ManageCategoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  GaugeSegmentType _selectedSegment = GaugeSegmentType.center;

  final Map<int, GaugeSegmentType> _pageIndexToSegment = {
    0: GaugeSegmentType.center,
    1: GaugeSegmentType.wallet,
    2: GaugeSegmentType.recurring,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      // The setState call here is now crucial for updating the IndexedStack
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
    if (segment == GaugeSegmentType.oneOffs) return;

    final pageIndex = _pageIndexToSegment.entries
        .firstWhere((entry) => entry.value == segment, orElse: () => _pageIndexToSegment.entries.first)
        .key;
    
    _tabController.animateTo(pageIndex);
  }


  @override
  Widget build(BuildContext context) {
    final stateAsync =
        ref.watch(manageCategoryControllerProvider(widget.category.id));
    final notifier =
        ref.read(manageCategoryControllerProvider(widget.category.id).notifier);
    final summaryAsync = ref.watch(overallBudgetSummaryProvider);
    final allCategoriesAsync = ref.watch(categoryListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.category.icon,
              color: widget.category.color,
            ),
            const SizedBox(width: 8),
            Text('Manage ${widget.category.name}'),
          ],
        ),
        actions: [
          stateAsync.maybeWhen(
              data: (_) => TextButton(
                    onPressed: () {
                      notifier.saveChanges();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
              orElse: () => const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )),
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
                      error: (e, s) => const SizedBox(height: 80, child: Center(child: Text('Error'))),
                    ),
                    loading: () => const SizedBox(height: 80),
                    error: (e, s) => const SizedBox(height: 80, child: Center(child: Text('Error'))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 0.0),
                    child: InteractiveBudgetGauge(
                      category: widget.category,
                      state: state,
                      selectedSegment: _selectedSegment,
                      onSegmentTapped: _onGaugeTapped,
                    ),
                  ),
                  // --- START OF CHANGES ---
                  // We no longer need a SizedBox with a fixed height.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Column(
                      children: [
                        // The TabBar remains the same
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Total'),
                            Tab(text: 'Wallet'),
                            Tab(text: 'Recurring'),
                          ],
                        ),
                        const SizedBox(height: 8), // Some spacing
                        // We replace TabBarView with an IndexedStack
                        IndexedStack(
                          index: _tabController.index,
                          children: [
                            TotalBudgetControls(state: state, notifier: notifier),
                            WalletControls(state: state, notifier: notifier),
                            RecurringControls(state: state, notifier: notifier),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // --- END OF CHANGES ---
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