// lib/src/features/wallet/presentation/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/common_widgets/swipable_page_view.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/average_spending_speedometers.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/daily_spending_gauges.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/wallet_bar_chart.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/wallet_category_card.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletCategoryDataAsync = ref.watch(walletCategoryDataProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // --- MODIFICATION: The entire screen's content is now conditional ---
    return walletCategoryDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        // If there is no data, show only the button
        if (data.isEmpty) {
          return Center(
            child: PulsingButton(
              label: 'Add Category',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
                );
              },
            ),
          );
        }

        // If data exists, build the full screen with charts and cards
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SwipablePageView(
              height: screenWidth,
              initialPage: 1,
              pages: const [
                DailySpendingGauges(),
                WalletBarChart(),
                AverageSpendingSpeedometers(),
              ],
            ),
            // We already know data is not empty here, so we just build the list
            Column(
              children: data.map((d) => WalletCategoryCard(data: d)).toList(),
            ),
          ],
        );
      },
    );
  }
}