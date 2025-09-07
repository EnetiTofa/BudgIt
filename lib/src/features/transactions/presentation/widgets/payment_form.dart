import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_dropdown_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

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
  DateTime? _selectedDate; // Correct variable name
  DateTime? _endDate;
  RecurrencePeriod _recurrence = RecurrencePeriod.monthly;
  bool _isWalleted = false;

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
      }
    } else {
      _selectedDate = ref.read(clockProvider).now();
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

  Future<void> _selectDate(BuildContext context, {bool isStartDate = true}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _selectedDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_amount <= 0 || _selectedCategory == null || _selectedDate == null) {
      // Add validation feedback if needed
      return;
    }

    final controller = ref.read(addTransactionControllerProvider.notifier);
    
    if (isEditing) {
      // Logic for updating an existing transaction
      final originalTx = widget.initialTransaction!;
      if(originalTx is OneOffPayment) {
        final updatedTx = OneOffPayment(
          id: originalTx.id,
          notes: originalTx.notes,
          createdAt: originalTx.createdAt,
          amount: _amount,
          date: _selectedDate!,
          itemName: _itemNameController.text,
          store: _storeController.text,
          category: _selectedCategory!,
          isWalleted: _isWalleted,
        );
        controller.updateTransaction(updatedTx);
      } else if (originalTx is RecurringPayment) {
        final updatedTx = RecurringPayment(
          id: originalTx.id,
          notes: originalTx.notes,
          createdAt: originalTx.createdAt,
          amount: _amount,
          paymentName: _paymentNameController.text,
          payee: _payeeController.text,
          category: _selectedCategory!,
          recurrence: _recurrence,
          startDate: _selectedDate!,
          endDate: _endDate,
        );
        controller.updateTransaction(updatedTx);
      }
    } else {
      // Logic for adding a new transaction
      if (_paymentType == PaymentType.oneOff) {
        controller.addOneOffPayment(
              amount: _amount,
              itemName: _itemNameController.text,
              date: _selectedDate!,
              category: _selectedCategory!,
              store: _storeController.text,
              isWalleted: _isWalleted,
            );
      } else { // Recurring
        controller.addRecurringPayment(
              amount: _amount,
              paymentName: _paymentNameController.text,
              payee: _payeeController.text,
              startDate: _selectedDate!,
              endDate: _endDate,
              category: _selectedCategory!,
              recurrence: _recurrence,
            );
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoryListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (!isEditing) // Show toggle only when adding a new transaction
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
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
          
          if (_paymentType == PaymentType.oneOff) ...[
            CustomTextInputField(controller: _itemNameController, labelText: 'Item Name'),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDate == null ? 'Date' : DateFormat.yMd().format(_selectedDate!)),
              onPressed: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            CustomTextInputField(controller: _storeController, labelText: 'Store (Optional)'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Wallet Transaction'),
              value: _isWalleted,
              onChanged: (value) => setState(() => _isWalleted = value),
            ),
          ] else ...[
            CustomTextInputField(controller: _paymentNameController, labelText: 'Payment Name'),
            const SizedBox(height: 16),
            CustomTextInputField(controller: _payeeController, labelText: 'Payee'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null ? 'Start Date' : DateFormat.yMd().format(_selectedDate!)),
                    onPressed: () => _selectDate(context, isStartDate: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate == null ? 'End Date (Optional)' : DateFormat.yMd().format(_endDate!)),
                    onPressed: () => _selectDate(context, isStartDate: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDropdownField<RecurrencePeriod>(
              labelText: 'Repeats',
              value: _recurrence,
              onChanged: (value) => setState(() => _recurrence = value!),
              items: RecurrencePeriod.values.map((period) => DropdownMenuItem(
                value: period,
                child: Text(period.toString().split('.').last),
              )).toList(),
            ),
          ],
          
          const SizedBox(height: 16),
          CurrencyInputField(
            labelText: 'Amount',
            initialValue: _amount,
            onChanged: (value) => _amount = value,
          ),
          const SizedBox(height: 16),
          switch (categoriesAsyncValue) {
            AsyncLoading() => const CircularProgressIndicator(),
            AsyncError() => const Text('Could not load categories.'),
            AsyncData(:final value) => CustomDropdownField<Category>(
                labelText: 'Category',
                value: _selectedCategory,
                onChanged: (Category? newValue) => setState(() => _selectedCategory = newValue),
                items: value.map<DropdownMenuItem<Category>>((Category category) => DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                )).toList(),
              ),
            _ => const SizedBox.shrink(),
          },
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(isEditing ? 'Save Changes' : 'Save Payment'),
          ),
        ],
      ),
    );
  }
}