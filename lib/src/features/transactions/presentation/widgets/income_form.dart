import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/custom_text_input_field.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/common_widgets/icon_picker_field.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/period_selector_field.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/date_selector_field.dart'; // 1. Add the import

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
  IconData? _selectedIcon;

  final _sourceController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _endDate;
  RecurrencePeriod _recurrence = RecurrencePeriod.monthly;
  int _recurrenceFrequency = 1;

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
        _referenceController.text = tx.reference ?? '';
        _selectedIcon = IconData(tx.iconCodePoint, fontFamily: tx.iconFontFamily);
      } else if (tx is RecurringIncome) {
        _incomeType = IncomeType.recurring;
        _sourceController.text = tx.source;
        _amount = tx.amount;
        _selectedDate = tx.startDate;
        _endDate = tx.endDate;
        _recurrence = tx.recurrence;
        _recurrenceFrequency = tx.recurrenceFrequency;
        _referenceController.text = tx.reference ?? '';
        _selectedIcon = IconData(tx.iconCodePoint, fontFamily: tx.iconFontFamily);
      }
    } else {
      _selectedDate = ref.read(clockProvider).now();
      _selectedIcon = Icons.attach_money;
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final source = _sourceController.text;
    final reference = _referenceController.text;
    if (source.isEmpty || _amount <= 0 || _selectedDate == null || _selectedIcon == null) return;

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
          reference: reference.isEmpty ? null : reference,
          iconCodePoint: _selectedIcon!.codePoint,
          iconFontFamily: _selectedIcon!.fontFamily,
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
          recurrenceFrequency: _recurrenceFrequency,
          isAdvanced: tx.isAdvanced,
          reference: reference.isEmpty ? null : reference,
          iconCodePoint: _selectedIcon!.codePoint,
          iconFontFamily: _selectedIcon!.fontFamily,
        );
        controller.updateTransaction(updatedTx);
      }
    } else {
      if (_incomeType == IncomeType.oneOff) {
        controller.addOneOffIncome(
          amount: _amount, 
          source: source, 
          date: _selectedDate!,
          reference: reference.isEmpty ? null : reference,
          iconCodePoint: _selectedIcon!.codePoint,
          iconFontFamily: _selectedIcon!.fontFamily,
        );
      } else {
        controller.addRecurringIncome(
          amount: _amount,
          source: source,
          startDate: _selectedDate!,
          endDate: _endDate,
          recurrence: _recurrence,
          recurrenceFrequency: _recurrenceFrequency,
          reference: reference.isEmpty ? null : reference,
          iconCodePoint: _selectedIcon!.codePoint,
          iconFontFamily: _selectedIcon!.fontFamily,
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
              child: Center(
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
            ),
          
          CustomTextInputField(controller: _sourceController, labelText: 'Source (e.g., Salary)'),
          const SizedBox(height: 16),
          CurrencyInputField(
            labelText: 'Amount',
            initialValue: _amount,
            onChanged: (value) => _amount = value,
          ),
          const SizedBox(height: 16),
          CustomTextInputField(controller: _referenceController, labelText: 'Reference (Optional)'),
          const SizedBox(height: 16),
          IconPickerField(
            selectedIcon: _selectedIcon,
            onIconSelected: (icon) {
              setState(() {
                _selectedIcon = icon;
              });
            },
          ),
          const SizedBox(height: 16),

          if (_incomeType == IncomeType.recurring) ...[
            // 2. Replace recurring date buttons
            PeriodSelectorField(
              frequency: _recurrenceFrequency,
              period: _recurrence,
              onFrequencyChanged: (frequency) {
                setState(() {
                  _recurrenceFrequency = frequency;
                });
              },
              onPeriodChanged: (period) {
                setState(() {
                  _recurrence = period;
                });
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
                    onDateSelected: (date) => setState(() => _selectedDate = date),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DateSelectorField(
                    labelText: 'End Date',
                    selectedDate: _endDate,
                    layout: DateSelectorLayout.vertical,
                    onDateSelected: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
          ] else ... [
            // 3. Replace one-off date button
            DateSelectorField(
              labelText: 'Date',
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
          ],
          
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                fixedSize: const Size(250, 50),
              ),
              child: Text(isEditing ? 'Save Changes' : 'Save Income'),
            ),
          ),
        ],
      ),
    );
  }
}