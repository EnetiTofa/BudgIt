import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/swipable_page_view.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/average_spending_speedometers.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/daily_spending_gauges.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/wallet_bar_chart.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/wallet_category_card.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_category_data_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletCategoryDataAsync = ref.watch(walletCategoryDataProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SwipablePageView(
          // --- CHANGE ---
          // Increased height for a larger view
          height: screenWidth,
          // --- END OF CHANGE ---
          initialPage: 1,
          pages: const [
            DailySpendingGauges(),
            WalletBarChart(),
            AverageSpendingSpeedometers(),
          ],
        ),
        walletCategoryDataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (data) => Column(
            children: data.map((d) => WalletCategoryCard(data: d)).toList(),
          ),
        ),
      ],
    );
  }
}