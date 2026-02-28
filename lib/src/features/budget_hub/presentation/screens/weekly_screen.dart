import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';

// Note: You might want to rename these widget files to 'weekly_bar_chart.dart' and 'weekly_category_card.dart' soon!
import 'package:budgit/src/features/budget_hub/presentation/widgets/wallet_bar_chart.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/wallet_category_card.dart';

import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';

// RENAMED CLASS: WalletScreen -> WeeklyScreen
class WeeklyScreen extends ConsumerWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(weeklyDateProvider);

    final weeklyCategoryDataAsync = ref.watch(
      weeklyCategoryDataProvider(selectedDate: selectedDate),
    );

    return weeklyCategoryDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
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

        return ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          children: [
            const WalletBarChart(), // We'll leave this named WalletBarChart until you rename its file
            const SizedBox(height: 12),
            Column(
              children: data
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      // Still calling the old card widget for now
                      child: WalletCategoryCard(data: d),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
