import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final List<String> daysOfWeek;
  final List<String> months;
  final List<int> years;

  final String selectedDay;
  final String selectedMonth;
  final int selectedYear;

  final Function(String) onDayChanged;
  final Function(String) onMonthChanged;
  final Function(int) onYearChanged;

  final TextEditingController fromController;
  final TextEditingController toController;

  const DateSelector({
    Key? key,
    required this.daysOfWeek,
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
  Widget build(BuildContext context) {
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
            // Day dropdown
            _buildDropdown<String>(
              value: selectedDay,
              items: daysOfWeek,
              onChanged: onDayChanged,
            ),
            const SizedBox(width: 8),
            // Month dropdown
            _buildDropdown<String>(
              value: selectedMonth,
              items: months,
              onChanged: onMonthChanged,
            ),
            const SizedBox(width: 8),
            // Year dropdown
            _buildDropdown<int>(
              value: selectedYear,
              items: years,
              onChanged: onYearChanged,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTimeField(fromController, 'from')),
            const SizedBox(width: 8),
            Expanded(child: _buildTimeField(toController, 'To')),
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
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 14,
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
            fontSize: 14,
            color: Colors.grey,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontFamily: 'poppins',
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}
