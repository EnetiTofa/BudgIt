import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

// Imports for the new separated widgets
import 'package:budgit/src/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:budgit/src/features/dashboard/presentation/widgets/dashboard_wallet_gauge.dart';

class DashboardWalletWidget extends ConsumerStatefulWidget {
  const DashboardWalletWidget({super.key});

  @override
  ConsumerState<DashboardWalletWidget> createState() => _DashboardWalletWidgetState();
}

class _DashboardWalletWidgetState extends ConsumerState<DashboardWalletWidget> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockNotifierProvider).now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final asyncData = ref.watch(walletCategoryDataProvider(selectedDate: todayNormalized));

    return asyncData.when(
      data: (dataList) {
        if (dataList.isEmpty) return const SizedBox.shrink();

        // 1. Pagination Logic: Split data into chunks of 3
        final int itemsPerPage = 3;
        final int pageCount = (dataList.length / itemsPerPage).ceil();
        
        final List<List<WalletCategoryData>> pages = [];
        for (int i = 0; i < pageCount; i++) {
          final int start = i * itemsPerPage;
          final int end = (start + itemsPerPage < dataList.length) 
              ? start + itemsPerPage 
              : dataList.length;
          pages.add(dataList.sublist(start, end));
        }

        return DashboardCard(
          title: 'Daily Wallet',
          subtitle: 'Today',
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: PageView.builder(
                  itemCount: pageCount,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final pageItems = pages[index];
                    
                    // 2. Render items centered and spaced evenly
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: pageItems.map((data) {
                        return WalletCategoryItem(data: data);
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // 3. Page Indicators
              if (pageCount > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pageCount, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 16 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class WalletCategoryItem extends StatelessWidget {
  final WalletCategoryData data;

  const WalletCategoryItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double spent = data.spendingToday;
    final double recommended = data.recommendedDailySpending;
    final bool isOver = spent > recommended;
    
    final double progress = recommended > 0 
        ? (spent / recommended).clamp(0.0, 1.0) 
        : (spent > 0 ? 1.0 : 0.0);

    final categoryColor = Color(data.category.colorValue);

    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Use the extracted Gauge Widget
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: BudgetCircularGauge(
              progress: progress,
              color: categoryColor,
              icon: data.category.icon,
            ),
          ),

          // Title
          Text(
            data.category.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 2),

          // Spending Details
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: '\$${spent.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isOver ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
                TextSpan(
                  text: ' / \$${recommended.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}