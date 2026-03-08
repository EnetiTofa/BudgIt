import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';

class FirstTimeDayPickerPage extends ConsumerStatefulWidget {
  const FirstTimeDayPickerPage({super.key});

  @override
  ConsumerState<FirstTimeDayPickerPage> createState() =>
      _FirstTimeDayPickerPageState();
}

class _FirstTimeDayPickerPageState
    extends ConsumerState<FirstTimeDayPickerPage> {
  int? _localSelectedDay;

  @override
  void initState() {
    super.initState();
    _loadInitialDay();
  }

  Future<void> _loadInitialDay() async {
    final settingsRepo = await ref.read(settingsProvider.future);
    if (mounted) {
      setState(() {
        _localSelectedDay = settingsRepo.getCheckInDay();
      });
    }
  }

  void _handleDaySelection(int dayNumber) {
    setState(() {
      _localSelectedDay = dayNumber;
    });
    ref.read(settingsProvider.notifier).setCheckInDay(dayNumber);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_localSelectedDay == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            "Pick Your Check-In Day",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "When do you want your weekly budgets to reset?",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // --- THE 7-CIRCLE DAY PICKER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              // Map index 0-6 (Sun-Sat) to Dart's DateTime weekday 1-7 (Mon-Sun)
              final int dayNumber = index == 0 ? 7 : index;
              final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

              final isSelected = _localSelectedDay == dayNumber;

              return GestureDetector(
                onTap: () => _handleDaySelection(dayNumber),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              "Example Calendar",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: theme.colorScheme.primary.withAlpha(150),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- DYNAMIC MINI CALENDAR ---
          IgnorePointer(
            child: _DynamicMiniCalendar(selectedDay: _localSelectedDay!),
          ),
        ],
      ),
    );
  }
}

class _DynamicMiniCalendar extends StatelessWidget {
  final int selectedDay; // 1 = Mon, 7 = Sun

  const _DynamicMiniCalendar({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Map Dart's weekday (1=Mon, 7=Sun) to our 0-6 visual grid (where 0=Sun)
    final visualTargetColumn = selectedDay == 7 ? 0 : selectedDay;

    // --- Calendar Math ---
    final int startOffset = 3; // Let's start the month on a Wednesday
    final int daysInMonth = 31;
    final int previousMonthDays = 30; // Assume the previous month had 30 days

    // Calculate which specific slot will be the "Monthly" (first active) check-in
    int firstActiveTargetSlot = -1;
    for (int i = startOffset; i < startOffset + daysInMonth; i++) {
      if (i % 7 == visualTargetColumn) {
        firstActiveTargetSlot = i;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Completely transparent background
      ),
      child: Column(
        children: [
          // Header Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, Colors.orange.shade800, "Monthly"),
              const SizedBox(width: 16),
              _buildLegendItem(
                context,
                Colors.orange.shade800.withOpacity(0.5),
                "Weekly",
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) {
              return SizedBox(
                width: 24,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Grid (35 slots: 5 rows x 7 columns)
          Column(
            children: List.generate(5, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (colIndex) {
                    final slot = (rowIndex * 7) + colIndex;

                    final bool isGhost =
                        slot < startOffset || slot >= startOffset + daysInMonth;
                    final bool isTargetDay = colIndex == visualTargetColumn;
                    final bool isMonthly = slot == firstActiveTargetSlot;

                    // Figure out what day number to display
                    int dayNumber;
                    if (slot < startOffset) {
                      dayNumber =
                          previousMonthDays -
                          startOffset +
                          slot +
                          1; // Previous month ghost days
                    } else if (slot >= startOffset + daysInMonth) {
                      dayNumber =
                          slot -
                          (startOffset + daysInMonth) +
                          1; // Next month ghost days
                    } else {
                      dayNumber =
                          slot - startOffset + 1; // Current active month days
                    }

                    // --- Styling Logic ---
                    Color bgColor = theme.colorScheme.surfaceContainerLow;
                    Color textColor = theme.colorScheme.onSurface.withOpacity(
                      0.4,
                    );

                    if (isMonthly) {
                      bgColor = Colors.orange.shade800;
                      textColor = Colors.white;
                    } else if (isTargetDay) {
                      bgColor = Colors.orange.shade800.withOpacity(0.5);
                      textColor = Colors.white;
                    } else {
                      if (isGhost) {
                        bgColor =
                            Colors.transparent; // Ghost days have no circle
                        textColor = theme.colorScheme.onSurface.withOpacity(
                          0.15,
                        ); // Extra faint text
                      } else {
                        bgColor = theme
                            .colorScheme
                            .surfaceContainerLow; // Active days get faint circle
                        textColor = theme.colorScheme.onSurface.withOpacity(
                          0.6,
                        );
                      }
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 10,
                          fontWeight: isTargetDay
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
