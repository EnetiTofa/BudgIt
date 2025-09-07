import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/wallet/presentation/controllers/boost_controller.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/boost_slider_card.dart';

class BoostScreen extends ConsumerWidget {
  final Category toCategory;
  const BoostScreen({super.key, required this.toCategory});

  Future<void> _confirmBoosts(BuildContext context, WidgetRef ref) async {
    // The logic is now simpler, just calling the provider.
    await ref.read(boostStateProvider(toCategory).notifier).confirmBoosts();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pass the "toCategory" to the provider so it knows what to load.
    final boostStateAsync = ref.watch(boostStateProvider(toCategory));

    return Scaffold(
      appBar: AppBar(
        title: Text('Boost "${toCategory.name}"'),
        // We no longer need the custom back button.
      ),
      body: switch (boostStateAsync) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        AsyncData() => _BoostScreenContent(toCategory: toCategory),
        _ => const SizedBox.shrink(),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _confirmBoosts(context, ref),
        label: const Text('Confirm Boosts'),
        icon: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Helper widget to contain the main content, preventing rebuilds.
class _BoostScreenContent extends ConsumerWidget {
  final Category toCategory;
  const _BoostScreenContent({required this.toCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableCategoriesAsync = ref.watch(categoryListProvider);
    return switch (availableCategoriesAsync) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError() => const Center(child: Text('Could not load categories.')),
      AsyncData(:final value) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: value
              .where((cat) => cat.id != toCategory.id && (cat.walletAmount ?? 0) > 0)
              .map((cat) => BoostSliderCard(
                    fromCategory: cat,
                    toCategory: toCategory, // Pass the toCategory to the slider card
                  ))
              .toList(),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}