import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_dropdown_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/constants/app_icons.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/presentation/add_transaction_controller.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';

class CategoryForm extends ConsumerStatefulWidget {
  final Category? initialCategory;
  const CategoryForm({super.key, this.initialCategory});

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  final _nameController = TextEditingController();
  double _budgetAmount = 0.0;
  double _walletAmount = 0.0;
  BudgetPeriod _budgetPeriod = BudgetPeriod.monthly;
  IconData _selectedIcon = AppIcons.defaultIcon;
  Color _selectedColor = Colors.blue;

  bool get isEditing => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final category = widget.initialCategory!;
      _nameController.text = category.name;
      _budgetAmount = category.budgetAmount;
      _walletAmount = category.walletAmount ?? 0.0;
      _budgetPeriod = category.budgetPeriod;
      _selectedIcon = category.icon;
      _selectedColor = category.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showIconPicker() async {
    final IconData? result = await showDialog<IconData>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an Icon'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              itemCount: AppIcons.categoryIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemBuilder: (context, index) {
                final icon = AppIcons.categoryIcons[index];
                final isSelected = icon.codePoint == _selectedIcon.codePoint;
                return InkWell(
                  onTap: () => Navigator.of(context).pop(icon),
                  borderRadius: BorderRadius.circular(50),
                  child: CircleAvatar(
                    backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                    child: FaIcon(icon, color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null),
                  ),
                );
              },
            ),
          ),
          actions: [TextButton(child: const Text('Close'), onPressed: () => Navigator.of(context).pop())],
        );
      },
    );
    if (result != null) setState(() => _selectedIcon = result);
  }
  
  void _submitForm() {
    final name = _nameController.text;
    if (name.isEmpty || _budgetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and budget amount.')),
      );
      return;
    }

    final controller = ref.read(addTransactionControllerProvider.notifier);
    
    if (isEditing) {
      controller.updateCategory(
        id: widget.initialCategory!.id,
        name: name,
        budgetAmount: _budgetAmount,
        walletAmount: _walletAmount > 0 ? _walletAmount : null,
        budgetPeriod: _budgetPeriod,
        icon: _selectedIcon,
        color: _selectedColor,
      );
    } else {
      controller.addCategory(
        name: name,
        budgetAmount: _budgetAmount,
        walletAmount: _walletAmount > 0 ? _walletAmount : null,
        budgetPeriod: _budgetPeriod,
        icon: _selectedIcon,
        color: _selectedColor,
      );
    }
    
    ref.invalidate(categoryListProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextInputField(controller: _nameController, labelText: 'Category Name'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: FaIcon(_selectedIcon),
                  label: const Text('Select Icon'),
                  onPressed: _showIconPicker,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: CircleAvatar(backgroundColor: _selectedColor, radius: 10),
                  label: const Text('Select Color'),
                  onPressed: () async {
                    final color = await showColorPickerDialog(context, _selectedColor);
                    setState(() => _selectedColor = color);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CurrencyInputField(
            labelText: 'Total Budget Amount',
            initialValue: _budgetAmount,
            onChanged: (value) => _budgetAmount = value,
          ),
          const SizedBox(height: 16),
          CustomDropdownField<BudgetPeriod>(
            labelText: 'Budget Period',
            value: _budgetPeriod,
            onChanged: (value) => setState(() => _budgetPeriod = value!),
            items: BudgetPeriod.values.map((period) => DropdownMenuItem(
              value: period,
              child: Text(period.name[0].toUpperCase() + period.name.substring(1)),
            )).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Wallet (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('A weekly amount for discretionary spending.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          CurrencyInputField(
            labelText: 'Wallet Amount',
            initialValue: _walletAmount,
            onChanged: (value) => _walletAmount = value,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(isEditing ? 'Save Changes' : 'Save Category'),
          ),
        ],
      ),
    );
  }
}