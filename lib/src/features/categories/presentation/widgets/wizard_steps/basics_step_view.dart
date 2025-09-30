// lib/src/features/categories/presentation/widgets/wizard_steps/basics_step_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/color_picker_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/common_widgets/icon_picker_field.dart';
import 'package:budgit/src/features/categories/presentation/controllers/add_category_controller.dart';

class BasicsStepView extends ConsumerStatefulWidget {
  const BasicsStepView({super.key});

  @override
  ConsumerState<BasicsStepView> createState() => BasicsStepViewState();
}

class BasicsStepViewState extends ConsumerState<BasicsStepView> {
  late final TextEditingController _nameController;
  late final AddCategoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(addCategoryControllerProvider.notifier);
    final initialState = ref.read(addCategoryControllerProvider);
    
    // The controller is pre-filled with the initial state name.
    _nameController = TextEditingController(text: initialState.name);

    // Add a listener to update the provider in real-time as the user types.
    _nameController.addListener(() {
      _controller.setName(_nameController.text);
    });
  }

  // REMOVED: The save() method is no longer needed.

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get the latest state for the icon and color.
    final state = ref.watch(addCategoryControllerProvider);

    return SingleChildScrollView(
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
            // Read the selected icon directly from the provider state
            selectedIcon: state.icon,
            // Update the provider directly when a new icon is selected
            onIconSelected: (icon) => _controller.setIcon(icon),
          ),
          const SizedBox(height: 16),
          ColorPickerField(
            labelText: 'Color',
            // Read the selected color directly from the provider state
            selectedColor: state.color,
            // Update the provider directly when a new color is selected
            onColorSelected: (color) => _controller.setColor(color),
          ),
        ],
      ),
    );
  }
}