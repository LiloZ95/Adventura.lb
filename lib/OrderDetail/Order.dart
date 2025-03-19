import 'package:adventura/OrderDetail/PurchaseConfiramtion.dart';
import 'package:adventura/OrderDetail/countries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adventura/colors.dart';
import 'package:intl/intl.dart';
// import 'package:adventura/widgets/payment_modal.dart';

/// Custom enforcer that rejects any new character if max length is exceeded.
class MaxDigitsEnforcer extends TextInputFormatter {
  final int maxLength;
  MaxDigitsEnforcer(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) {
      return oldValue;
    }
    return newValue;
  }
}

enum PaymentMethod { card, whish }

class OrderDetailsPage extends StatefulWidget {
  final String selectedImage;
  final String eventTitle;
  final String eventDate;
  final String eventLocation;

  const OrderDetailsPage({
    Key? key,
    required this.selectedImage,
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  int tickets = 0;
  int bbqShare = 0;
  int waterBottles = 0;
  int energyDrinks = 0;

  double ticketPrice = 15.0;
  double bbqPrice = 5.0;
  double waterPrice = 1.0;
  double energyPrice = 2.0;

  PaymentMethod _selectedMethod = PaymentMethod.card;

  void increment(Function setter, int value) {
    setState(() {
      setter(value + 1);
    });
  }

  void decrement(Function setter, int value) {
    if (value > 0) {
      setState(() {
        setter(value - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double ticketsTotal = tickets * ticketPrice;
    final double bbqTotal = bbqShare * bbqPrice;
    final double waterTotal = waterBottles * waterPrice;
    final double energyTotal = energyDrinks * energyPrice;
    final double subtotal = ticketsTotal + bbqTotal + waterTotal + energyTotal;
    final double totalDue = subtotal + 3.50;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section with overlay
            Container(
              width: double.infinity,
              height: screenHeight * 0.3,
              child: Stack(
                children: [
                  // Background image (network or asset)
                  Positioned.fill(
                    child: widget.selectedImage.startsWith('http')
                        ? Image.network(
                            widget.selectedImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/Pictures/island.jpg',
                                    fit: BoxFit.cover),
                          )
                        : Image.asset(
                            widget.selectedImage,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Gradient overlay + text
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '${widget.eventTitle}\n${widget.eventDate}\n${widget.eventLocation}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ticket Options container.
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ticket Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        _buildTicketOptionRow(
                          label: 'Tickets per person',
                          quantity: tickets,
                          onAdd: () =>
                              increment((val) => tickets = val, tickets),
                          onRemove: () =>
                              decrement((val) => tickets = val, tickets),
                        ),
                        _buildTicketOptionRow(
                          label: 'Barbeque share',
                          quantity: bbqShare,
                          onAdd: () =>
                              increment((val) => bbqShare = val, bbqShare),
                          onRemove: () =>
                              decrement((val) => bbqShare = val, bbqShare),
                        ),
                        _buildTicketOptionRow(
                          label: 'Water bottles',
                          quantity: waterBottles,
                          onAdd: () => increment(
                              (val) => waterBottles = val, waterBottles),
                          onRemove: () => decrement(
                              (val) => waterBottles = val, waterBottles),
                        ),
                        _buildTicketOptionRow(
                          label: 'Energy drink',
                          quantity: energyDrinks,
                          onAdd: () => increment(
                              (val) => energyDrinks = val, energyDrinks),
                          onRemove: () => decrement(
                              (val) => energyDrinks = val, energyDrinks),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Order Summary container.
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        _buildSummaryRow('Tickets', tickets, ticketsTotal),
                        _buildSummaryRow('BBQ Share', bbqShare, bbqTotal),
                        _buildSummaryRow(
                            'Water Bottles', waterBottles, waterTotal),
                        _buildSummaryRow(
                            'Energy Drinks', energyDrinks, energyTotal),
                        const Divider(),
                        _buildSummaryRow('Subtotal', 0, subtotal,
                            isSubtotal: true),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Due',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${totalDue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Payment Method section.
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildPaymentOptionRow(
                          method: PaymentMethod.card,
                          label: 'Credit/Debit Card',
                          trailingText: '**67',
                          iconPath: 'assets/Icons/mastercard.png',
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildPaymentOptionRow(
                          method: PaymentMethod.whish,
                          label: 'Whish Money',
                          trailingText: '**49',
                          iconPath: 'assets/Icons/wish.png',
                        ),
                      ],
                    ),
                  ),
                  // Purchase Button.
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.lock, // Optional: security/pay icon
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        ),
                        label: const Text(
                          'Proceed to Purchase',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const PaymentModal(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for ticket option rows.
  Widget _buildTicketOptionRow({
    required String label,
    required int quantity,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onRemove,
                child: const Text(
                  '-',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onAdd,
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for payment option rows.
  Widget _buildPaymentOptionRow({
    required PaymentMethod method,
    required String label,
    required String trailingText,
    required String iconPath,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            trailingText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          Radio<PaymentMethod>(
            value: method,
            groupValue: _selectedMethod,
            onChanged: (PaymentMethod? value) {
              if (value != null) {
                setState(() {
                  _selectedMethod = value;
                });
              }
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  // Helper widget for summary rows.
  Widget _buildSummaryRow(String label, int count, double cost,
      {bool isSubtotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isSubtotal)
            Text(
              '$count x $label',
              style: const TextStyle(
                fontFamily: 'Poppins',
              ),
            )
          else
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}


// PaymentModal BELOW


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

  String _selectedCountry = 'Lebanon';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expirationController.dispose();
    _cvvController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseConfirmationPage(),
                            ),
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
    return DropdownButtonFormField<String>(
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
      items: ['Lebanon', 'USA', 'Canada', 'UK']
          .map((country) => DropdownMenuItem(
                value: country,
                child: Text(
                  country,
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCountry = value!;
        });
      },
    );
  }
}

