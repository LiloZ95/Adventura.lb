import 'package:adventura/controllers/create_listing_controller.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:adventura/CreateListing/widgets/duration_selector.dart';
import 'package:adventura/CreateListing/widgets/weekday_selector.dart';

class CalendarDateSelector extends StatefulWidget {
  final ListingType selectedListingType;
  final Function(DateTime startDate, DateTime? endDate) onDateRangeSelected;
  final Duration? selectedDuration;
  final ValueChanged<Duration> onDurationChanged;
  final Set<String> selectedWeekdays;
  final ValueChanged<Set<String>> onWeekdaysChanged;
  final void Function(TimeOfDay?, TimeOfDay?)? onTimeRangeSelected;

  const CalendarDateSelector({
    Key? key,
    required this.selectedListingType,
    required this.onDateRangeSelected,
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.selectedWeekdays,
    required this.onWeekdaysChanged,
    required this.onTimeRangeSelected,
  }) : super(key: key);

  @override
  State<CalendarDateSelector> createState() => _CalendarDateSelectorState();
}

class _CalendarDateSelectorState extends State<CalendarDateSelector> {
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (widget.selectedListingType == ListingType.oneTime) {
        _startDate = selectedDay;
        _endDate = null;
        widget.onDateRangeSelected(_startDate!, null);
      } else {
        if (_startDate == null || (_startDate != null && _endDate != null)) {
          _startDate = selectedDay;
          _endDate = null;
        } else {
          if (selectedDay.isBefore(_startDate!)) {
            _startDate = selectedDay;
            _endDate = null;
          } else {
            _endDate = selectedDay;
            widget.onDateRangeSelected(_startDate!, _endDate);
          }
        }
      }
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final initialTime = TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? (_fromTime ?? initialTime) : (_toTime ?? initialTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
              primary: const Color(0xFF007AFF),
              onPrimary: Colors.white,
              secondary: const Color(0xFF007AFF),
              onSecondary: Colors.white,
              surface: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black,
              error: Colors.red,
              onError: Colors.white,
              background: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
              onBackground: isDarkMode ? Colors.white : Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor:
                  isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
              hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? const Color(0xFF007AFF)
                      : isDarkMode
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xFFF2F2F7)),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Colors.white
                      : isDarkMode
                          ? Colors.white
                          : Colors.black),
              dialHandColor: const Color(0xFF007AFF),
              entryModeIconColor: const Color(0xFF007AFF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
        widget.onTimeRangeSelected?.call(_fromTime, _toTime);
      });
    }
  }

  List<Duration> _calculateDurations() {
    if (_fromTime == null || _toTime == null) return [];

    final startMinutes = _fromTime!.hour * 60 + _fromTime!.minute;
    final endMinutes = _toTime!.hour * 60 + _toTime!.minute;
    final total = endMinutes - startMinutes;

    if (total <= 0) return [];

    final durations = <Duration>[];
    for (int step = 30; step <= total; step += 30) {
      durations.add(Duration(minutes: step));
    }
    return durations;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final durationOptions = _calculateDurations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Date(s)',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _startDate ?? DateTime.now(),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          selectedDayPredicate: (day) {
            if (widget.selectedListingType == ListingType.oneTime) {
              return _startDate != null && isSameDay(day, _startDate);
            }
            return false;
          },
          rangeStartDay: _startDate,
          rangeEndDay: _endDate,
          onDaySelected: _onDaySelected,
          calendarStyle: CalendarStyle(
            isTodayHighlighted: true,
            todayTextStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            todayDecoration: BoxDecoration(
              color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            rangeStartDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            rangeEndDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          rangeSelectionMode: widget.selectedListingType == ListingType.recurrent
              ? RangeSelectionMode.enforced
              : RangeSelectionMode.toggledOff,
        ),
        const SizedBox(height: 10),
        if (_startDate != null)
          Text(
            widget.selectedListingType == ListingType.oneTime
                ? "Selected Date: ${DateFormat.yMMMd().format(_startDate!)}"
                : _endDate != null
                    ? "Range: ${DateFormat.yMMMd().format(_startDate!)} → ${DateFormat.yMMMd().format(_endDate!)}"
                    : "Start: ${DateFormat.yMMMd().format(_startDate!)} (select end date)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        const SizedBox(height: 30),
        Row(
          children: [
            Text(
              'Time Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStyledTimeBox(
                context,
                'Start Time',
                _fromTime,
                () => _pickTime(true),
                isDarkMode,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStyledTimeBox(
                context,
                'End Time',
                _toTime,
                () => _pickTime(false),
                isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (widget.selectedListingType == ListingType.recurrent && durationOptions.isNotEmpty) ...[
          DurationSelector(
            selectedDuration: widget.selectedDuration,
            availableDurations: durationOptions,
            onChanged: widget.onDurationChanged,
          ),
          const SizedBox(height: 20),
          WeekdaySelector(
            selectedDays: widget.selectedWeekdays,
            onChanged: widget.onWeekdaysChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildStyledTimeBox(
    BuildContext context,
    String label,
    TimeOfDay? time,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    final timeStr = time != null ? time.format(context) : '';
    final isSelected = timeStr.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF007AFF) : Colors.grey.shade500,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 18, color: Color(0xFF007AFF)),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                isSelected ? timeStr : label,
                key: ValueKey(timeStr),
                style: TextStyle(
                  color: isSelected
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : Colors.grey,
                  fontFamily: 'poppins',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
