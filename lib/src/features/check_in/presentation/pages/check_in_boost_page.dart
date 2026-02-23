// lib/src/features/check_in/presentation/check_in_boost_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/filtered_category_selector.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/boost_composition_bar.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/amount_slider_field.dart';

class CheckInBoostPage extends ConsumerWidget {
  const CheckInBoostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text("Error loading categories")),
      data: (categories) {
        final walletedCategories = categories.where((c) => (c.walletAmount ?? 0) > 0).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Adjust Balances', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Shift funds between categories before calculating your final savings.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: walletedCategories.isEmpty
                  ? Center(child: Text("No wallet categories found.", style: theme.textTheme.bodyLarge))
                  : ListView.builder(
                      itemCount: walletedCategories.length,
                      itemBuilder: (context, index) {
                        final targetCat = walletedCategories[index];
                        final unspent = state.unspentFundsByCategory[targetCat.id] ?? 0.0;
                        final overspent = state.overspentFundsByCategory[targetCat.id] ?? 0.0;
                        
                        // FIX: Filter out system rollovers so only manual boosts are editable
                        final activeBoosts = state.checkInWeekBoosts.where((b) => 
                            b.toCategoryId == targetCat.id && 
                            b.fromCategoryId != 'rollover' // <-- The crucial filter!
                        ).toList();
                        
                        return _CategoryBoostCard(
                          targetCategory: targetCat,
                          unspentAmount: unspent,
                          overspentAmount: overspent,
                          activeBoosts: activeBoosts,
                          unspentMap: state.unspentFundsByCategory,
                          allCategories: categories,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryBoostCard extends ConsumerWidget {
  final Category targetCategory;
  final double unspentAmount;
  final double overspentAmount;
  final List<WalletAdjustment> activeBoosts;
  final Map<String, double> unspentMap;
  final List<Category> allCategories;

  const _CategoryBoostCard({
    required this.targetCategory,
    required this.unspentAmount,
    required this.overspentAmount,
    required this.activeBoosts,
    required this.unspentMap,
    required this.allCategories,
  });

  void _showBoostDialog(BuildContext context, WidgetRef ref, [WalletAdjustment? existingBoost]) {
    final validSources = allCategories.where((c) {
      if (c.id == targetCategory.id) return false;
      if (existingBoost != null && c.id == existingBoost.fromCategoryId) return true;
      return unspentMap.containsKey(c.id) && unspentMap[c.id]! > 0;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CheckInBoostBottomSheet(
          targetCategory: targetCategory,
          validSources: validSources,
          unspentMap: unspentMap,
          existingBoost: existingBoost,
          activeBoosts: activeBoosts,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final bool isOverspent = overspentAmount > 0;
    final bool isBalanced = overspentAmount == 0 && unspentAmount == 0;
    
    final Color cardColor = isOverspent 
        ? theme.colorScheme.errorContainer.withOpacity(0.3)
        : theme.colorScheme.surfaceContainerLow;
        
    String subtitleText;
    Color subtitleColor;
    
    if (isOverspent) {
      subtitleText = 'Overspent by \$${overspentAmount.toStringAsFixed(2)}';
      subtitleColor = theme.colorScheme.error;
    } else if (isBalanced) {
      subtitleText = 'Perfectly balanced (\$0)';
      subtitleColor = theme.colorScheme.secondary;
    } else {
      subtitleText = 'Left over: \$${unspentAmount.toStringAsFixed(2)}';
      subtitleColor = Colors.green; 
    }
    
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Color(targetCategory.colorValue),
              child: Icon(IconData(targetCategory.iconCodePoint, fontFamily: 'MaterialIcons'), color: targetCategory.contentColor),
            ),
            title: Text(targetCategory.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitleText, style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600)),
            trailing: OutlinedButton(
              onPressed: () => _showBoostDialog(context, ref),
              style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.primary),
              child: const Text("Boost"),
            ),
          ),
        ),
        // Active Boosts List below the main card
        if (activeBoosts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 16, bottom: 12),
            child: Column(
              children: activeBoosts.map((boost) {
                return _CheckInExistingBoostCard(
                  boost: boost,
                  allCategories: allCategories,
                  onTap: () => _showBoostDialog(context, ref, boost),
                );
              }).toList(),
            ),
          )
      ],
    );
  }
}

class _CheckInBoostBottomSheet extends ConsumerStatefulWidget {
  final Category targetCategory;
  final List<Category> validSources;
  final Map<String, double> unspentMap;
  final WalletAdjustment? existingBoost;
  final List<WalletAdjustment> activeBoosts;

  const _CheckInBoostBottomSheet({
    required this.targetCategory,
    required this.validSources,
    required this.unspentMap,
    this.existingBoost,
    required this.activeBoosts,
  });

  @override
  ConsumerState<_CheckInBoostBottomSheet> createState() => _CheckInBoostBottomSheetState();
}

class _CheckInBoostBottomSheetState extends ConsumerState<_CheckInBoostBottomSheet> {
  Category? _selectedSource;
  double _amountToTransfer = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.existingBoost != null) {
      // FIX: Safe lookup to prevent StateError if a source category was deleted or hidden
      final matchingSources = widget.validSources.where((c) => c.id == widget.existingBoost!.fromCategoryId);
      if (matchingSources.isNotEmpty) {
        _selectedSource = matchingSources.first;
      } else if (widget.validSources.isNotEmpty) {
        _selectedSource = widget.validSources.first; // Fallback to safe option
      }
      _amountToTransfer = widget.existingBoost!.amount;
    } else if (widget.validSources.isNotEmpty) {
      _selectedSource = widget.validSources.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.validSources.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.money_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text("No Funds Available", style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text("You don't have any unspent funds in other categories.", textAlign: TextAlign.center),
          ],
        ),
      );
    }

    double maxAvailable = widget.unspentMap[_selectedSource?.id] ?? 0.0;
    if (widget.existingBoost != null && _selectedSource?.id == widget.existingBoost!.fromCategoryId) {
      maxAvailable += widget.existingBoost!.amount;
    }
    final sliderMax = maxAvailable > 0 ? maxAvailable : 0.0;
    final displayAmount = _amountToTransfer.clamp(0.0, sliderMax);
    final sourceColor = _selectedSource != null ? Color(_selectedSource!.colorValue) : null;

    final baseBudget = widget.targetCategory.walletAmount ?? widget.targetCategory.budgetAmount;
    double otherBoostsTotal = widget.activeBoosts.fold(0.0, (sum, b) => sum + b.amount);
    if (widget.existingBoost != null) {
      otherBoostsTotal -= widget.existingBoost!.amount;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingBoost == null ? "Boost ${widget.targetCategory.name}" : "Edit Boost", 
                    style: theme.textTheme.titleLarge
                  ),
                  if (widget.existingBoost != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      onPressed: () async {
                        await ref.read(checkInControllerProvider.notifier).applyCheckInBoost(
                          existingBoostId: widget.existingBoost!.id,
                          fromCategoryId: widget.existingBoost!.fromCategoryId,
                          toCategoryId: widget.targetCategory.id,
                          amount: 0.0, 
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                    )
                ],
              ),
              const SizedBox(height: 16),
              BoostCompositionBar(
                targetCategory: widget.targetCategory,
                baseBudget: baseBudget,
                spent: 0.0, 
                otherBoostsTotal: otherBoostsTotal,
                currentBoostAmount: displayAmount,
                currentBoostColor: sourceColor,
              ),
              const SizedBox(height: 24),
              FilteredCategorySelector(
                labelText: "Take funds from",
                categories: widget.validSources,
                selectedCategory: _selectedSource,
                onCategorySelected: (cat) {
                  setState(() {
                    _selectedSource = cat;
                    _amountToTransfer = 0.0; 
                  });
                },
              ),
              const SizedBox(height: 24),
              AmountSliderField(
                value: displayAmount,
                maxAvailable: sliderMax,
                activeColor: sourceColor,
                onChanged: (val) => setState(() => _amountToTransfer = val),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: _selectedSource != null && displayAmount > 0 ? () async {
                  await ref.read(checkInControllerProvider.notifier).applyCheckInBoost(
                    existingBoostId: widget.existingBoost?.id,
                    fromCategoryId: _selectedSource!.id,
                    toCategoryId: widget.targetCategory.id,
                    amount: _amountToTransfer,
                  );
                  if (context.mounted) Navigator.pop(context);
                } : null,
                child: Text(widget.existingBoost == null ? "Apply Boost" : "Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInExistingBoostCard extends StatelessWidget {
  final WalletAdjustment boost;
  final List<Category> allCategories;
  final VoidCallback onTap;

  const _CheckInExistingBoostCard({
     required this.boost,
     required this.allCategories,
     required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Graceful fallback for the visual card as well
    final source = allCategories.firstWhere(
      (c) => c.id == boost.fromCategoryId, 
      orElse: () => Category(id: 'unknown', name: 'Unknown', iconCodePoint: Icons.help_outline.codePoint, colorValue: Colors.grey.value, budgetAmount: 0)
    );
    
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Color(source.colorValue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(source.colorValue).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(IconData(source.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(source.colorValue), size: 16),
            const SizedBox(width: 8),
            Text("From ${source.name}", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text("+\$${boost.amount.toStringAsFixed(0)}", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Color(source.colorValue))),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 14, color: theme.colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}