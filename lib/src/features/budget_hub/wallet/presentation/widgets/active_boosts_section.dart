import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/controllers/boost_controller.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/screens/add_boost_screen.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/screens/edit_boost_screen.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

class ActiveBoostsSection extends ConsumerWidget {
  final Category category;

  const ActiveBoostsSection({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final boostState = ref.watch(boostStateProvider(category));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Title is always visible
        Text(
          "Active Boosts", 
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 8),

        // 2. List or Loading or Nothing
        boostState.when(
          loading: () => const SizedBox(
            height: 60, 
            child: Center(child: LinearProgressIndicator())
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (state) {
            final boostsMap = state.initialBoosts;
            
            // If empty, we just show nothing here and fall through to the button
            if (boostsMap.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: boostsMap.entries.map((entry) {
                final fromCategoryId = entry.key;
                final amount = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Dismissible(
                    key: Key('boost_$fromCategoryId'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: theme.colorScheme.onError),
                    ),
                    confirmDismiss: (direction) async {
                       return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                             title: const Text("Delete Boost?"),
                             content: const Text("Are you sure you want to remove this boost? Funds will return to the source category."),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                               TextButton(
                                 style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                 onPressed: () => Navigator.pop(context, true), 
                                 child: const Text("Delete")
                               ),
                             ],
                          )
                       );
                    },
                    onDismissed: (_) {
                      final controller = ref.read(boostStateProvider(category).notifier);
                      controller.updateAmount(fromCategoryId, 0.0);
                      controller.confirmBoosts();
                    },
                    child: _ExistingBoostCard(
                      fromCategoryId: fromCategoryId,
                      amount: amount,
                      targetCategory: category,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditBoostScreen(
                          targetCategory: category,
                          boost: WalletAdjustment(
                            id: 'temp_edit', 
                            fromCategoryId: fromCategoryId,
                            toCategoryId: category.id,
                            amount: amount,
                            date: DateTime.now(),
                          ),
                        )));
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        
        const SizedBox(height: 4),

        // 3. Add Button always at the bottom
        _AddBoostButton(category: category),
      ],
    );
  }
}

class _AddBoostButton extends StatelessWidget {
  final Category category;
  const _AddBoostButton({required this.category});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddBoostScreen(
          targetCategory: category
        )));
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text("Add Boost"),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _ExistingBoostCard extends ConsumerWidget {
  final String fromCategoryId;
  final double amount;
  final Category targetCategory;
  final VoidCallback onTap;

  const _ExistingBoostCard({
     required this.fromCategoryId,
     required this.amount,
     required this.targetCategory,
     required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    
    // Find source category or fallback
    final source = categories.firstWhere(
      (c) => c.id == fromCategoryId, 
      orElse: () => Category(
        id: 'unknown', 
        name: 'Unknown', 
        iconCodePoint: Icons.help_outline.codePoint, 
        colorValue: Colors.grey.value, 
        budgetAmount: 0
      )
    );
    
    final sourceColor = Color(source.colorValue);
    final contentColor = source.contentColor; 
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: sourceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        leading: Icon(IconData(source.iconCodePoint, fontFamily: 'MaterialIcons'), color: contentColor, size: 24),
        title: Text("From ${source.name}", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: contentColor)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("+\$${amount.toStringAsFixed(0)}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: contentColor)),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 16, color: contentColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}