import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/Booking/MyBooking.dart'; // Import MyBooking page
import 'package:adventura/OrderDetail/countries.dart';

class PaymentModal extends StatefulWidget {
  const PaymentModal({Key? key}) : super(key: key);

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
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
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
                      Spacer(), // This will push the next button to the right
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Show success message to the user
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Payment successful!"))
                          );
                          
                          // Close the modal first
                          Navigator.of(context).pop();
                          
                          // Navigate directly to the MyBookingsPage
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyBookingsPage(onScrollChanged: (bool value) {}),
                            ),
                            (route) => false, // Remove all previous routes
                          );
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
      ),
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