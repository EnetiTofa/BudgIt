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
    
    // 1. Get the Current Wallet Date
    final date = ref.watch(walletDateProvider);
    
    // 2. Fetch Full Wallet Data (This contains the EFFECTIVE budgets)
    // FIX: Use 'walletCategoryDataProvider' (The Provider) instead of 'walletCategoryData' (The Function)
    final walletDataAsync = ref.watch(walletCategoryDataProvider(selectedDate: date));
    
    final boostState = ref.watch(boostStateProvider(widget.targetCategory));
    
    // Calculate Other Boosts for Visualization
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (walletDataList) {
        
        // -----------------------------------------------------------
        // FILTER LOGIC: Find valid sources based on REMAINING BALANCE
        // -----------------------------------------------------------
        final validSources = <Category>[];
        
        for (final data in walletDataList) {
          // Skip self
          if (data.category.id == widget.targetCategory.id) continue;
          
          // Use amountRemainingThisWeek instead of effectiveWeeklyBudget
          // This ensures we check actual available funds (Wallet - Spent - BoostsUsed)
          double available = data.amountRemainingThisWeek;
          
          // If editing a boost FROM this category, add that amount back to 'available'
          // so we can re-allocate the funds we are currently using.
          if (widget.initialBoost != null && data.category.id == widget.initialBoost!.fromCategoryId) {
            available += widget.initialBoost!.amount;
          }
          
          if (available > 0) {
            validSources.add(data.category);
          }
        }

        if (validSources.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "No other categories have available funds to boost from.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
              ),
            ),
          );
        }

        // Initialize Source
        if (_sourceCategory == null) {
          if (widget.initialBoost != null) {
            // Find the original source object from the list
            final originalSourceData = walletDataList.firstWhere(
              (d) => d.category.id == widget.initialBoost!.fromCategoryId, 
              orElse: () => walletDataList.first // Fallback
            );
            _sourceCategory = originalSourceData.category;
          } else {
             _sourceCategory = validSources.first;
          }
        }

        // -----------------------------------------------------------
        // CALCULATE MAX AVAILABLE FOR SLIDER
        // -----------------------------------------------------------
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
        
        // Ensure display doesn't exceed max (but we don't force setState during build)
        final displayAmount = _amount.clamp(0.0, sliderMax);

        final sourceColor = _sourceCategory != null 
            ? Color(_sourceCategory!.colorValue) 
            : null;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. VISUALIZATION
                    BoostCompositionBar(
                      targetCategory: widget.targetCategory,
                      baseBudget: _baseBudget,
                      spent: 0.0, 
                      otherBoostsTotal: _otherBoostsTotal,
                      currentBoostAmount: displayAmount,
                      currentBoostColor: sourceColor,
                    ),
                    const SizedBox(height: 18),
                    // 3. SOURCE CATEGORY
                    FilteredCategorySelector(
                      labelText: "Take funds from",
                      categories: validSources,
                      selectedCategory: _sourceCategory,
                      onCategorySelected: (cat) {
                          if (cat.id == widget.targetCategory.id) return;
                          
                          setState(() {
                            _sourceCategory = cat;
                            // Reset amount when swapping sources
                            _amount = 0.0; 
                          });
                      },
                    ),
                    const SizedBox(height: 18),
                    Column(
                      children: [
                        AmountSliderField(
                          value: displayAmount,
                          maxAvailable: sliderMax,
                          activeColor: sourceColor,
                          onChanged: (val) => setState(() => _amount = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // SAVE BUTTON
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _sourceCategory != null && displayAmount > 0 ? _saveBoost : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: Text(widget.initialBoost == null ? "Add Boost" : "Save Changes"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveBoost() {
    final controller = ref.read(boostStateProvider(widget.targetCategory).notifier);
    
    // Handle Source Swap on Edit
    if (widget.initialBoost != null && _sourceCategory!.id != widget.initialBoost!.fromCategoryId) {
      controller.updateAmount(widget.initialBoost!.fromCategoryId, 0.0);
    }
    
    controller.updateAmount(_sourceCategory!.id, _amount);
    controller.confirmBoosts(); 
    
    Navigator.pop(context);
  }
}