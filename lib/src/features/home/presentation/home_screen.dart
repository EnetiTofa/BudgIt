import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/home/presentation/dashboard_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  // V-- The build method needs two parameters: context and ref
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _MonthlySummaryCard(),
          // We can add more dashboard widgets here later
        ],
      ),
    );
  }
}

class _MonthlySummaryCard extends ConsumerWidget {
  const _MonthlySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: switch (summaryAsync) {
          AsyncLoading() => const Center(child: CircularProgressIndicator()),
          AsyncError(:final error) => Center(child: Text('Error: $error')),
          AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Progress', style: textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: value.progress,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade300,
                          ),
                          Center(
                            child: Text(
                              '${(value.progress * 100).toStringAsFixed(0)}%',
                              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spent', style: textTheme.bodyMedium),
                        Text(
                          '\$${value.totalSpending.toStringAsFixed(2)}',
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Remaining', style: textTheme.bodyMedium),
                        Text(
                          '\$${value.amountRemaining.toStringAsFixed(2)}',
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}