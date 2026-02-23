// lib/src/features/dashboard/presentation/widgets/streak_counter_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
// ADDED IMPORT: Update this path if you placed the file elsewhere
import 'package:budgit/src/features/dashboard/presentation/providers/streak_calendar_state_provider.dart';

/// Provides the current focused month for navigation
final displayedMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = ref.watch(clockNotifierProvider).now();
  return DateTime(now.year, now.month);
});

/// Controls whether the calendar shows 1 week or the full month
final isCalendarExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class StreakCounterWidget extends ConsumerWidget {
  const StreakCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedMonth = ref.watch(displayedMonthProvider);
    final isExpanded = ref.watch(isCalendarExpandedProvider);
    final now = ref.watch(clockNotifierProvider).now();
    final today = DateTime(now.year, now.month, now.day);
    
    final streakCountAsync = ref.watch(checkInStreakProvider);
    final calendarStateAsync = ref.watch(streakCalendarStateProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow, 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. INTERNAL HEADER
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w700, 
                    fontSize: 18, 
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                _StreakFlame(
                  isHeated: true
                ),
                const SizedBox(width: 8),
                Text(
                  '${streakCountAsync.valueOrNull ?? 0} ${(streakCountAsync.valueOrNull ?? 0) == 1 ? 'week' : 'weeks'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Legend',
                  onPressed: () => _showLegendDialog(context),
                ),
              ],
            ),
          ),

          // 2. MONTH SELECTOR
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: isExpanded 
                ? _CalendarHeader(key: const ValueKey('nav_header'), displayedMonth: displayedMonth)
                : const SizedBox.shrink(key: ValueKey('no_header')),
          ),
          
          if (streakCountAsync.isLoading || calendarStateAsync.isLoading || settingsAsync.isLoading)
            const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          else 
            Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: isExpanded ? 0 : 12),
                    
                    _WeekdayLabels(checkInDayIndex: settingsAsync.valueOrNull?.getCheckInDay() ?? 5),
                    const SizedBox(height: 8),
                    
                    // 3. GRID WITH CLIPPING
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: ClipRect(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 20), 
                          child: _CalendarGrid(
                            displayedMonth: displayedMonth,
                            today: today,
                            calendarState: calendarStateAsync.value!,
                            streakCount: streakCountAsync.valueOrNull ?? 0,
                            isExpanded: isExpanded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36), 
                  ],
                ),

                // 4. TOGGLE ARROW
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => ref.read(isCalendarExpandedProvider.notifier).state = !isExpanded,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceContainerLow, 
                      padding: const EdgeInsets.only(top: 0, bottom: 12), 
                      child: Center(
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: isExpanded ? 0.5 : 0,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Streak Calendar Keys'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendItem(
                icon: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade800.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                label: 'Successful Check-in',
                description: 'You completed your budget check-in.',
              ),
              const SizedBox(height: 16),
              _LegendItem(
                icon: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'F', 
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                label: 'Check in Day',
                description: 'The day of the week set for check-ins.',
              ),
               const SizedBox(height: 16),
              _LegendItem(
                icon: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
                label: 'Today',
                description: "Today's date.",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String description;

  const _LegendItem({required this.icon, required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: SizedBox(width: 30, child: Center(child: icon)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                description, 
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarHeader extends ConsumerWidget {
  final DateTime displayedMonth;
  const _CalendarHeader({super.key, required this.displayedMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockNotifierProvider).now();
    final isCurrentMonth = displayedMonth.year == now.year && displayedMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => ref.read(displayedMonthProvider.notifier).state = 
                DateTime(displayedMonth.year, displayedMonth.month - 1),
            icon: const Icon(Icons.chevron_left, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('MMMM yyyy').format(displayedMonth),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: isCurrentMonth ? null : () => ref.read(displayedMonthProvider.notifier).state = 
                DateTime(displayedMonth.year, displayedMonth.month + 1),
            icon: Icon(
              Icons.chevron_right, 
              size: 20,
              color: isCurrentMonth ? Theme.of(context).disabledColor : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakFlame extends StatelessWidget {
  final bool isHeated;
  const _StreakFlame({required this.isHeated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isHeated)
          Icon(
            Icons.circle,
            color: Colors.yellow.shade600,
            size: 20,
          ),
        FaIcon(
          FontAwesomeIcons.fire,
          size: 24,
          color: isHeated
              ? Colors.orange.shade700
              : theme.colorScheme.secondary.withOpacity(0.5),
        ),
      ],
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  final int checkInDayIndex; 
  const _WeekdayLabels({required this.checkInDayIndex});

  @override
  Widget build(BuildContext context) {
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(labels.length, (index) {
        int currentWeekday = index == 0 ? 7 : index;
        final isCheckInDay = currentWeekday == checkInDayIndex;

        return Expanded(
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCheckInDay ? theme.colorScheme.surfaceContainer : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isCheckInDay ? theme.colorScheme.primary : theme.colorScheme.secondary,
                    fontWeight: isCheckInDay ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime today;
  final StreakCalendarState calendarState;
  final int streakCount;
  final bool isExpanded;

  const _CalendarGrid({
    required this.displayedMonth,
    required this.today,
    required this.calendarState,
    required this.streakCount,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final leadingSpaces = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final gridStart = firstDayOfMonth.subtract(Duration(days: leadingSpaces));

    final daysSinceGridStart = today.difference(gridStart).inDays;
    final currentWeekRowIndex = (daysSinceGridStart / 7).floor();
    
    final safeWeekIndex = currentWeekRowIndex < 0 ? 0 : currentWeekRowIndex;
    final weekStart = gridStart.add(Duration(days: safeWeekIndex * 7));

    final startPoint = isExpanded ? gridStart : weekStart;
    final itemCount = isExpanded ? 35 : 7; 

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4.0, 
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final date = startPoint.add(Duration(days: index));
        final strippedDate = DateTime(date.year, date.month, date.day);
        
        final isToday = DateUtils.isSameDay(strippedDate, today);
        final isSuccessfulDate = calendarState.successfulDatesStripped.contains(strippedDate);
        final isDifferentMonth = date.month != displayedMonth.month;
        
        final nextDate = strippedDate.add(const Duration(days: 1));
        final prevDate = strippedDate.subtract(const Duration(days: 1));
        
        final isPartOfStreak = calendarState.highlightedDates.contains(strippedDate);
        final hasNext = calendarState.highlightedDates.contains(nextDate) && date.weekday != 6; 
        final hasPrev = calendarState.highlightedDates.contains(prevDate) && date.weekday != 7; 
        
        // Grab the specific tip value for this date (if it exists)
        final tipValue = calendarState.streakTips[strippedDate];
        final isStreakTip = tipValue != null;

        return _CalendarDayCell(
          day: date.day,
          isToday: isToday,
          isSuccessfulDate: isSuccessfulDate,
          isPartOfStreak: isPartOfStreak,
          hasPrev: hasPrev,
          hasNext: hasNext,
          isStreakTip: isStreakTip,
          streakCount: tipValue ?? 0, // Pass the block's specific length
          isDifferentMonth: isDifferentMonth,
        );
      },
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSuccessfulDate;
  final bool isPartOfStreak;
  final bool hasPrev;
  final bool hasNext;
  final bool isStreakTip;
  final int streakCount;
  final bool isDifferentMonth;

  const _CalendarDayCell({
    required this.day,
    required this.isToday,
    required this.isSuccessfulDate,
    required this.isPartOfStreak,
    required this.hasPrev,
    required this.hasNext,
    required this.isStreakTip,
    required this.streakCount,
    required this.isDifferentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const double barHeight = 32.0;
    const double barRadius = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final center = constraints.maxWidth / 2;
        final double distToCircleEdge = center - barRadius;
        
        return Center(
          child: SizedBox(
            width: double.infinity, 
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (isPartOfStreak)
                  Positioned(
                    top: (40 - barHeight) / 2,
                    left: hasPrev ? 0.0 : distToCircleEdge,
                    right: hasNext ? 0.0 : distToCircleEdge,
                    height: barHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800.withOpacity(0.1),
                        borderRadius: BorderRadius.horizontal(
                          left: hasPrev ? Radius.zero : const Radius.circular(barRadius),
                          right: hasNext ? Radius.zero : const Radius.circular(barRadius),
                        ),
                      ),
                    ),
                  ),

                if (isSuccessfulDate)
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800.withOpacity(0.3), 
                      shape: BoxShape.circle,
                    ),
                  ),

                if (isToday)
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                    ),
                  ),

                Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.normal,
                    color: isDifferentMonth 
                        ? colorScheme.tertiary.withOpacity(0.6) 
                        : (isToday || isSuccessfulDate ? colorScheme.primary : colorScheme.onSurface),
                  ),
                ),

                if (isStreakTip)
                  Positioned(
                    bottom: -18,
                    child: Text(
                      '$streakCount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}