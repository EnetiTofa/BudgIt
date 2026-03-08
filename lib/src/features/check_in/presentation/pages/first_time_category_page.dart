import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/features/categories/presentation/screens/edit_basic_category_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/core/domain/models/category.dart';

class FirstTimeCategoryPage extends ConsumerStatefulWidget {
  const FirstTimeCategoryPage({super.key});

  @override
  ConsumerState<FirstTimeCategoryPage> createState() =>
      _FirstTimeCategoryPageState();
}

class _FirstTimeCategoryPageState extends ConsumerState<FirstTimeCategoryPage> {
  List<Category>? _localCategories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListProvider);

    // --- THE FIX: Listen for any new additions or edits in the background ---
    ref.listen<AsyncValue<List<Category>>>(categoryListProvider, (
      previous,
      next,
    ) {
      next.whenData((categories) {
        // Automatically sync our local drag-and-drop list with the new database data!
        setState(() {
          _localCategories = List.from(categories);
        });
      });
    });

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.folder_special_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "Create Your Categories",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Categories are the buckets you use to organize your spending. Create a few to get started.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      "No categories added yet.\nLet's make your first one!",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  );
                }

                // Initial load sync
                _localCategories ??= List.from(categories);

                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  proxyDecorator: (child, index, animation) {
                    return Material(color: Colors.transparent, child: child);
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _localCategories!.removeAt(oldIndex);
                      _localCategories!.insert(newIndex, item);
                    });
                    // Note: If you add order-saving later, call the controller here!
                  },
                  itemCount: _localCategories!.length,
                  itemBuilder: (context, index) {
                    final cat = _localCategories![index];
                    final catColor = Color(cat.colorValue);

                    return Dismissible(
                      key: Key(cat.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) async {
                        setState(() {
                          _localCategories!.removeAt(index);
                        });
                        await ref
                            .read(addTransactionControllerProvider.notifier)
                            .deleteCategory(cat.id);
                      },
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: catColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditBasicCategoryScreen(category: cat),
                              ),
                            );
                          },
                          child: ListTile(
                            minTileHeight: 70,
                            leading: Icon(
                              IconData(
                                cat.iconCodePoint,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: cat.contentColor,
                              size: 28,
                            ),
                            title: Text(
                              cat.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cat.contentColor,
                              ),
                            ),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle_rounded,
                                color: cat.contentColor.withOpacity(0.5),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) =>
                  const Center(child: Text("Error loading categories")),
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              "Add a Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tap to edit, swipe to delete, or drag the handle to reorder.",
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
