import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/presentation/budget_hub_screen.dart';
import 'package:budgit/src/features/categories/presentation/add_category_screen.dart';
import 'package:budgit/src/features/home/presentation/home_screen.dart';
import 'package:budgit/src/features/menu/presentation/menu_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/add_income_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/add_payment_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/transaction_hub_screen.dart';
import 'package:budgit/src/theme/app_theme.dart';
import 'package:budgit/src/features/settings/presentation/theme_controller.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';

/// The root widget of the application.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme controller to get the current theme mode
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Budgit',
      debugShowCheckedModeBanner: false,
      // --- These three lines are the most important part ---
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      home: const AppShell(),
    );
  }
}

/// The main shell of the app, which manages the BottomAppBar and the main pages.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  // The list of main screens for your app, corresponding to the nav bar icons.
  final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const TransactionHubScreen(),
    const BudgetHubScreen(),
    const MenuScreen(),
  ];



  @override
  void initState() {
    super.initState();
    ref.read(allTransactionOccurrencesProvider);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AddPaymentScreen(),
                  ));
                },
              ),
              _buildMenuButton(
                context: ctx,
                icon: Icons.add_circle,
                label: 'Income',
                onTap: () {
                  Navigator.pop(ctx);
                   Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AddIncomeScreen(),
                  ));
                },
              ),
              _buildMenuButton(
                context: ctx,
                icon: Icons.create_new_folder,
                label: 'Category',
                onTap: () {
                  Navigator.pop(ctx);
                   Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AddCategoryScreen(),
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(index: 0, outlinedIcon: Icons.dashboard_outlined, filledIcon: Icons.dashboard),
            _buildNavItem(index: 1, outlinedIcon: Icons.history_outlined, filledIcon: Icons.history),
            
            // 3. Replace the SizedBox with a dedicated Add button
            _buildAddMenuItem(),

            _buildNavItem(index: 2, outlinedIcon: Icons.track_changes_outlined, filledIcon: Icons.track_changes),
            _buildNavItem(index: 3, outlinedIcon: Icons.menu_outlined, filledIcon: Icons.menu),
          ],
        ),
      ),
    );
  }

  // 4. Add this new helper method to build the central button
  Widget _buildAddMenuItem() {
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
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData outlinedIcon, required IconData filledIcon}) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        isSelected ? filledIcon : outlinedIcon,
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}