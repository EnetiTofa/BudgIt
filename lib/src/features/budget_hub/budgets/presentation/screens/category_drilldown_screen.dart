// lib/src/features/budgets/presentation/screens/category_drilldown_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/category_detail_view.dart';
import 'package:budgit/src/features/categories/presentation/screens/edit_basic_category_screen.dart';

class CategoryDrilldownScreen extends ConsumerStatefulWidget {
  const CategoryDrilldownScreen({
    super.key,
    required this.categories,
    required this.initialIndex,
  });

  final List<Category> categories;
  final int initialIndex;

  @override
  ConsumerState<CategoryDrilldownScreen> createState() =>
      _CategoryDrilldownScreenState();
}

class _CategoryDrilldownScreenState
    extends ConsumerState<CategoryDrilldownScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.categories.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    // --- THIS IS THE FIX ---
    // Listen to the animation to update the title mid-swipe.
    _tabController.animation!.addListener(() {
      // Round the animation value to get the nearest index
      final newIndex = _tabController.animation!.value.round();
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
    // --- END OF FIX ---
  }

  @override
  void dispose() {
    // The animation listener is automatically disposed with the controller.
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = widget.categories[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(currentCategory.icon, color: currentCategory.color),
            const SizedBox(width: 8),
            Text(currentCategory.name),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditBasicCategoryScreen(
                    category: currentCategory,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          dividerColor: Colors.transparent,
          indicator: const BoxDecoration(),
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.secondary.withAlpha(100),
          tabs: widget.categories
              .map((category) => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category.icon),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.categories
            .map((category) => CategoryDetailView(categoryId: category.id))
            .toList(),
      ),
    );
  }
}