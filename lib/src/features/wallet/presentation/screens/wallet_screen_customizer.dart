import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/customizer_card.dart';
import 'package:budgit/src/features/settings/domain/screen_layout.dart';
import 'package:budgit/src/features/settings/presentation/layout_provider.dart';

class WalletScreenCustomizer extends ConsumerWidget { // Now a simple ConsumerWidget
  const WalletScreenCustomizer({super.key});

  // --- Static constants are defined here ---
  static const Map<String, Map<String, dynamic>> _widgetDetails = {
    'gauges': {'title': "Today's Spending", 'icon': Icons.pie_chart_outline},
    'speedometers': {'title': 'Average Spending', 'icon': Icons.speed_outlined},
    'barchart': {'title': 'Weekly Chart', 'icon': Icons.bar_chart_outlined},
  };
  static const _defaultOrder = ['gauges', 'speedometers', 'barchart'];
  static const _itemWidth = 140.0;
  static const _itemMargin = 16.0;

  // --- Logic methods are now simple static or instance methods ---
  void _moveItem(WidgetRef ref, ScreenLayout layout, int oldIndex, bool moveRight) {
    final newIndex = moveRight ? oldIndex + 1 : oldIndex - 1;
    final item = layout.widgetOrder.removeAt(oldIndex);
    layout.widgetOrder.insert(newIndex, item);
    
    // Call the notifier to save the change
    ref.read(screenLayoutNotifierProvider('wallet_screen', defaultOrder: _defaultOrder).notifier)
       .saveScreenLayout(layout);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define and watch the provider inside the build method
    print("--- B. Building WalletScreenCustomizer ---");
    final layoutProvider = screenLayoutNotifierProvider('wallet_screen', defaultOrder: _defaultOrder);
    final layoutAsync = ref.watch(layoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Wallet Screen'),
      ),
      body: layoutAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,s) => Center(child: Text('Error: $e')),
        data: (layout) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text('Reorder Pages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    children: [
                      SizedBox(width: layout.widgetOrder.length * (_itemWidth + _itemMargin)),
                      ...layout.widgetOrder.asMap().entries.map((entry) {
                        final index = entry.key;
                        final key = entry.value;
                        final details = _widgetDetails[key]!;
                        
                        return AnimatedPositioned(
                          key: ValueKey(key),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: index * (_itemWidth + _itemMargin),
                          child: CustomizerCard(
                            title: details['title'],
                            icon: details['icon'],
                            isFirst: index == 0,
                            isLast: index == layout.widgetOrder.length - 1,
                            onMoveLeft: () => _moveItem(ref, layout, index, false),
                            onMoveRight: () => _moveItem(ref, layout, index, true),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}