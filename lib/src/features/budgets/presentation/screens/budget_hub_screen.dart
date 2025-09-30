import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:budgit/src/features/savings/presentation/savings_screen.dart';
import 'package:budgit/src/features/wallet/presentation/screens/wallet_screen.dart';

class BudgetHubScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const BudgetHubScreen({super.key, this.initialTabIndex = 1});

  @override
  ConsumerState<BudgetHubScreen> createState() => _BudgetHubScreenState();
}

class _BudgetHubScreenState extends ConsumerState<BudgetHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index != 1) {
      ref.read(selectedCategoryProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Overview'),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.secondary,
          dividerColor: Colors.transparent,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 4.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
          // **THE FIX: Added the onTap callback.**
          onTap: (index) {
            // If the Budgets tab (index 1) is tapped...
            if (index == 1) {
              // ...and it's already the current tab...
              if (_tabController.index == 1) {
                // ...then reset the category detail view.
                ref.read(selectedCategoryProvider.notifier).state = null;
              }
            }
          },
          tabs: const [
            Tab(text: 'Wallet', icon: Icon(Icons.wallet_outlined)),
            Tab(text: 'Budgets', icon: Icon(Icons.track_changes_outlined)),
            Tab(text: 'Savings', icon: Icon(Icons.savings_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WalletScreen(),
          BudgetsScreen(),
          SavingsScreen(),
        ],
      ),
    );
  }
}