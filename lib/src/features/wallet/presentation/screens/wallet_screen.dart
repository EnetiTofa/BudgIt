import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/average_spending_speedometers.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/daily_spending_gauges.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/wallet_bar_chart.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/wallet_category_card.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_category_data_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  // THE FIX: Set the initialPage to 1 to start on the middle page.
  final _pageController = PageController(initialPage: 1);
  late final ValueNotifier<int> _currentPageNotifier;

  // This is our simple, hardcoded list of pages.
  final List<Widget> _pages = [
    const DailySpendingGauges(),
    const WalletBarChart(),
    const AverageSpendingSpeedometers(),
  ];

  @override
  void initState() {
    super.initState();
    _currentPageNotifier = ValueNotifier<int>(_pageController.initialPage);
    _pageController.addListener(() {
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPageNotifier.value) {
        _currentPageNotifier.value = newPage;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletCategoryDataAsync = ref.watch(walletCategoryDataProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          height: screenWidth - 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: _pages,
                ),
              ),
            ],
          )
        ),
        _buildDotIndicator(),
        walletCategoryDataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (data) => Column(
            children: data.map((d) => WalletCategoryCard(data: d)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDotIndicator() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (index) {
            return GestureDetector(
              onTap: () => _pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}