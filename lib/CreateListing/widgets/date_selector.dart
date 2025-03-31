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

    return List.generate(lastDay, (i) => (i + 1).toString())
        .where((day) {
          final selectedDate = DateTime(year, monthIndex, int.parse(day));
          return selectedDate.isAfter(today);
        })
        .toList();
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
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDropdown<String>(
              value: days.contains(widget.selectedDay) ? widget.selectedDay : (days.isNotEmpty ? days.first : '1'),
              items: days,
              onChanged: widget.onDayChanged,
            ),
            const SizedBox(width: 8),
            _buildDropdown<String>(
              value: widget.selectedMonth,
              items: widget.months,
              onChanged: widget.onMonthChanged,
            ),
            const SizedBox(width: 8),
            _buildDropdown<int>(
              value: widget.selectedYear,
              items: widget.years,
              onChanged: widget.onYearChanged,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTimeField(widget.fromController, 'from')),
            const SizedBox(width: 8),
            Expanded(child: _buildTimeField(widget.toController, 'To')),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required Function(T) onChanged,
  }) {
    return Expanded(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCFCFCF), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: items.isNotEmpty ? value : null,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 15,
              color: Colors.black,
            ),
            onChanged: (T? newValue) {
              if (newValue != null) onChanged(newValue);
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
    );
  }

  Widget _buildTimeField(TextEditingController controller, String hint) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCFCFCF), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            color: Colors.grey,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontFamily: 'poppins',
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}
