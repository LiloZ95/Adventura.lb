import 'package:adventura/widgets/bouncing_dots_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/availability_service.dart';
import '../colors.dart';

class AvailabilityModal extends StatefulWidget {
  final int activityId;
  final void Function(String date, String slot) onDateSlotSelected;

  const AvailabilityModal({
    Key? key,
    required this.activityId,
    required this.onDateSlotSelected,
  }) : super(key: key);

  @override
  _AvailabilityModalState createState() => _AvailabilityModalState();
}

class _AvailabilityModalState extends State<AvailabilityModal> {
  DateTime? selectedDate;
  String? selectedSlot;
  List<String> availableSlots = [];
  bool isLoading = false;
  bool hasFetchedSlots = false;
  Set<DateTime> highlightedDates = {};
  DateTime? _initialValidDate;

  Future<void> fetchSlots(DateTime date) async {
    setState(() {
      isLoading = true;
      selectedSlot = null;
      hasFetchedSlots = false;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final stopwatch = Stopwatch()..start();
    final slots = await AvailabilityService.fetchAvailableSlots(
      widget.activityId,
      formattedDate,
    );
    stopwatch.stop();

    final elapsed = stopwatch.elapsed;
    if (elapsed.inMilliseconds < 1500) {
      await Future.delayed(
          Duration(milliseconds: 1500 - elapsed.inMilliseconds));
    }

    setState(() {
      availableSlots = slots;
      isLoading = false;
      hasFetchedSlots = true;
    });
  }

  Future<void> bookNow() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    // 🚩 DON'T show SnackBar here anymore!
    widget.onDateSlotSelected(formattedDate, selectedSlot!);
    // Close the modal cleanly
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> fetchHighlightedDates() async {
    setState(() {
      isLoading = true;
      highlightedDates.clear();
      _initialValidDate = null; 
    });
    final rawDates =
        await AvailabilityService.fetchAvailableDates(widget.activityId);

    final today = DateTime.now();

    setState(() {
      highlightedDates = rawDates
          .map((d) => DateTime.parse(d))
          .where((d) => !d.isBefore(today)) // Remove past dates here
          .toSet();

      if (highlightedDates.isNotEmpty) {
        _initialValidDate = highlightedDates.reduce((a, b) =>
            a.isBefore(b) ? a : b); // Pick earliest remaining valid date
      }
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchHighlightedDates();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: isDarkMode
            ? const ColorScheme.dark(
                primary: AppColors.blue,
                onPrimary: Colors.white,
                onSurface: Colors.white70,
              )
            : const ColorScheme.light(
                primary: AppColors.blue,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            Center(
              child: Text(
                "Check Availability",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.event_available,
                        color: AppColors.blue, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Selected: ${DateFormat.yMMMd().format(selectedDate!)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              "Select a Date",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Stack(
              children: [
                AbsorbPointer(
                  absorbing: isLoading,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDarkMode
                          ? ColorScheme.dark(
                              primary: AppColors.blue,
                              onPrimary: Colors.white,
                              onSurface: Colors.white70,
                            )
                          : ColorScheme.light(
                              primary: AppColors.blue,
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                    ),
                    child: _initialValidDate == null
                        ? const Center(child: CircularProgressIndicator())
                        : CalendarDatePicker(
                            initialDate: _initialValidDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 60)),
                            onDateChanged: (date) {
                              if (!isLoading) {
                                setState(() => selectedDate = date);
                                fetchSlots(date);
                              }
                            },
                            selectableDayPredicate: highlightedDates.isEmpty
                                ? (_) => false // No days are selectable
                                : (day) => highlightedDates.contains(
                                    DateTime(day.year, day.month, day.day)),
                          ),
                  ),
                ),
                if (highlightedDates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        "No available dates",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.5)
                          : Colors.white.withOpacity(0.6),
                      child: const Center(child: BouncingDotsLoader()),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            if (!isLoading && hasFetchedSlots) ...[
              if (availableSlots.isEmpty)
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.sentiment_dissatisfied,
                          size: 40,
                          color: isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        "All booked up!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "No slots available on this date.\nTry another day.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                )
              else ...[
                Text(
                  "Select a Time Slot",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: availableSlots.map((slot) {
                    final isSelected = selectedSlot == slot;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        selectedColor: AppColors.blue,
                        backgroundColor: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedSlot = slot;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ],

            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedDate != null &&
                          selectedSlot != null &&
                          availableSlots.isNotEmpty
                      ? bookNow
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm Booking",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
