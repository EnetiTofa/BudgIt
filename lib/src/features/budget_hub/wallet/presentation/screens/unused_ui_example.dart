import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/controllers/boost_controller.dart';

class BoostEditorScreen extends ConsumerStatefulWidget {
  final Category activeCategory; 

  const BoostEditorScreen({super.key, required this.activeCategory});

  @override
  ConsumerState<BoostEditorScreen> createState() => _BoostEditorScreenState();
}

class _BoostEditorScreenState extends ConsumerState<BoostEditorScreen> {
  // FIX: Removed 'late'. Initialize to null.
  Category? _sourceCategory; 
  double _amount = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListProvider);
    final boostState = ref.watch(boostStateProvider(widget.activeCategory));
    final controller = ref.read(boostStateProvider(widget.activeCategory).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Boosts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              controller.confirmBoosts();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (allCategories) {
          // Filter out the active category so we don't boost from self
          final sourceOptions = allCategories
              .where((c) => c.id != widget.activeCategory.id)
              .toList();
          
          if (sourceOptions.isEmpty) {
            return const Center(child: Text("No other categories available to boost from."));
          }

          // FIX: Safely initialize selection if null
          if (_sourceCategory == null) {
            _sourceCategory = sourceOptions.first;
            
            // Sync amount with existing boost if any
            final currentMap = boostState.valueOrNull?.currentBoosts ?? {};
            _amount = currentMap[_sourceCategory!.id] ?? 0.0;
          }

          // Safety check: Ensure selected category is still in options (e.g. if list changed)
          if (!sourceOptions.any((c) => c.id == _sourceCategory!.id)) {
             _sourceCategory = sourceOptions.first;
             _amount = 0.0;
          }

          final double maxAvailable = _sourceCategory!.walletAmount ?? _sourceCategory!.budgetAmount;
          // Prevent slider crash if max is 0
          final double sliderMax = maxAvailable > 0 ? maxAvailable : 100.0;
          // Ensure amount doesn't exceed max (e.g. if budget changed)
          if (_amount > sliderMax) _amount = sliderMax;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Take funds from", style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                
                // Category Selector List
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: sourceOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final cat = sourceOptions[index];
                      final isSelected = _sourceCategory!.id == cat.id;
                      
                      final currentMap = boostState.valueOrNull?.currentBoosts ?? {};
                      final isContributing = currentMap.containsKey(cat.id) && currentMap[cat.id]! > 0;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _sourceCategory = cat;
                            // Fetch amount for new selection
                            _amount = currentMap[cat.id] ?? 0.0;
                          });
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), 
                                color: Color(cat.colorValue)
                              ),
                              const SizedBox(height: 4),
                              if (isContributing)
                                Text(
                                  "+${currentMap[cat.id]!.round()}", 
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)
                                ),
                              Text(
                                cat.name, 
                                style: const TextStyle(fontSize: 10), 
                                overflow: TextOverflow.ellipsis
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Amount Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Boost Amount", style: theme.textTheme.titleMedium),
                    Text(
                      "\$${_amount.toStringAsFixed(0)}", 
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Color(_sourceCategory!.colorValue), 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
                
                Slider(
                  value: _amount,
                  min: 0,
                  max: sliderMax,
                  divisions: 100,
                  activeColor: Color(_sourceCategory!.colorValue),
                  onChanged: (val) {
                    setState(() => _amount = val);
                    // Update controller live for feedback
                    controller.updateAmount(_sourceCategory!.id, val);
                  },
                ),
                Text(
                  "Available: \$${maxAvailable.toStringAsFixed(0)}", 
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}