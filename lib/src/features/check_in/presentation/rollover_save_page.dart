import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';
import 'package:budgit/src/features/check_in/presentation/rollover_card.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';

class RolloverSavePage extends ConsumerWidget {
  const RolloverSavePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final categories = ref.watch(categoryListProvider); // To get category objects from IDs

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CustomToggle(
            options: const ['Save', 'Rollover'],
            selectedValue: checkInState.decision == RolloverDecision.save ? 'Save' : 'Rollover',
            onChanged: (value) {
              final newDecision = value == 'Save' ? RolloverDecision.save : RolloverDecision.rollover;
              ref.read(checkInControllerProvider.notifier).makeDecision(newDecision);
            },
          ),
          const SizedBox(height: 16),
          if (categories.hasValue)
            ...checkInState.unspentFundsByCategory.entries.map((entry) {
              final category = categories.value!.firstWhere((c) => c.id == entry.key);
              return RolloverCard(category: category, unspentAmount: entry.value);
            }),
        ],
      ),
    );
  }
}