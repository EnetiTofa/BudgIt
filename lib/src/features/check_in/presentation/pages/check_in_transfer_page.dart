import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/filtered_category_selector.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/transfer_composition_bar.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/amount_slider_field.dart';

class CheckInTransferPage extends ConsumerWidget {
  const CheckInTransferPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkInControllerProvider);

    // 1. Wait for the controller to do the heavy lifting
    if (state.status == CheckInStatus.initial ||
        state.status == CheckInStatus.loading) {
      // Changed to text so we know exactly what is loading
      return Center(child: Text("STUCK LOADING CONTROLLER: ${state.status}"));
    }

    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    if (!categoriesAsync.hasValue) {
      if (categoriesAsync.hasError) {
        return Center(
          child: Text("Error loading categories: ${categoriesAsync.error}"),
        );
      }
      // Changed to text so we know if categories are the problem
      return const Center(child: Text("STUCK LOADING CATEGORIES"));
    }
    final categories = categoriesAsync.value!;

    // 3. A category is "walleted" if it has a base budget > 0
    final walletedCategories = categories
        .where((c) => c.budgetAmount > 0)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Adjust Balances',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Shift funds between categories before calculating your final savings.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: walletedCategories.isEmpty
              ? Center(
                  child: Text(
                    "No active categories found.",
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: walletedCategories.length,
                  itemBuilder: (context, index) {
                    final targetCat = walletedCategories[index];

                    // Read the math straight out of the controller state! No async waiting!
                    final unspent =
                        state.unspentFundsByCategory[targetCat.id] ?? 0.0;
                    final overspent =
                        state.overspentFundsByCategory[targetCat.id] ?? 0.0;

                    final activeTransfers = state.checkInWeekTransfers
                        .where(
                          (b) =>
                              b.toCategoryId == targetCat.id &&
                              b.fromCategoryId != 'rollover',
                        )
                        .toList();

                    // Estimate base weekly budget for the visual progress bar scaling
                    final estimatedWeeklyBudget = targetCat.budgetAmount / 4.33;

                    return _CategoryTransferCard(
                      targetCategory: targetCat,
                      baseWeeklyBudget: estimatedWeeklyBudget,
                      unspentAmount: unspent,
                      overspentAmount: overspent,
                      activeTransfers: activeTransfers,
                      unspentMap: state.unspentFundsByCategory,
                      allCategories: categories,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryTransferCard extends ConsumerWidget {
  final Category targetCategory;
  final double baseWeeklyBudget;
  final double unspentAmount;
  final double overspentAmount;
  final List<BudgetTransfer> activeTransfers;
  final Map<String, double> unspentMap;
  final List<Category> allCategories;

  const _CategoryTransferCard({
    required this.targetCategory,
    required this.baseWeeklyBudget,
    required this.unspentAmount,
    required this.overspentAmount,
    required this.activeTransfers,
    required this.unspentMap,
    required this.allCategories,
  });

  void _showTransferDialog(
    BuildContext context,
    WidgetRef ref, [
    BudgetTransfer? existingTransfer,
  ]) {
    final validSources = allCategories.where((c) {
      if (c.id == targetCategory.id) return false;
      if (existingTransfer != null && c.id == existingTransfer.fromCategoryId) {
        return true;
      }
      return unspentMap.containsKey(c.id) && unspentMap[c.id]! > 0;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CheckInTransferBottomSheet(
          targetCategory: targetCategory,
          baseWeeklyBudget: baseWeeklyBudget,
          validSources: validSources,
          unspentMap: unspentMap,
          existingTransfer: existingTransfer,
          activeTransfers: activeTransfers,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Color(targetCategory.colorValue),
              child: Icon(
                IconData(
                  targetCategory.iconCodePoint,
                  fontFamily: 'MaterialIcons',
                ),
                color: targetCategory.contentColor,
              ),
            ),
            title: Text(
              targetCategory.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitleText,
              style: TextStyle(
                color: subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: OutlinedButton(
              onPressed: () => _showTransferDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
              child: const Text("Transfer"),
            ),
          ),
        ),
        if (activeTransfers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
              top: 8,
            ),
            child: Column(
              children: activeTransfers.map((transfer) {
                return _CheckInExistingTransferCard(
                  transfer: transfer,
                  allCategories: allCategories,
                  onTap: () => _showTransferDialog(context, ref, transfer),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _CheckInTransferBottomSheet extends ConsumerStatefulWidget {
  final Category targetCategory;
  final double baseWeeklyBudget;
  final List<Category> validSources;
  final Map<String, double> unspentMap;
  final BudgetTransfer? existingTransfer;
  final List<BudgetTransfer> activeTransfers;

  const _CheckInTransferBottomSheet({
    required this.targetCategory,
    required this.baseWeeklyBudget,
    required this.validSources,
    required this.unspentMap,
    this.existingTransfer,
    required this.activeTransfers,
  });

  @override
  ConsumerState<_CheckInTransferBottomSheet> createState() =>
      _CheckInTransferBottomSheetState();
}

class _CheckInTransferBottomSheetState
    extends ConsumerState<_CheckInTransferBottomSheet> {
  Category? _selectedSource;
  double _amountToTransfer = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransfer != null) {
      final matchingSources = widget.validSources.where(
        (c) => c.id == widget.existingTransfer!.fromCategoryId,
      );
      if (matchingSources.isNotEmpty) {
        _selectedSource = matchingSources.first;
      } else if (widget.validSources.isNotEmpty) {
        _selectedSource = widget.validSources.first;
      }
      _amountToTransfer = widget.existingTransfer!.amount;
    } else if (widget.validSources.isNotEmpty) {
      _selectedSource = widget.validSources.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.validSources.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.money_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text("No Funds Available", style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              "You don't have any unspent funds in other categories.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    double maxAvailable = widget.unspentMap[_selectedSource?.id] ?? 0.0;
    if (widget.existingTransfer != null &&
        _selectedSource?.id == widget.existingTransfer!.fromCategoryId) {
      maxAvailable += widget.existingTransfer!.amount;
    }
    final sliderMax = maxAvailable > 0 ? maxAvailable : 0.0;
    final displayAmount = _amountToTransfer.clamp(0.0, sliderMax);
    final sourceColor = _selectedSource != null
        ? Color(_selectedSource!.colorValue)
        : null;

    final baseBudget = widget.baseWeeklyBudget;

    double otherTransfersTotal = widget.activeTransfers.fold(
      0.0,
      (sum, b) => sum + b.amount,
    );
    if (widget.existingTransfer != null) {
      otherTransfersTotal -= widget.existingTransfer!.amount;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                    widget.existingTransfer == null
                        ? "Transfer to ${widget.targetCategory.name}"
                        : "Edit Transfer",
                    style: theme.textTheme.titleLarge,
                  ),
                  if (widget.existingTransfer != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      // ... existing close/delete math ...
                      onPressed: () async {
                        await ref
                            .read(checkInControllerProvider.notifier)
                            .applyCheckInTransfer(
                              existingTransferId: widget.existingTransfer!.id,
                              fromCategoryId:
                                  widget.existingTransfer!.fromCategoryId,
                              toCategoryId: widget.targetCategory.id,
                              amount: 0.0,
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TransferCompositionBar(
                targetCategory: widget.targetCategory,
                baseBudget: baseBudget,
                spent: 0.0,
                otherTransfersTotal: otherTransfersTotal,
                currentTransferAmount: displayAmount,
                currentTransferColor: sourceColor,
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
                onPressed: _selectedSource != null && displayAmount > 0
                    ? () async {
                        await ref
                            .read(checkInControllerProvider.notifier)
                            .applyCheckInTransfer(
                              existingTransferId: widget.existingTransfer?.id,
                              fromCategoryId: _selectedSource!.id,
                              toCategoryId: widget.targetCategory.id,
                              amount: _amountToTransfer,
                            );
                        if (context.mounted) Navigator.pop(context);
                      }
                    : null,
                child: Text(
                  widget.existingTransfer == null
                      ? "Apply Transfer"
                      : "Save Changes",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInExistingTransferCard extends StatelessWidget {
  final BudgetTransfer transfer;
  final List<Category> allCategories;
  final VoidCallback onTap;

  const _CheckInExistingTransferCard({
    required this.transfer,
    required this.allCategories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final source = allCategories.firstWhere(
      (c) => c.id == transfer.fromCategoryId,
      orElse: () => Category(
        id: 'unknown',
        name: 'Unknown',
        iconCodePoint: Icons.help_outline.codePoint,
        colorValue: Colors.grey.value,
        budgetAmount: 0,
      ),
    );

    final theme = Theme.of(context);
    final sourceColor = Color(source.colorValue);
    final contentColor = source.contentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: sourceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        leading: Icon(
          IconData(source.iconCodePoint, fontFamily: 'MaterialIcons'),
          color: contentColor,
          size: 24,
        ),
        title: Text(
          "From ${source.name}",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: contentColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "+\$${transfer.amount.toStringAsFixed(0)}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 16, color: contentColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}

// Hello
