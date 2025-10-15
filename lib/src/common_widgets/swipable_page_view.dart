import 'package:flutter/material.dart';

class SwipablePageView extends StatefulWidget {
  const SwipablePageView({
    super.key,
    required this.pages,
    this.controller,
    this.initialPage = 0,
    this.backgroundColor,
    this.height, // Add height property
  });

  final List<Widget> pages;
  final PageController? controller;
  final int initialPage;
  final Color? backgroundColor;
  final double? height; // Add height property

  @override
  State<SwipablePageView> createState() => _SwipablePageViewState();
}

class _SwipablePageViewState extends State<SwipablePageView> {
  late PageController _pageController;
  late final ValueNotifier<int> _currentPageNotifier;

  @override
  void initState() {
    super.initState();
    _pageController = widget.controller ?? PageController(initialPage: widget.initialPage);
    _currentPageNotifier = ValueNotifier<int>(_pageController.initialPage);

    _pageController.addListener(() {
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPageNotifier.value) {
        _currentPageNotifier.value = newPage;
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _pageController.dispose();
    }
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE FIX ---
    // The Column that contains our UI.
    final content = Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: PageView(
              controller: _pageController,
              children: widget.pages,
            ),
          ),
        ),
        _buildDotIndicator(),
      ],
    );

    // If a height is provided, constrain the widget with a SizedBox.
    // Otherwise, let it expand freely (for use in our ManageCategoryScreen).
    if (widget.height != null) {
      return SizedBox(height: widget.height, child: content);
    }
    return content;
    // --- END OF FIX ---
  }

  Widget _buildDotIndicator() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pages.length, (index) {
            return GestureDetector(
              onTap: () => _pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}