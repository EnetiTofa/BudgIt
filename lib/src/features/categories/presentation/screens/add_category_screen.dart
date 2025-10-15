// lib/src/features/categories/presentation/screens/add_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/color_picker_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/common_widgets/icon_picker_field.dart';
import 'package:budgit/src/features/categories/presentation/controllers/add_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/screens/manage_category_screen.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(addCategoryControllerProvider.notifier);
    final initialState = ref.read(addCategoryControllerProvider);
    
    _nameController = TextEditingController(text: initialState.name);
    _nameController.addListener(() {
      notifier.setName(_nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndNavigate() async {
    final notifier = ref.read(addCategoryControllerProvider.notifier);
    final newCategory = await notifier.saveCategory();

    if (mounted && newCategory != null) {
      // Pop the add screen
      Navigator.of(context).pop();
      // Push the manage screen for the new category
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ManageCategoryScreen(category: newCategory),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addCategoryControllerProvider);
    final notifier = ref.read(addCategoryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Category'),
        actions: [
          state.isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : TextButton(
                  onPressed: _nameController.text.trim().isEmpty ? null : _saveAndNavigate,
                  child: const Text('Save'),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What's the category?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "Give it a name, and choose an icon and color to make it recognizable.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomTextInputField(
              controller: _nameController,
              labelText: 'Category Name',
            ),
            const SizedBox(height: 16),
            IconPickerField(
              labelText: 'Icon',
              selectedIcon: state.icon,
              onIconSelected: (icon) => notifier.setIcon(icon),
            ),
            const SizedBox(height: 16),
            ColorPickerField(
              labelText: 'Color',
              selectedColor: state.color,
              onColorSelected: (color) => notifier.setColor(color),
            ),
          ],
        ),
      ),
    );
  }
}