// lib/src/features/transactions/presentation/widgets/payment_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/categories/presentation/widgets/category_selector_field.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/wallet_toggle.dart';
import 'package:budgit/src/common_widgets/date_selector_field.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/period_selector_field.dart';
import 'package:budgit/src/common_widgets/icon_picker_field.dart';


enum PaymentType { oneOff, recurring }

class PaymentForm extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;
  const PaymentForm({super.key, this.initialTransaction});

  @override
  ConsumerState<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  PaymentType _paymentType = PaymentType.oneOff;
  double _amount = 0.0;

  final _itemNameController = TextEditingController();
  final _storeController = TextEditingController();
  final _paymentNameController = TextEditingController();
  final _payeeController = TextEditingController();
  
  Category? _selectedCategory;
  IconData? _selectedIcon;
  DateTime? _selectedDate;
  DateTime? _endDate;
  RecurrencePeriod _recurrence = RecurrencePeriod.monthly;
  int _recurrenceFrequency = 1;
  bool _isWalleted = true;

  bool get isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final transaction = widget.initialTransaction!;
      if (transaction is OneOffPayment) {
        _paymentType = PaymentType.oneOff;
        _itemNameController.text = transaction.itemName;
        _storeController.text = transaction.store;
        _amount = transaction.amount;
        _selectedCategory = transaction.category;
        _selectedDate = transaction.date;
        _isWalleted = transaction.isWalleted;
      } else if (transaction is RecurringPayment) {
        _paymentType = PaymentType.recurring;
        _paymentNameController.text = transaction.paymentName;
        _payeeController.text = transaction.payee;
        _amount = transaction.amount;
        _selectedCategory = transaction.category;
        _selectedDate = transaction.startDate;
        _endDate = transaction.endDate;
        _recurrence = transaction.recurrence;
        _recurrenceFrequency = transaction.recurrenceFrequency;
        if (transaction.iconCodePoint != null) {
          _selectedIcon = IconData(
            transaction.iconCodePoint!,
            fontFamily: transaction.iconFontFamily,
            fontPackage: transaction.iconFontPackage,
          );
        }
      }
    } else {
      _selectedDate = ref.read(clockNotifierProvider).now();
      _isWalleted = true;
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _storeController.dispose();
    _paymentNameController.dispose();
    _payeeController.dispose();
    super.dispose();
  }

  Future<bool?> _showBudgetConfirmationDialog(double newMonthlyAmount) {
    final oldBudget = _selectedCategory!.budgetAmount;
    final newBudget = oldBudget + newMonthlyAmount;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Increase Budget?'),
        content: Text(
          'Adding this recurring payment will increase the monthly budget for the "${_selectedCategory!.name}" category.\n\n'
          'Current Budget: \$${oldBudget.toStringAsFixed(2)}\n'
          'Increase by: \$${newMonthlyAmount.toStringAsFixed(2)}\n\n'
          'New Budget: \$${newBudget.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_amount <= 0 || _selectedCategory == null || _selectedDate == null) {
      return;
    }

    final controller = ref.read(addTransactionControllerProvider.notifier);
    
    if (isEditing) {
      // --- EDITING LOGIC (UNCHANGED) ---
      final originalTx = widget.initialTransaction!;
      if(originalTx is OneOffPayment) {
        final updatedTx = OneOffPayment(
          id: originalTx.id, notes: originalTx.notes, createdAt: originalTx.createdAt,
          amount: _amount, date: _selectedDate!, itemName: _itemNameController.text,
          store: _storeController.text, category: _selectedCategory!, isWalleted: _isWalleted,
        );
        await controller.updateTransaction(updatedTx);
      } else if (originalTx is RecurringPayment) {
        final updatedTx = RecurringPayment(
          id: originalTx.id, notes: originalTx.notes, createdAt: originalTx.createdAt,
          amount: _amount, paymentName: _paymentNameController.text, payee: _payeeController.text,
          category: _selectedCategory!, recurrence: _recurrence, recurrenceFrequency: _recurrenceFrequency,
          startDate: _selectedDate!, endDate: _endDate, iconCodePoint: _selectedIcon?.codePoint,
          iconFontFamily: _selectedIcon?.fontFamily,
          iconFontPackage: _selectedIcon?.fontPackage,
        );
        await controller.updateTransaction(updatedTx);
      }
    } else {
      // --- ADDING NEW TRANSACTION LOGIC ---
      if (_paymentType == PaymentType.oneOff) {
        await controller.addOneOffPayment(
          amount: _amount, itemName: _itemNameController.text, date: _selectedDate!,
          category: _selectedCategory!, store: _storeController.text, isWalleted: _isWalleted,
        );
      } else { // Recurring
        
        // 1. Calculate the monthly value of the new payment
        double monthlyIncrease = 0;
        switch (_recurrence) {
          case RecurrencePeriod.daily: monthlyIncrease = _amount * 30.44; break;
          case RecurrencePeriod.weekly: monthlyIncrease = _amount * 4.33; break;
          case RecurrencePeriod.monthly: monthlyIncrease = _amount; break;
          case RecurrencePeriod.yearly: monthlyIncrease = _amount / 12; break;
        }

        // 2. Show confirmation dialog and exit if cancelled
        final bool? confirmed = await _showBudgetConfirmationDialog(monthlyIncrease);
        if (confirmed != true) {
          return; // User cancelled
        }

        // 3. Add the recurring payment
        await controller.addRecurringPayment(
          amount: _amount, paymentName: _paymentNameController.text, payee: _payeeController.text,
          startDate: _selectedDate!, endDate: _endDate, category: _selectedCategory!,
          recurrence: _recurrence, recurrenceFrequency: _recurrenceFrequency,
          iconCodePoint: _selectedIcon?.codePoint, iconFontFamily: _selectedIcon?.fontFamily, iconFontPackage: _selectedIcon?.fontPackage,
        );
        
        // 4. Update the category's budget
        final newTotalBudget = _selectedCategory!.budgetAmount + monthlyIncrease;
        final updatedCategory = _selectedCategory!.copyWith(budgetAmount: newTotalBudget);
        await controller.updateCategory(
          id: updatedCategory.id,
          name: updatedCategory.name,
          budgetAmount: updatedCategory.budgetAmount,
          walletAmount: updatedCategory.walletAmount,
          icon: updatedCategory.icon,
          color: updatedCategory.color,
        );
      }
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoryListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: CustomToggle(
                  options: const ['One-Off', 'Recurring'],
                  selectedValue: _paymentType == PaymentType.oneOff ? 'One-Off' : 'Recurring',
                  onChanged: (value) {
                    setState(() {
                      _paymentType = value == 'One-Off' ? PaymentType.oneOff : PaymentType.recurring;
                    });
                  },
                ),
              ),
            ),
          
          if (_paymentType == PaymentType.oneOff) ...[
            CustomTextInputField(controller: _itemNameController, labelText: 'Item Name'),
            const SizedBox(height: 16),
            CurrencyInputField(
              labelText: 'Amount', initialValue: _amount,
              textStyle: const TextStyle(fontWeight: FontWeight.w400),
              onChanged: (value) => _amount = value,
            ),
            const SizedBox(height: 16),
            CustomTextInputField(controller: _storeController, labelText: 'Store (Optional)'),
            const SizedBox(height: 8),
            CategorySelectorField(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) => setState(() => _selectedCategory = category),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DateSelectorField(
                    labelText: 'Date', selectedDate: _selectedDate,
                    onDateSelected: (date) => setState(() => _selectedDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                WalletToggle(
                  isWalleted: _isWalleted,
                  onChanged: (value) => setState(() => _isWalleted = value),
                ),
              ],
            ),
          ] else ...[
            CustomTextInputField(controller: _paymentNameController, labelText: 'Payment Name'),
            const SizedBox(height: 16),
            CurrencyInputField(
              labelText: 'Amount', initialValue: _amount,
              textStyle: const TextStyle(fontWeight: FontWeight.w400),
              onChanged: (value) => _amount = value,
            ),
            const SizedBox(height: 16),
            CustomTextInputField(controller: _payeeController, labelText: 'Payee'),
            const SizedBox(height: 8),
            CategorySelectorField(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) => setState(() => _selectedCategory = category),
            ),
            const SizedBox(height: 16),
            IconPickerField(
              labelText: 'Custom Icon (Optional)', selectedIcon: _selectedIcon,
              onIconSelected: (icon) => setState(() => _selectedIcon = icon),
            ),
            const SizedBox(height: 16),
            PeriodSelectorField(
              frequency: _recurrenceFrequency, period: _recurrence,
              onFrequencyChanged: (frequency) => setState(() => _recurrenceFrequency = frequency),
              onPeriodChanged: (period) => setState(() => _recurrence = period),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DateSelectorField(
                    labelText: 'Start Date', selectedDate: _selectedDate,
                    layout: DateSelectorLayout.vertical,
                    onDateSelected: (date) => setState(() => _selectedDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DateSelectorField(
                    labelText: 'End Date', selectedDate: _endDate,
                    layout: DateSelectorLayout.vertical,
                    onDateSelected: (date) => setState(() => _endDate = date),
                    allowFutureDates: true,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                fixedSize: const Size(200, 50), 
              ),
              child: Text(isEditing ? 'Save Changes' : 'Save Payment'),
            ),
          ),
        ],
      ),
    );
  }
}