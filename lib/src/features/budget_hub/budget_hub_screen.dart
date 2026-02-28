// lib/src/features/budget_hub/presentation/screens/budget_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/presentation/screens/budgets_screen.dart';
import 'package:budgit/src/features/budget_hub/presentation/screens/weekly_screen.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

// Note: SavingsScreen import is temporarily commented out while locked
// import 'package:budgit/src/features/budget_hub/savings/presentation/savings_screen.dart';

class BudgetHubScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const BudgetHubScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<BudgetHubScreen> createState() => _BudgetHubScreenState();
}

class _BudgetHubScreenState extends ConsumerState<BudgetHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check if the user has any categories
    final categoriesAsync = ref.watch(categoryListProvider);
    final isLocked = categoriesAsync.maybeWhen(
      data: (categories) => categories.isEmpty,
      orElse: () =>
          false, // Default to unlocked while loading to prevent UI flashing
    );

    return Column(
      children: [
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
            tabs: [
              // 2. Change icons dynamically based on lock status
              Tab(
                text: 'Wallet',
                icon: Icon(
                  isLocked ? Icons.lock_outline : Icons.wallet_outlined,
                ),
              ),
              Tab(
                text: 'Budgets',
                icon: Icon(
                  isLocked ? Icons.lock_outline : Icons.track_changes_outlined,
                ),
              ),
              const Tab(text: 'Savings', icon: Icon(Icons.lock_outline)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 3. Render the lock screen or the actual screens
              isLocked ? const _NoCategoriesView() : const WeeklyScreen(),
              isLocked ? const _NoCategoriesView() : const BudgetsScreen(),
              isLocked ? const _NoCategoriesView() : const _LockedSavingsView(),
            ],
          ),
        ),
      ],
    );
  }
}

// --- NEW: View for when NO categories exist in the app ---
class _NoCategoriesView extends StatelessWidget {
  const _NoCategoriesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: theme.colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            "Hub Locked",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Create your first category to unlock the Wallet and Budgets features!",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// --- View for the specific Savings tab lock ---
class _LockedSavingsView extends StatelessWidget {
  const _LockedSavingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: theme.colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            "Savings Locked",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "The savings feature is currently locked. Check back later to start tracking your goals!",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
