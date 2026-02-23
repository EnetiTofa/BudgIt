// lib/src/features/budget_hub/wallet/presentation/widgets/boost_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/controllers/boost_controller.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/filtered_category_selector.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/boost_composition_bar.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/amount_slider_field.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';

class BoostForm extends ConsumerStatefulWidget {
  final Category targetCategory;
  final WalletAdjustment? initialBoost;

  const BoostForm({
    super.key,
    required this.targetCategory,
    this.initialBoost,
  });

  @override
  ConsumerState<BoostForm> createState() => _BoostFormState();
}

class _BoostFormState extends ConsumerState<BoostForm> {
  Category? _sourceCategory;
  double _amount = 0.0;
  
  late double _baseBudget;
  double _otherBoostsTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _baseBudget = widget.targetCategory.walletAmount ?? widget.targetCategory.budgetAmount;
    if (widget.initialBoost != null) {
      _amount = widget.initialBoost!.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = ref.watch(walletDateProvider);
    final walletDataAsync = ref.watch(walletCategoryDataProvider(selectedDate: date));
    final boostState = ref.watch(boostStateProvider(widget.targetCategory));
    
    final currentMap = boostState.valueOrNull?.currentBoosts ?? {};
    double totalActive = 0.0;
    currentMap.forEach((key, value) => totalActive += value);

    _otherBoostsTotal = totalActive;
    if (widget.initialBoost != null) {
       final currentContribution = currentMap[widget.initialBoost!.fromCategoryId] ?? 0.0;
       _otherBoostsTotal -= currentContribution;
    }
    if (_otherBoostsTotal < 0) _otherBoostsTotal = 0;

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
        final validSources = <Category>[];
        
        for (final data in walletDataList) {
          if (data.category.id == widget.targetCategory.id) continue;
          double available = data.amountRemainingThisWeek;
          
          if (widget.initialBoost != null && data.category.id == widget.initialBoost!.fromCategoryId) {
            available += widget.initialBoost!.amount;
          }
          if (available > 0) validSources.add(data.category);
        }

        if (validSources.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.money_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text("No Funds Available", style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text("No other categories have available funds to boost from.", textAlign: TextAlign.center),
              ],
            ),
          );
        }

        if (_sourceCategory == null) {
          if (widget.initialBoost != null) {
            final originalSourceData = walletDataList.firstWhere(
              (d) => d.category.id == widget.initialBoost!.fromCategoryId, 
              orElse: () => walletDataList.first 
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
            orElse: () => walletDataList.first
          );
          maxAvailable = sourceData.amountRemainingThisWeek;
          
          if (widget.initialBoost != null && _sourceCategory!.id == widget.initialBoost!.fromCategoryId) {
            maxAvailable += widget.initialBoost!.amount;
          }
        }
        
        final double sliderMax = maxAvailable > 0 ? maxAvailable : 0.0;
        final displayAmount = _amount.clamp(0.0, sliderMax);
        final sourceColor = _sourceCategory != null ? Color(_sourceCategory!.colorValue) : null;

        // CHANGED TO BOTTOM SHEET FRIENDLY LAYOUT
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
                    widget.initialBoost == null ? "Boost ${widget.targetCategory.name}" : "Edit Boost", 
                    style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: 16),
                  BoostCompositionBar(
                    targetCategory: widget.targetCategory,
                    baseBudget: _baseBudget,
                    spent: 0.0, 
                    otherBoostsTotal: _otherBoostsTotal,
                    currentBoostAmount: displayAmount,
                    currentBoostColor: sourceColor,
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
                    onPressed: _sourceCategory != null && displayAmount > 0 ? _saveBoost : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(widget.initialBoost == null ? "Add Boost" : "Save Changes"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveBoost() {
    final controller = ref.read(boostStateProvider(widget.targetCategory).notifier);
    
    if (widget.initialBoost != null && _sourceCategory!.id != widget.initialBoost!.fromCategoryId) {
      controller.updateAmount(widget.initialBoost!.fromCategoryId, 0.0);
    }
    
    controller.updateAmount(_sourceCategory!.id, _amount);
    controller.confirmBoosts(); 
    
    Navigator.pop(context);
  }
}