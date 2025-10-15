// lib/src/features/budgets/presentation/widgets/category_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/category_gauge.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/historical_category_chart.dart';
import 'package:budgit/src/features/budgets/presentation/providers/category_gauge_data_provider.dart';
import 'package:budgit/src/features/budgets/presentation/providers/historical_category_spending_provider.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/upcoming_transaction_card.dart';
import 'package:budgit/src/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:budgit/src/features/categories/presentation/screens/manage_category_screen.dart';
import 'package:budgit/src/utils/palette_generator.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';


class CategoryDetailView extends ConsumerStatefulWidget {
  const CategoryDetailView({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  ConsumerState<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends ConsumerState<CategoryDetailView> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth =
        ref.read(selectedMonthProvider) ?? DateTime(now.year, now.month, 1);
  }

  Widget _buildChartPlaceholder(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
              7,
              (i) => Container(
                    width: 22,
                    height: (i.isEven ? 80 : 50) *
                        (i == 3 ? 1.4 : 1.0), // Varied heights
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final categoryListAsync = ref.watch(categoryListProvider);

    return categoryListAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (cat) => cat.id == widget.categoryId,
          orElse: () {
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (Navigator.canPop(context)) Navigator.of(context).pop();
              });
            }
            return Category(id: '', name: '', iconCodePoint: 0, colorValue: 0, budgetAmount: 0);
          },
        );

        if (category.id.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final gaugeDataAsync = ref.watch(categoryGaugeDataProvider(
          category: category,
          month: _displayMonth,
        ));
        final historicalDataAsync =
            ref.watch(historicalCategorySpendingProvider(
          categoryId: category.id,
        ));

        final palette = generateSpendingPalette(category.color);

        return SingleChildScrollView(
          key: ValueKey('detail_scroll_${category.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: CategoryGauge(
                          gaugeDataAsync: gaugeDataAsync,
                          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                          legendColors: palette.legendList,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          DateFormat.yMMMM().format(_displayMonth),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                historicalDataAsync.when(
                  data: (data) => HistoricalCategoryChart(
                    data: data,
                    selectedMonth: _displayMonth,
                    colorPalette: palette.historicalChartList,
                    onMonthSelected: (newMonth) {
                      setState(() {
                        _displayMonth = newMonth;
                      });
                    },
                  ),
                  loading: () => _buildChartPlaceholder(context),
                  error: (err, stack) => Center(
                    child: Text('Error loading chart: ${err.toString()}'),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ManageCategoryScreen(category: category),
                        ),
                      );
                    },
                    child: Text('Manage ${category.name} Budget'),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: UpcomingTransactionCard(categoryId: category.id),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Category'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, ref, category),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

Future<void> _showDeleteConfirmationDialog(
    BuildContext context, WidgetRef ref, Category category) async {
  final didConfirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Category?'),
      content: Text(
          'Are you sure you want to delete "${category.name}"? All associated transactions and budget data will be permanently lost.'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if (didConfirm == true && context.mounted) {
    await ref
        .read(transactionRepositoryProvider)
        .deleteCategory(category.id);
    ref.invalidate(categoryListProvider);
    Navigator.of(context).pop();
  }
}