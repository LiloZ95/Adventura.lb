// ✅ FIXED: Avoid crash when no valid days — fallback to safe default
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final List<String> months;
  final List<int> years;

  final String selectedMonth;
  final int selectedYear;
  final String selectedDay;

  final Function(String) onDayChanged;
  final Function(String) onMonthChanged;
  final Function(int) onYearChanged;

  final TextEditingController fromController;
  final TextEditingController toController;

  const DateSelector({
    Key? key,
    required this.months,
    required this.years,
    required this.selectedDay,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.fromController,
    required this.toController,
  }) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late List<String> validDays;
  late String validSelectedDay;
  String? _focusedField;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeValidDate());
  }

  void _initializeValidDate() {
    int monthIndex = widget.months.indexOf(widget.selectedMonth);
    int year = widget.selectedYear;

    List<String> days = getValidDays(widget.months[monthIndex], year);

    while (days.isEmpty) {
      monthIndex++;
      if (monthIndex >= 12) {
        monthIndex = 0;
        year++;
      }
      if (!widget.years.contains(year)) break;
      widget.onMonthChanged(widget.months[monthIndex]);
      widget.onYearChanged(year);
      days = getValidDays(widget.months[monthIndex], year);
    }

    validDays = days;
    validSelectedDay = validDays.contains(widget.selectedDay)
        ? widget.selectedDay
        : (validDays.isNotEmpty ? validDays.first : '1');

    widget.onDayChanged(validSelectedDay);
  }

  List<String> getValidDays(String month, int year) {
    final monthIndex = widget.months.indexOf(month) + 1;
    final lastDay = DateTime(year, monthIndex + 1, 0).day;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(lastDay, (i) => (i + 1).toString()).where((day) {
      final selectedDate = DateTime(year, monthIndex, int.parse(day));
      return selectedDate.isAfter(today);
    }).toList();
  }

  Widget _buildStyledTimeBox({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        String? lastSelectedTime;
        bool isFocused = _focusedField == label;

        return GestureDetector(
          onTap: () async {
            setState(() => _focusedField = label); // focus this box
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF007AFF), // Main blue
                      onSurface: Colors.black,
                    ),
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: Colors.white,
                      hourMinuteShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hourMinuteColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? const Color(0xFF007AFF)
                              : Colors.transparent),
                      dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                          states.contains(WidgetState.selected)
                              ? const Color(0xFF007AFF)
                              : Colors.transparent),
                      dayPeriodTextColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Colors.white
                              : Colors.black),
                      entryModeIconColor: const Color(0xFF007AFF),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              final formatted = picked.format(context);
              setState(() {
                lastSelectedTime = formatted;
                controller.text = formatted;
              });
            }
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isFocused
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFCFCFCF),
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 18, color: Color(0xFF007AFF)),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    controller.text.isEmpty ? label : controller.text,
                    key: ValueKey(controller.text),
                    style: TextStyle(
                      color:
                          controller.text.isEmpty ? Colors.grey : Colors.black,
                      fontFamily: 'poppins',
                      fontSize: 14,
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

  @override
  Widget build(BuildContext context) {
    final days = getValidDays(widget.selectedMonth, widget.selectedYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Date',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),

        // ⏳ Date Pickers Row
        Row(
          children: [
            _buildDropdown<String>(
              value: days.contains(widget.selectedDay)
                  ? widget.selectedDay
                  : (days.isNotEmpty ? days.first : '1'),
              items: days,
              onChanged: widget.onDayChanged,
              fieldKey: 'day',
            ),
            const SizedBox(width: 8),
            _buildDropdown<String>(
              value: widget.selectedMonth,
              items: widget.months,
              onChanged: widget.onMonthChanged,
              fieldKey: 'month',
            ),
            const SizedBox(width: 8),
            _buildDropdown<int>(
              value: widget.selectedYear,
              items: widget.years,
              onChanged: widget.onYearChanged,
              fieldKey: 'year',
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 🕓 Time Pickers (Styled Like Image Picker Boxes)
        Row(
          children: [
            Expanded(
              child: _buildStyledTimeBox(
                label: 'Start Time',
                controller: widget.fromController,
                context: context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStyledTimeBox(
                label: 'End Time',
                controller: widget.toController,
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required Function(T) onChanged,
    required String fieldKey, // 👈 add unique key
  }) {
    final isFocused = _focusedField == fieldKey;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _focusedField = fieldKey),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isFocused ? const Color(0xFF007AFF) : const Color(0xFFCFCFCF),
              width: 1.3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: items.isNotEmpty ? value : null,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down,
                  color: isFocused ? const Color(0xFF007AFF) : Colors.grey),
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                color: Colors.black,
              ),
              onChanged: (T? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                  setState(
                      () => _focusedField = null); // unfocus after selection
                }
              },
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.white,
                  hourMinuteShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  dayPeriodTextStyle: const TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  hourMinuteTextStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  helpTextStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'poppins',
                  ),
                  dialHandColor: Colors.blueAccent,
                  entryModeIconColor: Colors.blue,
                ),
                colorScheme: const ColorScheme.light(
                  primary: Colors.blueAccent,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          final formattedTime = picked.format(context); // e.g., 08:00 AM
          controller.text = formattedTime;
        }
      },
      child: Container(
        height: 50,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCFCFCF), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          controller.text.isEmpty ? label : controller.text,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            color: controller.text.isEmpty ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }
}
