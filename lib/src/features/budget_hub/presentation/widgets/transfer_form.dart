import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/filtered_category_selector.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/transfer_composition_bar.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/amount_slider_field.dart';

// FIX 1: Point to the updated controller location
import 'package:budgit/src/features/budget_hub/presentation/controllers/transfer_controller.dart';

// FIX 2: Point to the new consolidated weekly providers
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';

class TransferForm extends ConsumerStatefulWidget {
  final Category targetCategory;
  final BudgetTransfer? initialTransfer;

  const TransferForm({
    super.key,
    required this.targetCategory,
    this.initialTransfer,
  });

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  Category? _sourceCategory;
  double _amount = 0.0;
  double _otherTransfersTotal = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransfer != null) {
      _amount = widget.initialTransfer!.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // FIX 3: Use weeklyDateProvider
    final date = ref.watch(weeklyDateProvider);

    // FIX 4: Use weeklyCategoryDataProvider
    final walletDataAsync = ref.watch(
      weeklyCategoryDataProvider(selectedDate: date),
    );

    // FIX 5: Use transferControllerProvider (Note: lowerCamelCase)
    final transferState = ref.watch(
      transferControllerProvider(widget.targetCategory),
    );

    final currentMap = transferState.valueOrNull?.currentTransfers ?? {};
    double totalActive = 0.0;
    currentMap.forEach((key, value) => totalActive += value);

    _otherTransfersTotal = totalActive;
    if (widget.initialTransfer != null) {
      final currentContribution =
          currentMap[widget.initialTransfer!.fromCategoryId] ?? 0.0;
      _otherTransfersTotal -= currentContribution;
    }
    if (_otherTransfersTotal < 0) _otherTransfersTotal = 0;

    return walletDataAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(child: Text("Error: $err")),
      ),
      data: (walletDataList) {
        final targetCategoryData = walletDataList.firstWhere(
          (d) => d.category.id == widget.targetCategory.id,
          orElse: () => walletDataList.first,
        );
        final baseBudget = targetCategoryData.baseWeeklyBudget;

        final validSources = <Category>[];

        for (final data in walletDataList) {
          if (data.category.id == widget.targetCategory.id) continue;
          double available = data.amountRemainingThisWeek;

          if (widget.initialTransfer != null &&
              data.category.id == widget.initialTransfer!.fromCategoryId) {
            available += widget.initialTransfer!.amount;
          }
          if (available > 0) validSources.add(data.category);
        }

        if (validSources.isEmpty) {
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
                  "No other categories have available funds to transfer from.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (_sourceCategory == null) {
          if (widget.initialTransfer != null) {
            final originalSourceData = walletDataList.firstWhere(
              (d) => d.category.id == widget.initialTransfer!.fromCategoryId,
              orElse: () => walletDataList.first,
            );
            _sourceCategory = originalSourceData.category;
          } else {
            _sourceCategory = validSources.first;
          }
        }

        double maxAvailable = 0.0;
        if (_sourceCategory != null) {
          final sourceData = walletDataList.firstWhere(
            (d) => d.category.id == _sourceCategory!.id,
            orElse: () => walletDataList.first,
          );
          maxAvailable = sourceData.amountRemainingThisWeek;

          if (widget.initialTransfer != null &&
              _sourceCategory!.id == widget.initialTransfer!.fromCategoryId) {
            maxAvailable += widget.initialTransfer!.amount;
          }
        }

        final double sliderMax = maxAvailable > 0 ? maxAvailable : 0.0;
        final displayAmount = _amount.clamp(0.0, sliderMax);
        final sourceColor = _sourceCategory != null
            ? Color(_sourceCategory!.colorValue)
            : null;

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
                  Text(
                    widget.initialTransfer == null
                        ? "Transfer ${widget.targetCategory.name}"
                        : "Edit Transfer",
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TransferCompositionBar(
                    targetCategory: widget.targetCategory,
                    baseBudget: baseBudget,
                    spent: 0.0,
                    otherTransfersTotal: _otherTransfersTotal,
                    currentTransferAmount: displayAmount,
                    currentTransferColor: sourceColor,
                  ),
                  const SizedBox(height: 24),
                  FilteredCategorySelector(
                    labelText: "Take funds from",
                    categories: validSources,
                    selectedCategory: _sourceCategory,
                    onCategorySelected: (cat) {
                      if (cat.id == widget.targetCategory.id) return;
                      setState(() {
                        _sourceCategory = cat;
                        _amount = 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  AmountSliderField(
                    value: displayAmount,
                    maxAvailable: sliderMax,
                    activeColor: sourceColor,
                    onChanged: (val) => setState(() => _amount = val),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _sourceCategory != null && displayAmount > 0
                        ? _saveTransfer
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(
                      widget.initialTransfer == null
                          ? "Add Transfer"
                          : "Save Changes",
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveTransfer() {
    // FIX 6: Use transferControllerProvider.notifier
    final controller = ref.read(
      transferControllerProvider(widget.targetCategory).notifier,
    );

    if (widget.initialTransfer != null &&
        _sourceCategory!.id != widget.initialTransfer!.fromCategoryId) {
      controller.updateAmount(widget.initialTransfer!.fromCategoryId, 0.0);
    }

    controller.updateAmount(_sourceCategory!.id, _amount);
    controller.confirmTransfers();

    Navigator.pop(context);
  }
}
