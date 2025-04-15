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
    final initialTime = TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? (_fromTime ?? initialTime) : (_toTime ?? initialTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF),
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? const Color(0xFF007AFF)
                    : Colors.transparent,
              ),
              dayPeriodColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? const Color(0xFF007AFF)
                    : Colors.transparent,
              ),
              dayPeriodTextColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Colors.white
                    : Colors.black,
              ),
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

  // String _formatDuration(Duration d) {
  //   final hours = d.inHours;
  //   final minutes = d.inMinutes % 60;
  //   return '${hours}h${minutes > 0 ? ' $minutes min' : ''}';
  // }

  @override
  Widget build(BuildContext context) {
    final durationOptions = _calculateDurations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Select Date(s)',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
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
          calendarStyle: const CalendarStyle(
            isTodayHighlighted: true,
            rangeStartDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            rangeEndDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          rangeSelectionMode:
              widget.selectedListingType == ListingType.recurrent
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        
          const SizedBox(height: 30),
          Row(
            children: const [
              Text(
                'Time Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Expanded(child: Divider(color: Colors.grey)),
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
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledTimeBox(
                  context,
                  'End Time',
                  _toTime,
                  () => _pickTime(false),
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
            onChanged: (days) => widget.onWeekdaysChanged(days),
          ),
        ]
      ],
    );
  }

  Widget _buildStyledTimeBox(
      BuildContext context, String label, TimeOfDay? time, VoidCallback onTap) {
    final timeStr = time != null ? time.format(context) : '';
    final bool isSelected = timeStr.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? const Color(0xFF007AFF) : const Color(0xFFCFCFCF),
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
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
                  color: isSelected ? Colors.black : Colors.grey,
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
