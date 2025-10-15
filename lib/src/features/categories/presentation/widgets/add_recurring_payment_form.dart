// lib/src/features/categories/presentation/widgets/add_recurring_payment_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/common_widgets/icon_picker_field.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/common_widgets/date_selector_field.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/period_selector_field.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/utils/clock_provider.dart';


class AddRecurringPaymentForm extends ConsumerStatefulWidget {
  final RecurringPayment? initialPayment;
  // --- MODIFIED ---
  // Category is now required as this form is only used for existing categories.
  final Category category;

  const AddRecurringPaymentForm({
    super.key, 
    this.initialPayment,
    required this.category,
  });

  @override
  ConsumerState<AddRecurringPaymentForm> createState() =>
      _AddRecurringPaymentFormState();
}

class _AddRecurringPaymentFormState
    extends ConsumerState<AddRecurringPaymentForm> {
  double _amount = 0.0;
  final _paymentNameController = TextEditingController();
  final _payeeController = TextEditingController();
  final _amountFocusNode = FocusNode();
  DateTime? _selectedDate;
  DateTime? _endDate;
  RecurrencePeriod _recurrence = RecurrencePeriod.monthly;
  int _recurrenceFrequency = 1;
  IconData? _selectedIcon;

  bool get isEditing => widget.initialPayment != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final p = widget.initialPayment!;
      _amount = p.amount;
      _paymentNameController.text = p.paymentName;
      _payeeController.text = p.payee;
      _selectedDate = p.startDate;
      _endDate = p.endDate;
      _recurrence = p.recurrence;
      _recurrenceFrequency = p.recurrenceFrequency;
      if (p.iconCodePoint != null) {
        _selectedIcon = IconData(
          p.iconCodePoint!,
          fontFamily: p.iconFontFamily,
        );
      }
    } else {
      _selectedDate = ref.read(clockProvider).now();
    }
  }

  @override
  void dispose() {
    _paymentNameController.dispose();
    _payeeController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    _amountFocusNode.unfocus();
    
    Future.delayed(const Duration(milliseconds: 50), () {
      // --- MODIFIED ---
      // Removed the old wizard logic. We now get the category directly from the widget.
      final category = widget.category;

      if (_amount <= 0 ||
          _paymentNameController.text.trim().isEmpty ||
          _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all required fields.')),
        );
        return;
      }

      final RecurringPayment result;
      if (isEditing) {
        result = RecurringPayment(
          id: widget.initialPayment!.id,
          notes: widget.initialPayment!.notes,
          createdAt: widget.initialPayment!.createdAt,
          amount: _amount,
          paymentName: _paymentNameController.text,
          payee: _payeeController.text,
          category: category,
          recurrence: _recurrence,
          recurrenceFrequency: _recurrenceFrequency,
          startDate: _selectedDate!,
          endDate: _endDate,
          iconCodePoint: _selectedIcon?.codePoint,
          iconFontFamily: _selectedIcon?.fontFamily,
        );
      } else {
        result = RecurringPayment(
          id: const Uuid().v4(),
          notes: '',
          createdAt: ref.read(clockProvider).now(),
          amount: _amount,
          paymentName: _paymentNameController.text,
          payee: _payeeController.text,
          category: category,
          recurrence: _recurrence,
          recurrenceFrequency: _recurrenceFrequency,
          startDate: _selectedDate!,
          endDate: _endDate,
          iconCodePoint: _selectedIcon?.codePoint,
          iconFontFamily: _selectedIcon?.fontFamily,
        );
      }

      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEditing ? 'Edit Payment' : 'Add Recurring Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextInputField(
                controller: _paymentNameController, labelText: 'Payment Name'),
            const SizedBox(height: 16),
            CurrencyInputField(
              labelText: 'Amount',
              initialValue: _amount,
              onChanged: (value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() { _amount = value; });
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextInputField(
                controller: _payeeController, labelText: 'Payee (Optional)'),
            const SizedBox(height: 16),
            IconPickerField(
              labelText: 'Custom Icon (Optional)',
              selectedIcon: _selectedIcon,
              onIconSelected: (icon) {
                setState(() { _selectedIcon = icon; });
              },
            ),
            const SizedBox(height: 16),
            PeriodSelectorField(
              frequency: _recurrenceFrequency,
              period: _recurrence,
              onFrequencyChanged: (frequency) {
                setState(() { _recurrenceFrequency = frequency; });
              },
              onPeriodChanged: (period) {
                setState(() { _recurrence = period; });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DateSelectorField(
                    labelText: 'Start Date',
                    selectedDate: _selectedDate,
                    layout: DateSelectorLayout.vertical,
                    onDateSelected: (date) {
                      setState(() { _selectedDate = date; });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DateSelectorField(
                    labelText: 'End Date',
                    selectedDate: _endDate,
                    layout: DateSelectorLayout.vertical,
                    onDateSelected: (date) {
                      setState(() { _endDate = date; });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 0,
                  fixedSize: const Size(200, 50),
                ),
                child: Text(isEditing ? 'Save Changes' : 'Add Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}