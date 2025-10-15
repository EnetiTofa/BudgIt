// lib/src/features/transactions/presentation/screens/transaction_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/app/navigation_provider.dart';
import 'package:budgit/src/common_widgets/general_search_bar.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transactions/presentation/providers/dropdown_active_provider.dart';
import 'package:budgit/src/features/transactions/presentation/screens/recurring_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/transaction_log_screen.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/filter_dropdown.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/sort_dropdown.dart';

enum ActiveDropdown { none, sort, filter }

class TransactionHubScreen extends ConsumerStatefulWidget {
  const TransactionHubScreen({super.key});

  @override
  ConsumerState<TransactionHubScreen> createState() =>
      _TransactionHubScreenState();
}

class _TransactionHubScreenState extends ConsumerState<TransactionHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  final _barKey = GlobalKey();
  final _bodyKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late final AnimationController _overlayAnimationController;
  late final Animation<double> _fadeAnimation;
  ActiveDropdown _activeDropdown = ActiveDropdown.none;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(transactionHubTabIndexProvider);
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    
    _searchController.text = ref.read(logFilterProvider).searchQuery;
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _overlayAnimationController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _removeOverlay() {
    if (_overlayEntry != null) {
      if (mounted) {
        setState(() => _activeDropdown = ActiveDropdown.none);
        ref.read(dropdownActiveProvider.notifier).state = false;
      }
      _overlayAnimationController.reverse().whenComplete(() {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  void _showOverlay({required Widget child, required ActiveDropdown type}) {
    // ... (This method's implementation remains the same)
    if (_overlayEntry != null && type == _activeDropdown) {
      _removeOverlay();
      return;
    }

    if (_overlayEntry != null) {
      _removeOverlay();
      Future.delayed(const Duration(milliseconds: 260), () {
        _showOverlay(child: child, type: type);
      });
      return;
    }
    
    final overlay = Overlay.of(context);
    final barRenderBox = _barKey.currentContext!.findRenderObject() as RenderBox;
    final barSize = barRenderBox.size;
    final barOffset = barRenderBox.localToGlobal(Offset.zero);
    
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: barOffset.dy + barSize.height,
              left: 16.0,
              right: 16.0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: child,
                ),
              ),
            )
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    _overlayAnimationController.forward();
    
    setState(() => _activeDropdown = type);
    ref.read(dropdownActiveProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(transactionHubTabIndexProvider, (previous, next) {
      if (next != _tabController.index) {
        _tabController.animateTo(next);
      }
    });

    final filterController = ref.read(logFilterProvider.notifier);
    final filterState = ref.watch(logFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final bool isSortActive = _activeDropdown == ActiveDropdown.sort || filterState.sortBy != SortBy.date;
    final bool isFilterActive = _activeDropdown == ActiveDropdown.filter ||
        filterState.transactionTypeFilter != TransactionTypeFilter.all ||
        filterState.selectedCategoryIds.isNotEmpty;
    
    final activeStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
      backgroundColor: WidgetStateProperty.all(colorScheme.primary),
    );
    final inactiveStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.all(colorScheme.secondary),
      backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainerLow),
    );

    // --- MODIFICATION: Removed Scaffold and AppBar ---
    return Column(
      children: [
        // --- MODIFICATION: The TabBar now lives here ---
        Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              ref.read(transactionHubTabIndexProvider.notifier).setIndex(index);
            },
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 4.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            tabs: const [
              Tab(text: 'History', icon: Icon(Icons.history)),
              Tab(text: 'Recurring', icon: Icon(Icons.event_repeat)),
            ],
          ),
        ),
        Container(
          key: _barKey,
          padding: const EdgeInsets.all(16.0),
          color: colorScheme.surface,
          child: SizedBox(
            height: 38,
            child: Row(
              children: [
                Expanded(
                  child: Focus(
                    focusNode: _searchFocusNode,
                    child: GeneralSearchBar(
                      initialQuery: filterState.searchQuery,
                      hintText: '',
                      onChanged: filterController.setSearchQuery,
                      onClear: () => filterController.setSearchQuery(''),
                      hasOutline: false,
                      backgroundColor: colorScheme.surfaceContainerLow,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        child: child,
                      ),
                    );
                  },
                  child: _isSearchFocused
                      ? const SizedBox.shrink()
                      : Row(
                          key: const ValueKey('buttons'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(width: 8),
                            FilledButton.tonalIcon(
                              style: isSortActive ? activeStyle : inactiveStyle,
                              onPressed: () => _showOverlay(
                                child: const SortDropdown(),
                                type: ActiveDropdown.sort,
                              ),
                              icon: const Icon(Icons.sort),
                              label: const Text('Sort'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonalIcon(
                              style: isFilterActive ? activeStyle : inactiveStyle,
                              onPressed: () {
                                _showOverlay(
                                  child: const FilterDropdown(),
                                  type: ActiveDropdown.filter,
                                );
                              },
                              icon: const Icon(Icons.filter_list),
                              label: const Text('Filter'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            key: _bodyKey,
            child: TabBarView(
              controller: _tabController,
              children: const [
                TransactionLogScreen(),
                RecurringScreen(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}