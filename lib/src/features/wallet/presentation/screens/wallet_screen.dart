import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/average_spending_speedometers.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/daily_spending_gauges.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/wallet_bar_chart.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/wallet_category_card.dart';
import 'package:budgit/src/features/wallet/presentation/controllers/wallet_category_data_provider.dart';
import 'package:budgit/src/features/settings/data/settings_repository.dart';

// The "loading shell" is the main entry point for this screen.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading settings: $e')),
      data: (settingsRepo) => _WalletScreenContent(settingsRepo: settingsRepo),
    );
  }
}

// The main content is in its own widget.
class _WalletScreenContent extends ConsumerStatefulWidget {
  final SettingsRepository settingsRepo;
  const _WalletScreenContent({required this.settingsRepo});

  @override
  ConsumerState<_WalletScreenContent> createState() => __WalletScreenContentState();
}

class __WalletScreenContentState extends ConsumerState<_WalletScreenContent> {
  final _pageController = PageController();
  // Use a ValueNotifier to manage the page index without causing a full rebuild.
  late final ValueNotifier<int> _currentPageNotifier;

  // This is now a hardcoded list of the widgets for the PageView.
  final List<Widget> _pages = [
    const DailySpendingGauges(),
    const AverageSpendingSpeedometers(),
    const WalletBarChart(),
  ];

  @override
  void initState() {
    super.initState();
    _currentPageNotifier = ValueNotifier<int>(_pageController.initialPage);
    _pageController.addListener(() {
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPageNotifier.value) {
        // Update the notifier's value instead of calling setState.
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
    final checkInDay = widget.settingsRepo.getCheckInDay();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          height: screenWidth - 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
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
              _buildDotIndicator(_pages.length),
            ],
          )
        ),
        const SizedBox(height: 16),
        walletCategoryDataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (data) => Column(
            children: data.map((d) {
              final today = DateTime.now().weekday;
              int daysRemaining = (checkInDay - today + 7) % 7;
              if (daysRemaining == 0) daysRemaining = 7;
              
              return WalletCategoryCard(data: d, daysRemaining: daysRemaining);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // The dot indicator is now wrapped in a ValueListenableBuilder.
  Widget _buildDotIndicator(int length) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(length, (index) {
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
                      : Colors.grey.withOpacity(0.5),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}