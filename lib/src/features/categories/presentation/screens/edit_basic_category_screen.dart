// lib/src/features/categories/presentation/screens/edit_basic_category_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/budgets/presentation/providers/category_gauge_data_provider.dart';
import 'package:budgit/src/common_widgets/color_picker_field.dart';
import 'package:budgit/src/common_widgets/icon_picker_field.dart';
// Import your new custom text field
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';

class EditBasicCategoryScreen extends ConsumerStatefulWidget {
  final Category category;

  const EditBasicCategoryScreen({super.key, required this.category});

  @override
  ConsumerState<EditBasicCategoryScreen> createState() =>
      _EditBasicCategoryScreenState();
}

class _EditBasicCategoryScreenState
    extends ConsumerState<EditBasicCategoryScreen> {
  late final TextEditingController _nameController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColor = widget.category.color;
    _selectedIcon = widget.category.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot be empty.')),
      );
      return;
    }

    final updatedCategory = Category(
      id: widget.category.id,
      name: _nameController.text.trim(),
      iconCodePoint: _selectedIcon.codePoint,
      iconFontFamily: _selectedIcon.fontFamily,
      iconFontPackage: _selectedIcon.fontPackage,
      colorValue: _selectedColor.value,
      budgetAmount: widget.category.budgetAmount,
      walletAmount: widget.category.walletAmount,
    );

    await ref
        .read(categoryListProvider.notifier)
        .updateCategory(updatedCategory);
    
    ref.invalidate(categoryGaugeDataProvider);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THE FIX IS HERE ---
            // Replaced the standard TextField with your custom widget.
            CustomTextInputField(
              controller: _nameController,
              labelText: 'Category Name',
            ),
            // --- END OF FIX ---
            const SizedBox(height: 24),

            ColorPickerField(
              selectedColor: _selectedColor,
              onColorSelected: (newColor) {
                setState(() {
                  _selectedColor = newColor;
                });
              },
            ),
            const SizedBox(height: 24),
            
            IconPickerField(
              selectedIcon: _selectedIcon,
              onIconSelected: (newIcon) {
                setState(() {
                  _selectedIcon = newIcon;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}