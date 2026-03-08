// lib/src/features/categories/presentation/screens/manage_category_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/enums/budget_enum.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/overall_budget_summary_provider.dart';
import 'package:budgit/src/features/categories/presentation/widgets/income_context_bar.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

// Controls
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/widgets/recurring_controls.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/add_transaction_controller.dart';

// UI Utils
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/utils/palette_generator.dart';
import 'package:budgit/src/utils/date_utils.dart';

class ManageCategoryScreen extends ConsumerStatefulWidget {
  const ManageCategoryScreen({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<ManageCategoryScreen> createState() =>
      _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends ConsumerState<ManageCategoryScreen> {
  String _activeTab = 'Variable';
  bool _canPop = false;

  Future<void> _saveChanges() async {
    final notifier = ref.read(
      manageCategoryControllerProvider(widget.category.id).notifier,
    );
    await notifier.saveChanges();

    if (mounted) {
      setState(() => _canPop = true);
      Future.microtask(() {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  Future<void> _deleteCategory() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete the "${widget.category.name}" category? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final controller = ref.read(addTransactionControllerProvider.notifier);
      await controller.deleteCategory(widget.category.id);

      if (mounted) {
        setState(() => _canPop = true);
        Future.microtask(() {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  String _periodToString(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  BudgetPeriod _stringToPeriod(String val) {
    switch (val) {
      case 'Weekly':
        return BudgetPeriod.weekly;
      case 'Yearly':
        return BudgetPeriod.yearly;
      case 'Monthly':
      default:
        return BudgetPeriod.monthly;
    }
  }

  String _getUnitString(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'per week';
      case BudgetPeriod.monthly:
        return 'per month';
      case BudgetPeriod.yearly:
        return 'per year';
    }
  }

  // --- THE FIX: Round the floating point math to strictly 2 decimal places ---
  double _scaleValue(double monthlyValue, BudgetPeriod period) {
    double rawValue;
    switch (period) {
      case BudgetPeriod.weekly:
        rawValue = monthlyValue / AppDateUtils.weeksPerMonth;
        break;
      case BudgetPeriod.monthly:
        rawValue = monthlyValue;
        break;
      case BudgetPeriod.yearly:
        rawValue = monthlyValue * 12;
        break;
    }
    return (rawValue * 100).roundToDouble() / 100;
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(
      manageCategoryControllerProvider(widget.category.id),
    );
    final notifier = ref.read(
      manageCategoryControllerProvider(widget.category.id).notifier,
    );
    final summaryAsync = ref.watch(overallBudgetSummaryProvider);
    final allCategoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    final palette = generateSpendingPalette(Color(widget.category.colorValue));
    final varColor = palette.wallet;
    final recColor = palette.recurring;

    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final state = ref
            .read(manageCategoryControllerProvider(widget.category.id))
            .value;

        final hasChanges =
            state != null && state.totalBudget != widget.category.budgetAmount;

        if (!hasChanges) {
          setState(() => _canPop = true);
          Future.microtask(() {
            if (mounted) Navigator.of(context).pop();
          });
          return;
        }

        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. What would you like to do?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('discard'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: const Text('Don\'t Save'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('save'),
                child: const Text('Save'),
              ),
            ],
          ),
        );

        if (result == 'save') {
          await _saveChanges();
        } else if (result == 'discard') {
          setState(() => _canPop = true);
          Future.microtask(() {
            if (mounted) Navigator.of(context).pop();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Budget'),
          actions: [
            stateAsync.maybeWhen(
              data: (_) => TextButton(
                onPressed: _saveChanges,
                child: const Text('Save'),
              ),
              orElse: () => const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        ),
        body: stateAsync.when(
          data: (state) {
            final unitString = _getUnitString(state.budgetPeriod);
            final displayVariable = _scaleValue(
              state.variableBudget,
              state.budgetPeriod,
            );
            final displayRecurring = _scaleValue(
              state.recurringSum,
              state.budgetPeriod,
            );

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(
                                  widget.category.colorValue,
                                ),
                                child: Icon(
                                  IconData(
                                    widget.category.iconCodePoint,
                                    fontFamily: widget.category.iconFontFamily,
                                    fontPackage:
                                        widget.category.iconFontPackage,
                                  ),
                                  color: theme.colorScheme.surface,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  widget.category.name,
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 32,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          CustomToggle(
                            options: const ['Weekly', 'Monthly', 'Yearly'],
                            selectedValue: _periodToString(state.budgetPeriod),
                            width: MediaQuery.of(context).size.width - 48,
                            onChanged: (val) {
                              notifier.setBudgetPeriod(_stringToPeriod(val));
                            },
                          ),

                          const SizedBox(height: 32),

                          _GiantBudgetInput(
                            value: state.displayTotalBudget,
                            onChanged: (newAmount) {
                              notifier.setTotalBudget(newAmount);
                            },
                          ),
                          Text(
                            unitString,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 40),

                          _LinearBudgetGauge(
                            state: state,
                            varColor: varColor,
                            recColor: recColor,
                            activeTab: _activeTab,
                            displayVariable: displayVariable,
                            displayRecurring: displayRecurring,
                            unitString: unitString,
                          ),

                          const SizedBox(height: 32),

                          CustomToggle(
                            options: const ['Variable', 'Recurring'],
                            selectedValue: _activeTab,
                            width: MediaQuery.of(context).size.width - 48,
                            onChanged: (val) {
                              setState(() {
                                _activeTab = val;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            child: _activeTab == 'Variable'
                                ? _VariableBudgetInputView(
                                    key: const ValueKey('variable_tab'),
                                    state: state,
                                    notifier: notifier,
                                    displayVariable: displayVariable,
                                    displayRecurring: displayRecurring,
                                    unitString: unitString,
                                  )
                                : RecurringControls(
                                    key: const ValueKey('recurring_tab'),
                                    state: state,
                                    notifier: notifier,
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: summaryAsync.when(
                        data: (summary) => allCategoriesAsync.when(
                          data: (allCategories) => IncomeContextBar(
                            summary: summary,
                            allCategories: allCategories,
                            thisCategory: state.initialCategory,
                            activePeriod: state.budgetPeriod,
                          ),
                          loading: () => const SizedBox(height: 80),
                          error: (e, s) => const SizedBox(
                            height: 80,
                            child: Center(
                              child: Text('Error loading categories'),
                            ),
                          ),
                        ),
                        loading: () => const SizedBox(height: 80),
                        error: (e, s) => const SizedBox(
                          height: 80,
                          child: Center(child: Text('Error loading summary')),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _deleteCategory,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete Category'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(
                              color: theme.colorScheme.error.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _GiantBudgetInput extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _GiantBudgetInput({required this.value, required this.onChanged});

  @override
  State<_GiantBudgetInput> createState() => _GiantBudgetInputState();
}

class _GiantBudgetInputState extends State<_GiantBudgetInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  final NumberFormat _formatter = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatter.format(widget.value));
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final cleanText = _controller.text.replaceAll(',', '');
        final val = double.tryParse(cleanText) ?? 0.0;
        widget.onChanged(val);
        _controller.text = _formatter.format(val);
      } else {
        _controller.text = _controller.text.replaceAll(',', '');
      }
    });
  }

  @override
  void didUpdateWidget(covariant _GiantBudgetInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = _formatter.format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '\$',
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        IntrinsicWidth(
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onFieldSubmitted: (value) {
              final cleanText = value.replaceAll(',', '');
              final val = double.tryParse(cleanText) ?? 0.0;
              widget.onChanged(val);
              _controller.text = _formatter.format(val);
            },
          ),
        ),
      ],
    );
  }
}

class _LinearBudgetGauge extends StatelessWidget {
  final ManageCategoryState state;
  final Color varColor;
  final Color recColor;
  final String activeTab;
  final double displayVariable;
  final double displayRecurring;
  final String unitString;

  const _LinearBudgetGauge({
    required this.state,
    required this.varColor,
    required this.recColor,
    required this.activeTab,
    required this.displayVariable,
    required this.displayRecurring,
    required this.unitString,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0.00', 'en_US');

    final double total = state.totalBudget > 0 ? state.totalBudget : 1.0;
    final double recurringPercent = (state.recurringSum / total).clamp(
      0.0,
      1.0,
    );
    final double variablePercent = (state.variableBudget / total).clamp(
      0.0,
      1.0,
    );

    final int varFlex = (variablePercent * 1000).toInt();
    final int recFlex = (recurringPercent * 1000).toInt();
    final int emptyFlex = 1000 - (varFlex + recFlex);

    const double activeHeight = 28.0;
    const double inactiveHeight = 12.0;

    return Column(
      children: [
        SizedBox(
          height: activeHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (varFlex > 0)
                Expanded(
                  flex: varFlex,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    height: activeTab == 'Variable'
                        ? activeHeight
                        : inactiveHeight,
                    decoration: BoxDecoration(
                      color: varColor,
                      borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(16),
                        right: recFlex == 0 && emptyFlex == 0
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),

              if (varFlex > 0 && recFlex > 0)
                Container(width: 4, color: theme.scaffoldBackgroundColor),

              if (recFlex > 0)
                Expanded(
                  flex: recFlex,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    height: activeTab == 'Recurring'
                        ? activeHeight
                        : inactiveHeight,
                    decoration: BoxDecoration(
                      color: recColor,
                      borderRadius: BorderRadius.horizontal(
                        right: emptyFlex == 0
                            ? const Radius.circular(16)
                            : Radius.zero,
                        left: varFlex == 0
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),

              if (emptyFlex > 0)
                Expanded(
                  flex: emptyFlex,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: inactiveHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.horizontal(
                        right: const Radius.circular(16),
                        left: (varFlex == 0 && recFlex == 0)
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Variable: \$${formatter.format(displayVariable)} $unitString",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: varColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  "Recurring: \$${formatter.format(displayRecurring)} $unitString",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: recColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- RESTORED & FIXED: Original Currency Input View ---
class _VariableBudgetInputView extends StatefulWidget {
  final ManageCategoryState state;
  final ManageCategoryController notifier;
  final double displayVariable;
  final double displayRecurring;
  final String unitString;

  const _VariableBudgetInputView({
    super.key,
    required this.state,
    required this.notifier,
    required this.displayVariable,
    required this.displayRecurring,
    required this.unitString,
  });

  @override
  State<_VariableBudgetInputView> createState() =>
      _VariableBudgetInputViewState();
}

class _VariableBudgetInputViewState extends State<_VariableBudgetInputView> {
  late double _currentAmount;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.displayVariable;
  }

  @override
  void didUpdateWidget(covariant _VariableBudgetInputView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // --- THE CIRCUIT BREAKER ---
    // Only externally overwrite the text field if the value changed by more than 5 cents.
    // This completely stops the floating-point rounding loop from ruining your active typing!
    if ((widget.displayVariable - _currentAmount).abs() > 0.05) {
      _currentAmount = widget.displayVariable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CurrencyInputField(
                key: ValueKey('var_input_${widget.state.budgetPeriod}'),
                labelText: 'Amount',
                initialValue: _currentAmount,
                onChanged: (value) {
                  // Keep track of exactly what the user is typing to prevent the circuit breaker from tripping
                  _currentAmount = value;

                  widget.notifier.setTotalBudget(
                    value + widget.displayRecurring,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Text(
              widget.unitString,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
