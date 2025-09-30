// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/app/navigation_provider.dart';
import 'package:budgit/src/features/budgets/presentation/screens/budget_hub_screen.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/features/home/presentation/home_screen.dart';
import 'package:budgit/src/features/menu/presentation/menu_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/add_income_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/add_payment_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/transaction_hub_screen.dart';
import 'package:budgit/src/theme/app_theme.dart';
import 'package:budgit/src/features/settings/presentation/theme_controller.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Budgit',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final List<Widget> _screens = const <Widget>[
    HomeScreen(key: ValueKey('HomeScreen')),
    TransactionHubScreen(key: ValueKey('TransactionHubScreen')),
    BudgetHubScreen(key: ValueKey('BudgetHubScreen')),
    MenuScreen(key: ValueKey('MenuScreen')),
  ];

  // --- REMOVED ---
  // The _previousIndex variable is no longer needed.

  @override
  void initState() {
    super.initState();
    // --- SIMPLIFIED ---
    // The logic for setting the initial index is no longer needed.
    ref.read(allTransactionOccurrencesProvider);
  }

  @override
  Widget build(BuildContext context) {
    // --- REMOVED ---
    // The ref.listen block is no longer needed because we don't have to
    // manage any animation state.

    final selectedIndex = ref.watch(mainPageIndexProvider);

    return Scaffold(
      // --- THE CHANGE IS HERE ---
      // We directly show the selected screen from the list.
      // When selectedIndex changes, ref.watch triggers a rebuild,
      // and this line instantly displays the new screen.
      body: _screens[selectedIndex],
      // --- END OF CHANGE ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(index: 0, currentIndex: selectedIndex, outlinedIcon: Icons.dashboard_outlined, filledIcon: Icons.dashboard),
            _buildNavItem(index: 1, currentIndex: selectedIndex, outlinedIcon: Icons.history_outlined, filledIcon: Icons.history),
            _buildAddMenuItem(context),
            _buildNavItem(index: 2, currentIndex: selectedIndex, outlinedIcon: Icons.track_changes_outlined, filledIcon: Icons.track_changes),
            _buildNavItem(index: 3, currentIndex: selectedIndex, outlinedIcon: Icons.menu_outlined, filledIcon: Icons.menu),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required int currentIndex, required IconData outlinedIcon, required IconData filledIcon}) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () => ref.read(mainPageIndexProvider.notifier).setIndex(index),
      icon: Icon(
        isSelected ? filledIcon : outlinedIcon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
      ),
    );
  }
  
  Widget _buildAddMenuItem(BuildContext context) {
    return InkWell(
      onTap: () => _showAddMenu(context),
      customBorder: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuButton(
                context: ctx,
                icon: Icons.remove_circle,
                label: 'Payment',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPaymentScreen()));
                },
              ),
              _buildMenuButton(
                context: ctx,
                icon: Icons.add_circle,
                label: 'Income',
                onTap: () {
                  Navigator.pop(ctx);
                   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddIncomeScreen()));
                },
              ),
              _buildMenuButton(
                context: ctx,
                icon: Icons.create_new_folder,
                label: 'Category',
                onTap: () {
                  Navigator.pop(ctx);
                   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCategoryScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton({required BuildContext context, required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 40),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}