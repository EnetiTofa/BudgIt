import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/constants/app_icons.dart';
import 'package:budgit/src/common_widgets/general_search_bar.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';

// 1. Define the StateNotifier for managing recent icons
class RecentIconsNotifier extends StateNotifier<List<IconDefinition>> {
  final Ref _ref;
  RecentIconsNotifier(this._ref) : super([]) {
    _loadRecents();
  }

  // Load icons from storage when the notifier is first created
  Future<void> _loadRecents() async {
    final repository = _ref.read(transactionRepositoryProvider);
    final iconNames = await repository.getRecentIcons();
    // Convert the saved names back into IconDefinition objects
    final icons = iconNames
        .map((name) =>
            AppIcons.allIcons.firstWhere((def) => def.name == name))
        .toList();
    state = icons;
  }

  // Add a new icon, update the state, and save to storage
  Future<void> addIcon(IconDefinition iconDef) async {
    final currentState = state;
    final newState = currentState
        .where((i) => i.icon.codePoint != iconDef.icon.codePoint)
        .toList();

    final updatedList = [iconDef, ...newState].take(20).toList();
    state = updatedList;

    final repository = _ref.read(transactionRepositoryProvider);
    final iconNamesToSave = updatedList.map((def) => def.name).toList();
    await repository.saveRecentIcons(iconNamesToSave);
  }
}

// 2. Define the StateNotifierProvider
final recentIconsProvider =
    StateNotifierProvider<RecentIconsNotifier, List<IconDefinition>>(
        (ref) => RecentIconsNotifier(ref));

// --- The rest of the file is mostly unchanged, but refers to the new provider ---

class IconPickerField extends ConsumerWidget {
  const IconPickerField({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
    this.labelText = 'Icon',
  });

  final IconData? selectedIcon;
  final ValueChanged<IconData> onIconSelected;
  final String labelText;

  void _showIconPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return _IconPickerModal(
            scrollController: scrollController,
            onIconSelected: (iconDef) {
              onIconSelected(iconDef.icon);
              // 3. Call the notifier's method to add and save the icon
              ref.read(recentIconsProvider.notifier).addIcon(iconDef);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... The build method for the field itself is unchanged ...
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showIconPicker(context, ref),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                if (selectedIcon != null) ...[
                  Icon(selectedIcon, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedIcon != null ? 'Icon Selected' : 'Choose an icon...',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconPickerModal extends ConsumerStatefulWidget {
  // ... This widget remains unchanged ...
  final ScrollController scrollController;
  final ValueChanged<IconDefinition> onIconSelected;

  const _IconPickerModal(
      {required this.scrollController, required this.onIconSelected});

  @override
  ConsumerState<_IconPickerModal> createState() => _IconPickerModalState();
}

class _IconPickerModalState extends ConsumerState<_IconPickerModal> {
  String _searchQuery = '';
  static const Map<String, IconData> _tabIcons = {
    'Recents': Icons.history_outlined,
    'Food & Drink': Icons.restaurant_menu_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Travel & Transport': Icons.flight_takeoff_outlined,
    'Home & Utilities': Icons.home_outlined,
    'Finance & Bills': Icons.monetization_on_outlined,
    'Health & Wellness': Icons.favorite_border_outlined,
    'Entertainment': Icons.theaters_outlined,
    'Personal': Icons.face_outlined,
    'Tech & Brands': Icons.devices_other_outlined,
    'Other': Icons.more_horiz_outlined,
  };
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: GeneralSearchBar(
            hintText: 'Search all icons...',
            onChanged: _onSearchChanged,
            onClear: () => _onSearchChanged(''),
            useLabelText: false,
          ),
        ),
        Expanded(
          child: _searchQuery.isEmpty
              ? _buildTabbedView()
              // ... rest of build method is unchanged
              : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final searchResults = AppIcons.allIcons
        .where((iconDef) => iconDef.name.toLowerCase().contains(_searchQuery))
        .toList();
    if (searchResults.isEmpty) {
      return const Center(child: Text('No icons found.'));
    }
    return _buildIconGridView(searchResults);
  }

  Widget _buildTabbedView() {
    final recentIcons = ref.watch(recentIconsProvider);
    final tabCategories = ['Recents', ...AppIcons.categorizedIcons.keys];
    return DefaultTabController(
      length: tabCategories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: tabCategories
                .map((name) => Tab(icon: Icon(_tabIcons[name] ?? Icons.error)))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: [
                if (recentIcons.isEmpty)
                  const Center(
                      child: Text('Recently used icons will appear here.'))
                else
                  _buildIconGridView(recentIcons),
                ...AppIcons.categorizedIcons.entries.map((entry) {
                  return _buildIconGridView(entry.value);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconGridView(List<IconDefinition> icons) {
    return GridView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconDef = icons[index];
        return InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => widget.onIconSelected(iconDef),
          child: Icon(iconDef.icon,
              size: 30, color: Theme.of(context).colorScheme.primary),
        );
      },
    );
  }
}