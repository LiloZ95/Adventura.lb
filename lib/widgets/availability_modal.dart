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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.blue,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
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
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select a Date",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins'),
              ),
              CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                  fetchSlots(date);
                },
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: BouncingDotsLoader(),
                  ),
                ),
              if (!isLoading && hasFetchedSlots) ...[
                const SizedBox(height: 10),
                if (availableSlots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Center(
                      child: Text(
                        "No available slots for this date.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else ...[
                  Text(
                    "Select a Time Slot",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: availableSlots.map((slot) {
                      return ChoiceChip(
                        label: Text(slot),
                        selected: selectedSlot == slot,
                        labelStyle: TextStyle(
                          color: selectedSlot == slot
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        selectedColor: AppColors.blue,
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedSlot = slot;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
              const SizedBox(height: 30),
              SizedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
