// lib/src/features/settings/presentation/feedback_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _feedbackType = 'Bug';

  // --- NEW: Store multiple selections in a Map (Key: Name, Value: Path) ---
  final Map<String, String> _selectedComponents = {};

  final Map<String, Map<String, String>> _appComponents = {
    'Common Widgets': {
      'Amount Slider Card': 'lib/src/common_widgets/amount_slider_card.dart',
      'Color Picker Field': 'lib/src/common_widgets/color_picker_field.dart',
      'Currency Input Field':
          'lib/src/common_widgets/currency_input_field.dart',
      'Custom Dropdown Field':
          'lib/src/common_widgets/custom_dropdown_field.dart',
      'Custom Text Input Field':
          'lib/src/common_widgets/custom_text_input_field.dart',
      'Custom Toggle': 'lib/src/common_widgets/custom_toggle.dart',
      'Customizer Card': 'lib/src/common_widgets/customizer_card.dart',
      'Date Selector Field': 'lib/src/common_widgets/date_selector_field.dart',
      'General Search Bar': 'lib/src/common_widgets/general_search_bar.dart',
      'Icon Picker Field': 'lib/src/common_widgets/icon_picker_field.dart',
      'Pulsing Button': 'lib/src/common_widgets/pulsing_button.dart',
      'Summary Card Base': 'lib/src/common_widgets/summary_card_base.dart',
      'Summary Stat Card': 'lib/src/common_widgets/summary_stat_card.dart',
      'Swipable Page View': 'lib/src/common_widgets/swipable_page_view.dart',
    },
    'Budget Hub': {
      'Budget Hub Screen': 'lib/src/features/budget_hub/budget_hub_screen.dart',
      'Add Transfer Screen':
          'lib/src/features/budget_hub/presentation/screens/add_transfer_screen.dart',
      'Edit Transfer Screen':
          'lib/src/features/budget_hub/presentation/screens/edit_transfer_screen.dart',
      'Monthly Screen':
          'lib/src/features/budget_hub/presentation/screens/monthly_screen.dart',
      'Weekly Screen':
          'lib/src/features/budget_hub/presentation/screens/weekly_screen.dart',
      'Active Transfers Section':
          'lib/src/features/budget_hub/presentation/widgets/active_transfers_section.dart',
      'Amount Slider Field':
          'lib/src/features/budget_hub/presentation/widgets/amount_slider_field.dart',
      'Budget Card':
          'lib/src/features/budget_hub/presentation/widgets/budget_card.dart',
      'Budget List':
          'lib/src/features/budget_hub/presentation/widgets/budget_list.dart',
      'Budget Timeline':
          'lib/src/features/budget_hub/presentation/widgets/budget_timeline.dart',
      'Category Detail View':
          'lib/src/features/budget_hub/presentation/widgets/category_detail_view.dart',
      'Category Ring Painter':
          'lib/src/features/budget_hub/presentation/widgets/category_ring_painter.dart',
      'Daily Spending Gauges':
          'lib/src/features/budget_hub/presentation/widgets/daily_spending_gauges.dart',
      'Filtered Category Selector':
          'lib/src/features/budget_hub/presentation/widgets/filtered_category_selector.dart',
      'Month Selector':
          'lib/src/features/budget_hub/presentation/widgets/month_selector.dart',
      'Monthly Transaction Calendar':
          'lib/src/features/budget_hub/presentation/widgets/monthly_transaction_calendar.dart',
      'Recent Transactions List':
          'lib/src/features/budget_hub/presentation/widgets/recent_transactions_list.dart',
      'Segmented Linear Gauge':
          'lib/src/features/budget_hub/presentation/widgets/segmented_linear_gauge.dart',
      'Spending Speedometer':
          'lib/src/features/budget_hub/presentation/widgets/spending_speedometer.dart',
      'Transfer Composition Bar':
          'lib/src/features/budget_hub/presentation/widgets/transfer_composition_bar.dart',
      'Transfer Form':
          'lib/src/features/budget_hub/presentation/widgets/transfer_form.dart',
      'Unified Budget Gauge':
          'lib/src/features/budget_hub/presentation/widgets/unified_budget_gauge.dart',
      'Week Selector':
          'lib/src/features/budget_hub/presentation/widgets/week_selector.dart',
      'Weekly Bar Chart':
          'lib/src/features/budget_hub/presentation/widgets/weekly_bar_chart.dart',
      'Weekly Category Card':
          'lib/src/features/budget_hub/presentation/widgets/weekly_category_card.dart',
      'Weekly Category Detail View':
          'lib/src/features/budget_hub/presentation/widgets/weekly_category_detail_view.dart',
      'Weekly Category Summary Card':
          'lib/src/features/budget_hub/presentation/widgets/weekly_category_summary_card.dart',
      'Weekly Pattern Chart':
          'lib/src/features/budget_hub/presentation/widgets/weekly_pattern_chart.dart',
      'Weekly Speedometer':
          'lib/src/features/budget_hub/presentation/widgets/weekly_speedometer.dart',
    },
    'Categories': {
      'Add Category Screen':
          'lib/src/features/categories/presentation/screens/add_category_screen.dart',
      'Edit Basic Category Screen':
          'lib/src/features/categories/presentation/screens/edit_basic_category_screen.dart',
      'Manage Categories Screen':
          'lib/src/features/categories/presentation/screens/manage_categories_screen.dart',
      'Manage Category Screen':
          'lib/src/features/categories/presentation/screens/manage_category_screen.dart',
      'Add Recurring Payment Form':
          'lib/src/features/categories/presentation/widgets/add_recurring_payment_form.dart',
      'Category Selector Field':
          'lib/src/features/categories/presentation/widgets/category_selector_field.dart',
      'Income Context Bar':
          'lib/src/features/categories/presentation/widgets/income_context_bar.dart',
      'Interactive Budget Gauge':
          'lib/src/features/categories/presentation/widgets/interactive_budget_gauge.dart',
      'Recurring Controls':
          'lib/src/features/categories/presentation/widgets/recurring_controls.dart',
      'Total Budget Controls':
          'lib/src/features/categories/presentation/widgets/total_budget_controls.dart',
    },
    'Check In': {
      'Check In Screen':
          'lib/src/features/check_in/presentation/screens/check_in_screen.dart',
      'Streak Ended Screen':
          'lib/src/features/check_in/presentation/screens/streak_ended_screen.dart',
      'Streak Screen':
          'lib/src/features/check_in/presentation/screens/streak_screen.dart',
      'Check In Transfer Page':
          'lib/src/features/check_in/presentation/pages/check_in_transfer_page.dart',
      'Confirmation Page':
          'lib/src/features/check_in/presentation/pages/confirmation_page.dart',
      'Debt Rollover Page':
          'lib/src/features/check_in/presentation/pages/debt_rollover_page.dart',
      'First Time Category Page':
          'lib/src/features/check_in/presentation/pages/first_time_category_page.dart',
      'First Time Confirmation Page':
          'lib/src/features/check_in/presentation/pages/first_time_confirmation_page.dart',
      'First Time Day Picker Page':
          'lib/src/features/check_in/presentation/pages/first_time_day_picker_page.dart',
      'First Time Income Page':
          'lib/src/features/check_in/presentation/pages/first_time_income_page.dart',
      'First Time Intro Page':
          'lib/src/features/check_in/presentation/pages/first_time_intro_page.dart',
      'First Time Monthly Info Page':
          'lib/src/features/check_in/presentation/pages/first_time_monthly_info_page.dart',
      'First Time Prorate Page':
          'lib/src/features/check_in/presentation/pages/first_time_prorate_page.dart',
      'First Time Weekly Log Page':
          'lib/src/features/check_in/presentation/pages/first_time_weekly_log_page.dart',
      'Monthly Debt Acknowledgment Page':
          'lib/src/features/check_in/presentation/pages/monthly_debt_acknowledgment_page.dart',
      'Monthly Review Page':
          'lib/src/features/check_in/presentation/pages/monthly_review_page.dart',
      'Rollover Save Page':
          'lib/src/features/check_in/presentation/pages/rollover_save_page.dart',
      'Smart Proposals Page':
          'lib/src/features/check_in/presentation/pages/smart_proposals_page.dart',
      'Transaction Review Page':
          'lib/src/features/check_in/presentation/pages/transaction_review_page.dart',
      'Transition Page':
          'lib/src/features/check_in/presentation/pages/transition_page.dart',
      'Rollover Card':
          'lib/src/features/check_in/presentation/widgets/rollover_card.dart',
    },
    'Dashboard': {
      'Dashboard Screen':
          'lib/src/features/dashboard/presentation/screens/dashboard.dart',
      'Dashboard Card':
          'lib/src/features/dashboard/presentation/widgets/dashboard_card.dart',
      'Dashboard Weekly Gauge':
          'lib/src/features/dashboard/presentation/widgets/dashboard_weekly_gauge.dart',
      'Dashboard Weekly Widget':
          'lib/src/features/dashboard/presentation/widgets/dashboard_weekly_widget.dart',
      'Notices Widget':
          'lib/src/features/dashboard/presentation/widgets/notices_widget.dart',
      'Streak Counter Widget':
          'lib/src/features/dashboard/presentation/widgets/streak_counter_widget.dart',
    },
    'Transaction Hub': {
      'Transaction Hub Screen':
          'lib/src/features/transaction_hub/transaction_hub_screen.dart',
      'Add Income Screen':
          'lib/src/features/transaction_hub/transactions/presentation/screens/add_income_screen.dart',
      'Add Payment Screen':
          'lib/src/features/transaction_hub/transactions/presentation/screens/add_payment_screen.dart',
      'Edit Income Screen':
          'lib/src/features/transaction_hub/transactions/presentation/screens/edit_income_screen.dart',
      'Edit Payment Screen':
          'lib/src/features/transaction_hub/transactions/presentation/screens/edit_payment_screen.dart',
      'Recurring Screen':
          'lib/src/features/transaction_hub/transactions/presentation/screens/recurring_screen.dart',
      'Transaction Log Screen':
          'lib/src/features/transaction_hub/transactions/presentation/screens/transaction_log_screen.dart',
      'Filter Chip Bar':
          'lib/src/features/transaction_hub/transactions/presentation/widgets/filter_chip_bar.dart',
      'Filter Dropdown':
          'lib/src/features/transaction_hub/transactions/presentation/widgets/filter_dropdown.dart',
      'Income Form':
          'lib/src/features/transaction_hub/transactions/presentation/widgets/income_form.dart',
      'Payment Form':
          'lib/src/features/transaction_hub/transactions/presentation/widgets/payment_form.dart',
      'Period Selector Field':
          'lib/src/features/transaction_hub/transactions/presentation/widgets/period_selector_field.dart',
      'Recurring Transaction Card':
          'lib/src/features/transaction_hub/transactions/presentation/widgets/recurring_transaction_card.dart',
      'Sort Dropdown':
          'lib/src/features/transaction_hub/transactions/presentation/widgets/sort_dropdown.dart',
    },
    'Settings & Menu': {
      'Menu Screen': 'lib/src/features/menu/presentation/menu_screen.dart',
      'Manage Payees Screen':
          'lib/src/features/settings/presentation/manage_payees_screen.dart',
      'Theme Selector Screen':
          'lib/src/features/settings/presentation/theme_selector_screen.dart',
      'Time Machine Screen':
          'lib/src/features/debug/presentation/time_machine_screen.dart',
    },
  };

  void _showComponentPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // --- NEW: StatefulBuilder allows the bottom sheet to update its own checkboxes ---
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Components',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Done',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _appComponents.keys.length,
                        itemBuilder: (context, index) {
                          final groupName = _appComponents.keys.elementAt(
                            index,
                          );
                          final components = _appComponents[groupName]!;

                          return ExpansionTile(
                            title: Text(
                              groupName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: components.entries.map((entry) {
                              final isSelected = _selectedComponents
                                  .containsKey(entry.key);

                              return CheckboxListTile(
                                title: Text(entry.key),
                                subtitle: Text(
                                  entry.value.split('/').last,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                value: isSelected,
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                onChanged: (bool? checked) {
                                  // Update the Bottom Sheet UI
                                  setModalState(() {
                                    if (checked == true) {
                                      _selectedComponents[entry.key] =
                                          entry.value;
                                    } else {
                                      _selectedComponents.remove(entry.key);
                                    }
                                  });
                                  // Update the Main Screen UI behind it
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  Future<void> _sendEmail() async {
    final typeLabel = _feedbackType == 'Bug' ? 'Bug Report' : 'Feature Request';

    // Format the subject line based on how many items were selected
    final subjectSuffix = _selectedComponents.isEmpty
        ? 'General / Not Sure'
        : _selectedComponents.length == 1
        ? _selectedComponents.keys.first
        : '${_selectedComponents.length} Components';

    final subject = 'Budgit Beta: $typeLabel - $subjectSuffix';

    // Format the component list to be highly scannable
    final componentPathsList = _selectedComponents.isEmpty
        ? 'None Selected'
        : _selectedComponents.entries
              .map((e) => '• ${e.key}\n  File: ${e.value}')
              .join('\n\n');

    // Added visual dividers and extra spacing for readability
    final body =
        '''
Hi Budgit Team,

I am submitting a $_feedbackType.


DESCRIPTION:

[Please type your message here. What happened? What did you expect?]






AFFECTED COMPONENTS:

$componentPathsList



SCREENSHOTS:

[Please attach any screenshots to this email]
''';

    // THE FIX: Some email clients ignore standard newlines (\n).
    // Converting them to CRLF (\r\n) forces Apple Mail, Gmail, etc., to respect the spacing.
    final robustBody = body.replaceAll('\n', '\r\n');

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'developer.boostedmobile@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': robustBody,
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      if (mounted) Navigator.pop(context); // Go back after sending
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the email client. Please ensure you have an email app installed.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Bug / Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What would you like to report?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CustomToggle(
                options: const ['Bug', 'Suggestion'],
                selectedValue: _feedbackType,
                onChanged: (value) => setState(() => _feedbackType = value),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Which part of the app is this regarding?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // --- NEW: Visual list of selected components (Chips) ---
            if (_selectedComponents.isNotEmpty) ...[
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedComponents.keys.map((name) {
                  return Chip(
                    label: Text(name, style: const TextStyle(fontSize: 13)),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    deleteIconColor: theme.colorScheme.error,
                    onDeleted: () {
                      setState(() {
                        _selectedComponents.remove(name);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Selector Button
            InkWell(
              onTap: _showComponentPicker,
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedComponents.isEmpty
                          ? Icons.widgets_outlined
                          : Icons.add_circle_outline,
                      color: _selectedComponents.isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedComponents.isEmpty
                            ? 'Select Screen or Widget'
                            : 'Add another component...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _selectedComponents.isEmpty
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                          fontWeight: _selectedComponents.isEmpty
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.mail_outline),
              label: const Text('Continue to Email'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'This will open your default email app with a pre-filled template.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
