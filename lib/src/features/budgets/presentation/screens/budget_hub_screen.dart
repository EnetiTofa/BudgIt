// lib/src/features/budgets/presentation/screens/budget_hub_screen.dart
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- MODIFICATION: Removed Scaffold and AppBar ---
    return Column(
      children: [
        // --- MODIFICATION: The TabBar now lives here ---
        Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: TabBar(
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
            tabs: const [
              Tab(text: 'Wallet', icon: Icon(Icons.wallet_outlined)),
              Tab(text: 'Budgets', icon: Icon(Icons.track_changes_outlined)),
              Tab(text: 'Savings', icon: Icon(Icons.savings_outlined)),
            ],
          ),
        ),
        // The TabBarView needs to be wrapped in an Expanded widget
        // so it fills the remaining space in the Column.
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              WalletScreen(),
              BudgetsScreen(),
              SavingsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}