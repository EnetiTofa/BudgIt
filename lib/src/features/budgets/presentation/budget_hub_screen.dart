import 'package:flutter/material.dart';
import 'package:budgit/src/features/budgets/presentation/budgets_screen.dart';
import 'package:budgit/src/features/savings/presentation/savings_screen.dart';
import 'package:budgit/src/features/wallet/presentation/screens/wallet_screen.dart';

class BudgetHubScreen extends StatefulWidget {
  final int initialTabIndex;
  const BudgetHubScreen({super.key, this.initialTabIndex = 0});

  @override
  State<BudgetHubScreen> createState() => _BudgetHubScreenState();
}

class _BudgetHubScreenState extends State<BudgetHubScreen> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Overview'),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary, // Color for the selected tab
          unselectedLabelColor: Theme.of(context).colorScheme.secondary,
          dividerColor: Colors.transparent,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 4.0, // Set the thickness of the indicator
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.only( // Add rounded corners
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
          ),
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