// lib/src/features/budget_hub/presentation/widgets/category_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/next_recurring_payment_provider.dart';
import 'package:budgit/src/common_widgets/summary_stat_card.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/monthly_projection_providers.dart';

class CategoryDetailView extends ConsumerStatefulWidget {
  const CategoryDetailView({
    super.key,
    required this.categoryId,
    required this.selectedMonth,
  });

  final String categoryId;
  final DateTime selectedMonth;

  @override
  ConsumerState<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends ConsumerState<CategoryDetailView> {
  @override
  Widget build(BuildContext context) {
    final categoryListAsync = ref.watch(categoryListProvider);

    return categoryListAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (cat) => cat.id == widget.categoryId,
          orElse: () => Category(
            id: '',
            name: '',
            iconCodePoint: 0,
            colorValue: 0,
            budgetAmount: 0,
          ),
        );

        if (category.id.isEmpty) {
          return const SizedBox.shrink();
        }

        // --- FETCH DATA ---
        final breakdown = ref.watch(
          categoryMonthlyBreakdownProvider(
            categoryId: category.id,
            month: widget.selectedMonth,
          ),
        );

        final nextPayment = ref.watch(
          nextRecurringPaymentProvider(categoryId: category.id),
        );
        // ---------------------------------

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Column(
          children: [
            // --- 1. Upcoming Transactions Card FIRST ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _DetailCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Transactions',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            if (nextPayment == null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'No upcoming recurring payments.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return Row(
                              children: [
                                // --- UPDATED ICON WIDGET ---
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(
                                    nextPayment.category.colorValue,
                                  ),
                                  child: Icon(
                                    IconData(
                                      nextPayment.iconCodePoint ??
                                          nextPayment.category.iconCodePoint,
                                      fontFamily:
                                          nextPayment.iconFontFamily ??
                                          nextPayment.category.iconFontFamily,
                                      fontPackage:
                                          nextPayment.iconFontPackage ??
                                          nextPayment.category.iconFontPackage,
                                    ),
                                    size: 24,
                                    color: nextPayment.category.contentColor,
                                  ),
                                ),
                                // ----------------------------
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        nextPayment.itemName,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(
                                          nextPayment.date,
                                        ),
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-\$${nextPayment.amount.toStringAsFixed(2)}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- 2. Summary Card SECOND ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SummaryStatCard(
                stats: [
                  SummaryStat(
                    value: '\$${breakdown.recurring.toStringAsFixed(2)}',
                    unit: 'Fixed',
                    title: 'Fixed Spending',
                    description: 'Spent on recurring bills.',
                  ),
                  SummaryStat(
                    value: '\$${breakdown.variable.toStringAsFixed(2)}',
                    unit: 'Variable',
                    title: 'Variable Spending',
                    description: 'Spent on day-to-day items.',
                  ),
                  SummaryStat(
                    value: '\$${breakdown.dailyAverage.toStringAsFixed(2)}',
                    unit: '/ day',
                    title: 'Daily Average',
                    description: 'Average total spending per day this month.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: child,
    );
  }
}
