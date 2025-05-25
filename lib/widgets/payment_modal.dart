// import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';

import 'package:adventura/Services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:adventura/OrderDetail/countries.dart';

class PaymentModal extends StatefulWidget {
  final int activityId;
  final int clientId;
  final String bookingDate;
  final String slot;
  final double totalPrice;

  const PaymentModal({
    super.key,
    required this.activityId,
    required this.clientId,
    required this.bookingDate,
    required this.slot,
    required this.totalPrice,
  });
  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expirationController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  Country? _selectedCountry;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expirationController.dispose();
    _cvvController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  String formatCardNumber(String input) {
    final digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    return digitsOnly
        .replaceAllMapped(RegExp(r".{1,4}"), (match) => "${match.group(0)} ")
        .trimRight();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black87),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Add Card Details',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.credit_card, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Card Number
                    _inputField(
                      label: 'Card Number',
                      hint: '1234 5678 9012 3456',
                      controller: _cardNumberController,
                      inputType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Expiration & CVV Row
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            label: 'Expiration',
                            hint: 'MM/YY',
                            controller: _expirationController,
                            inputType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _inputField(
                            label: 'CVV',
                            hint: '123',
                            controller: _cvvController,
                            inputType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Zip Code
                    _inputField(
                      label: 'Zip Code',
                      hint: 'e.g. 10001',
                      controller: _zipController,
                      inputType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Country Dropdown
                    _buildCountryDropdown(),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            print("🔵 Continue pressed");
                            bool success = await BookingService.createBooking(
                              activityId: widget.activityId,
                              userId: widget.clientId,
                              date: widget.bookingDate,
                              slot: widget.slot,
                              totalPrice: widget.totalPrice,
                            );

                            if (success) {
                              Navigator.of(context).pop();
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         PurchaseConfirmationPage(),
                              //   ),
                              // );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("❌ Booking failed"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required TextInputType inputType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<Country>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Country / Region',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
      value: _selectedCountry,
      items: allCountries.map((country) {
        return DropdownMenuItem(
          value: country,
          child: Text("${country.flag} ${country.name}"),
        );
      }).toList(),
      onChanged: (Country? value) {
        setState(() {
          _selectedCountry = value;
        });
      },
    );
  }
}
