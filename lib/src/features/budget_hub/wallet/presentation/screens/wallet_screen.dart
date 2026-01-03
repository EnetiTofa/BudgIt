// lib/src/features/wallet/presentation/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/wallet_bar_chart.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/wallet_category_card/wallet_category_card.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(walletDateProvider);
    final walletCategoryDataAsync = ref.watch(walletCategoryDataProvider(selectedDate: selectedDate));
    
    return walletCategoryDataAsync.when(
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
          // --- MODIFICATION: Reduced top padding to 0 ---
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          children: [
            const WalletBarChart(),
            const SizedBox(height: 4),
            Column(
              children: data.map((d) => Padding(
                // --- MODIFICATION: Added bottom padding to increase gap between cards ---
                padding: const EdgeInsets.only(bottom: 4.0),
                child: WalletCategoryCard(data: d),
              )).toList(),
            ),
          ],
        );
      },
    );
  }
}