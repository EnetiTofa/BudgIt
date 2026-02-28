import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/category.dart';

class FilteredCategorySelector extends StatefulWidget {
  const FilteredCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.labelText = '',
  });

  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;
  final String labelText;

  @override
  State<FilteredCategorySelector> createState() => _FilteredCategorySelectorState();
}

class _FilteredCategorySelectorState extends State<FilteredCategorySelector> 
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
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
  // If the overlay is open, remove it immediately without animating
  if (_overlayEntry != null) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  _animationController.dispose();
  super.dispose();
}

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 8.0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: widget.categories.map((category) {
                    final isSelected = widget.selectedCategory?.id == category.id;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'), 
                        color: Color(category.colorValue),
                      ),
                      title: Text(category.name),
                      trailing: isSelected 
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 16) 
                          : null,
                      onTap: () {
                        widget.onCategorySelected(category);
                        _removeOverlay();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _removeOverlay() async {
    await _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = widget.selectedCategory;
    
    // --- STYLING LOGIC ---
    // If selected: Solid Color Background, Contras Text
    // If null: Surface Background, Outline Border
    final isSelected = cat != null;
    
    final backgroundColor = isSelected 
        ? Color(cat.colorValue) 
        : Colors.transparent;
    
    final borderColor = isSelected 
        ? Colors.transparent 
        : theme.colorScheme.outlineVariant;
        
    final textColor = isSelected 
        ? cat.contentColor 
        : theme.colorScheme.onSurface;
        
    final iconColor = isSelected 
        ? cat.contentColor 
        : theme.colorScheme.onSurfaceVariant;

    final name = cat?.name ?? "Select Category";
    final iconData = cat != null 
        ? IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons') 
        : Icons.category_outlined;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.labelText.isNotEmpty) ...[
                Text(
                  widget.labelText, 
                  // If background is dark, make label slightly transparent white
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected ? textColor.withOpacity(0.8) : theme.colorScheme.onSurfaceVariant
                  )
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  // We remove the CircleAvatar background when the whole container is colored
                  // to make it cleaner (just the icon), or keep it subtle.
                  // Let's keep it clean: Just the icon.
                  Icon(iconData, size: 20, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name, 
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: iconColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}