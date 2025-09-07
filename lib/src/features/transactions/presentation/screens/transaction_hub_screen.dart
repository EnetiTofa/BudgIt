import 'package:flutter/material.dart';
import 'package:budgit/src/features/transactions/presentation/screens/recurring_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/transaction_log_screen.dart';

class TransactionHubScreen extends StatefulWidget {
  final int initialTabIndex;
  const TransactionHubScreen({super.key, this.initialTabIndex = 0});

  @override
  State<TransactionHubScreen> createState() => _TransactionHubScreenState();
}

class _TransactionHubScreenState extends State<TransactionHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
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
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Log'),
            Tab(text: 'Recurring'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TransactionLogScreen(),
          RecurringScreen(),
        ],
      ),
    );
  }
}