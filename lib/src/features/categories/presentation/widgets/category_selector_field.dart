import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

/// A custom form field for selecting a category.
///
/// It displays the selected category's color, icon, and name. When tapped,
/// it opens a dropdown menu with a list of categories to choose from.
class CategorySelectorField extends ConsumerStatefulWidget {
  const CategorySelectorField({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.labelText = '',
  });

  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;
  final String labelText;

  @override
  ConsumerState<CategorySelectorField> createState() =>
      _CategorySelectorFieldState();
}

class _CategorySelectorFieldState extends ConsumerState<CategorySelectorField>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get _isDropdownOpen => _overlayEntry != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggleDropdown() async {
    if (_isDropdownOpen) {
      await _closeDropdown();
    } else {
      _openDropdown();
    }
    if (mounted) {
      setState(() {}); // Rebuild to update the dropdown arrow icon
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  Future<void> _closeDropdown() async {
    if (_overlayEntry != null) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final theme = Theme.of(context);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                await _closeDropdown();
                if (mounted) {
                  setState(() {});
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height - 8.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                elevation: 0.0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width,
                    maxHeight: 250,
                  ),
                  child: _CategorySelectionMenu(
                    selectedCategory: widget.selectedCategory,
                    onCategorySelected: (category) async {
                      widget.onCategorySelected(category);
                      await _closeDropdown();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final hasCategory = widget.selectedCategory != null;
    
    // --- UPDATED BACKGROUND & BORDER LOGIC ---
    // If selected: Use category color, no border.
    // If not selected: surfaceContainerLowest, outline border.
    final backgroundColor = hasCategory 
        ? widget.selectedCategory!.color 
        : colorScheme.surfaceContainerLowest; // Changed from Transparent
        
    final border = hasCategory 
        ? null 
        : Border.all(color: colorScheme.outline);

    // --- CONTENT COLOR LOGIC ---
    final Color contentColor;
    if (hasCategory) {
      contentColor = widget.selectedCategory!.contentColor;
    } else {
      contentColor = colorScheme.onSurface;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          Text(
            widget.labelText,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: AnimatedContainer(
            height: 60.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              border: border, // Outline applied when empty
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleDropdown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      if (hasCategory) ...[
                        Icon(widget.selectedCategory!.icon,
                            color: contentColor, size: 22),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          hasCategory
                              ? widget.selectedCategory!.name
                              : 'Select a category...',
                          style: textTheme.bodyLarge?.copyWith(
                            color: contentColor,
                            fontWeight:
                                hasCategory ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ),
                      Icon(
                        _isDropdownOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: contentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The content of the dropdown menu for category selection.
class _CategorySelectionMenu extends ConsumerWidget {
  const _CategorySelectionMenu({
    this.selectedCategory,
    required this.onCategorySelected,
  });

  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget buildCategoryOption(Category category) {
      final isSelected = selectedCategory?.id == category.id;
      final textColor = isSelected ? colorScheme.primary : colorScheme.onSurface;

      return ListTile(
        leading: Icon(category.icon, color: category.color),
        title: Text(
          category.name,
          style: textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_rounded, color: colorScheme.primary)
            : null,
        onTap: () => onCategorySelected(category),
        dense: true,
      );
    }

    return switch (categoriesAsync) {
      AsyncLoading() => const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        ),
      AsyncError() =>
        const Center(child: Text('Could not load categories.')),
      AsyncData(:final value) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          shrinkWrap: true,
          children: value.map(buildCategoryOption).toList(),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}