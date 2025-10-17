// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:budgit/src/features/check_in/presentation/app_bar_info_provider.dart';
import 'package:budgit/src/app/navigation_provider.dart';
import 'package:budgit/src/features/budgets/presentation/screens/budget_hub_screen.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_screen.dart';
import 'package:budgit/src/features/check_in/presentation/is_check_in_available_provider.dart';
import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/home/presentation/home_screen.dart';
import 'package:budgit/src/features/menu/presentation/menu_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/add_income_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/add_payment_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/transaction_hub_screen.dart';
import 'package:budgit/src/theme/app_theme.dart';
import 'package:budgit/src/features/settings/presentation/theme_controller.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';

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

  final List<String> _screenTitles = const [
    'Dashboard',
    'Transactions',
    'Financial Overview',
    'Menu',
  ];

  @override
  void initState() {
    super.initState();
    ref.read(allTransactionOccurrencesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainPageIndexProvider);
    final theme = Theme.of(context);
    final formattedDate = DateFormat('d MMMM').format(DateTime.now());
    final isCheckInAvailableAsync = ref.watch(isCheckInAvailableProvider);
    const checkInEligibleScreenIndices = {0, 1, 2};

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        titleSpacing: 16.0,
        toolbarHeight: 48.0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Consumer(
                builder: (context, ref, child) {
                  final appBarInfoAsync = ref.watch(appBarInfoProvider);
                  // --- MODIFICATION: Added `skipLoadingOnReload` to prevent flicker ---
                  return appBarInfoAsync.when(
                    skipLoadingOnReload: true,
                    loading: () => Container(
                      height: 34.0,
                      width: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    error: (e, s) => SizedBox(
                      height: 34.0,
                      child: Center(
                        child: Icon(Icons.cloud_off, color: theme.colorScheme.tertiary),
                      ),
                    ),
                    data: (info) {
                      final isHeated = info.isCheckInCompleted;
                      return Container(
                        height: 34.0,
                        padding: const EdgeInsets.only(left: 14.0, right: 16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (isHeated)
                                  Icon(
                                    Icons.circle,
                                    color: Colors.yellow.shade600,
                                    size: 16,
                                  ),
                                FaIcon(
                                  FontAwesomeIcons.fire,
                                  size: 20,
                                  color: isHeated
                                      ? Colors.orange.shade700
                                      : theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              info.streakCount.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90.0),
              child: Center(
                child: Text(
                  _screenTitles[selectedIndex],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formattedDate,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isCheckInAvailableAsync.when(
        data: (isAvailable) {
          if (isAvailable && checkInEligibleScreenIndices.contains(selectedIndex)) {
            return PulsingButton(
              label: 'Check In',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckInScreen()));
              },
            );
          } else {
            return _screens[selectedIndex];
          }
        },
        loading: () => _screens[selectedIndex],
        error: (e, s) => _screens[selectedIndex],
      ),
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
        return Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoryListProvider);
            final bool hasCategories = categoriesAsync.maybeWhen(
              data: (categories) => categories.isNotEmpty,
              orElse: () => false,
            );
            final theme = Theme.of(context);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
              child: Row(
                children: [
                  _buildMenuButton(
                    context: ctx,
                    icon: Icons.remove_circle,
                    label: 'Payment',
                    color: hasCategories ? Colors.red.shade400 : theme.colorScheme.surfaceContainer,
                    contentColor: hasCategories ? Colors.white : theme.colorScheme.secondary,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (hasCategories) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPaymentScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add a category first.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  _buildMenuButton(
                    context: ctx,
                    icon: Icons.add_circle,
                    label: 'Income',
                    color: Colors.green.shade400,
                    contentColor: Colors.white,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddIncomeScreen()));
                    },
                  ),
                  const SizedBox(width: 24),
                  _buildMenuButton(
                    context: ctx,
                    icon: Icons.create_new_folder,
                    label: 'Category',
                    color: Colors.amber.shade400,
                    contentColor: Colors.white,
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
      },
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color contentColor,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0, 
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center( 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: contentColor, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(color: contentColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}