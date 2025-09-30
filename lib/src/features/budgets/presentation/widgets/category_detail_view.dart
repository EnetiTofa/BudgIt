// lib/src/features/budgets/presentation/views/category_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/category_gauge.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/historical_category_chart.dart';
import 'package:budgit/src/features/budgets/presentation/providers/category_gauge_data_provider.dart';
import 'package:budgit/src/features/budgets/presentation/providers/historical_category_spending_provider.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/categories/presentation/screens/edit_basic_category_screen.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/upcoming_transaction_card.dart';

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
    // Watch the master list to get the most up-to-date category data
    final categoryListAsync = ref.watch(categoryListProvider);

    return categoryListAsync.when(
      data: (categories) {
        // Find our specific category from the fresh list
        final category = categories.firstWhere(
          (cat) => cat.id == widget.categoryId,
          // If the category was deleted elsewhere, it won't be found.
          orElse: () {
            // Gracefully pop the screen if the category no longer exists.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
            // Return a dummy category to prevent build errors before popping.
            return Category(
                id: '',
                name: '',
                iconCodePoint: 0,
                colorValue: 0,
                budgetAmount: 0);
          },
        );

        // If the dummy category was returned, show a loading indicator
        // for a frame while the pop completes.
        if (category.id.isEmpty) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // Watch the providers that depend on the fresh category data
        final gaugeDataAsync = ref.watch(categoryGaugeDataProvider(
          category: category,
          month: _displayMonth,
        ));
        final historicalDataAsync =
            ref.watch(historicalCategorySpendingProvider(
          categoryId: category.id,
        ));

        // Derive colors from the fresh category object
        final lightestColor = category.color;
        final hslColor = HSLColor.fromColor(lightestColor);
        final mediumColor = hslColor
            .withLightness((hslColor.lightness * 0.8))
            .withSaturation((hslColor.saturation * 0.82))
            .toColor();
        final darkestColor = hslColor
            .withLightness((hslColor.lightness * 0.65))
            .withSaturation((hslColor.saturation * 0.78))
            .toColor();
        
        // Define the color list for the legend in the correct order.
        final legendColors = [lightestColor, mediumColor, darkestColor];
        
        // Define the color palette for the historical chart.
        final colorPalette = [darkestColor, mediumColor, lightestColor];

        return Scaffold(
          body: SingleChildScrollView(
            key: ValueKey('detail_${category.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                null;
                          },
                        ),
                        Row(
                          children: [
                            Icon(category.icon,
                                color: category.color, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              category.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditBasicCategoryScreen(
                                  category: category,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: CategoryGauge(
                            gaugeDataAsync: gaugeDataAsync,
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceDim,
                            // Pass the static list of colors to the gauge.
                            legendColors: legendColors,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Text(
                            DateFormat.yMMMM().format(_displayMonth),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                      colorPalette: colorPalette,
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
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () {},
                      child: Text('Manage ${category.name} Budget'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: UpcomingTransactionCard(categoryId: category.id),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}