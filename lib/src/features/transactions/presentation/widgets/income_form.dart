import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_dropdown_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/utils/clock_provider.dart';

enum IncomeType { oneOff, recurring }

class IncomeForm extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;
  const IncomeForm({super.key, this.initialTransaction});

  @override
  ConsumerState<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends ConsumerState<IncomeForm> {
  IncomeType _incomeType = IncomeType.oneOff;
  double _amount = 0.0;

  final _sourceController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _endDate;
  RecurrencePeriod _recurrence = RecurrencePeriod.monthly;

  bool get isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final tx = widget.initialTransaction!;
      if (tx is OneOffIncome) {
        _incomeType = IncomeType.oneOff;
        _sourceController.text = tx.source;
        _amount = tx.amount;
        _selectedDate = tx.date;
      } else if (tx is RecurringIncome) {
        _incomeType = IncomeType.recurring;
        _sourceController.text = tx.source;
        _amount = tx.amount;
        _selectedDate = tx.startDate;
        _endDate = tx.endDate;
        _recurrence = tx.recurrence;
      }
    } else {
      _selectedDate = ref.read(clockProvider).now();
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
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
    final source = _sourceController.text;
    if (source.isEmpty || _amount <= 0 || _selectedDate == null) return;

    final controller = ref.read(addTransactionControllerProvider.notifier);
    
    if (isEditing) {
      final tx = widget.initialTransaction!;
      if (tx is OneOffIncome) {
        final updatedTx = OneOffIncome(
          id: tx.id,
          notes: tx.notes,
          createdAt: tx.createdAt,
          amount: _amount,
          date: _selectedDate!,
          source: source,
          isAdvanced: tx.isAdvanced,
        );
        controller.updateTransaction(updatedTx);
      } else if (tx is RecurringIncome) {
        final updatedTx = RecurringIncome(
          id: tx.id,
          notes: tx.notes,
          createdAt: tx.createdAt,
          amount: _amount,
          source: source,
          startDate: _selectedDate!,
          endDate: _endDate,
          recurrence: _recurrence,
          isAdvanced: tx.isAdvanced,
        );
        controller.updateTransaction(updatedTx);
      }
    } else {
      if (_incomeType == IncomeType.oneOff) {
        controller.addOneOffIncome(amount: _amount, source: source, date: _selectedDate!);
      } else {
        controller.addRecurringIncome(
          amount: _amount,
          source: source,
          startDate: _selectedDate!,
          endDate: _endDate,
          recurrence: _recurrence,
        );
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (!isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: CustomToggle(
                options: const ['One-Off', 'Recurring'],
                selectedValue: _incomeType == IncomeType.oneOff ? 'One-Off' : 'Recurring',
                onChanged: (value) {
                  setState(() {
                    _incomeType = value == 'One-Off' ? IncomeType.oneOff : IncomeType.recurring;
                  });
                },
              ),
            ),
          
          CustomTextInputField(controller: _sourceController, labelText: 'Source (e.g., Salary)'),
          const SizedBox(height: 16),
          CurrencyInputField(
            labelText: 'Amount',
            initialValue: _amount,
            onChanged: (value) => _amount = value,
          ),
          const SizedBox(height: 16),
          
          if (_incomeType == IncomeType.recurring) ...[
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
          ] else ... [
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDate == null ? 'Date' : DateFormat.yMd().format(_selectedDate!)),
              onPressed: () => _selectDate(context, isStartDate: true),
            ),
          ],
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(isEditing ? 'Save Changes' : 'Save Income'),
          ),
        ],
      ),
    );
  }
}