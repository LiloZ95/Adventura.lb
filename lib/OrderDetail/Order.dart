import 'package:adventura/Services/booking_service.dart';
import 'package:adventura/widgets/payment_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adventura/colors.dart';
import 'package:hive/hive.dart';

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
  final int activityId;
  final String selectedSlot;

  const OrderDetailsPage({
    Key? key,
    required this.activityId,
    required this.selectedImage,
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
    required this.selectedSlot,
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
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
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
                            colors: [
                              Color.fromARGB(134, 62, 62, 62),
                              Color.fromARGB(221, 0, 0, 0)
                            ],
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
              SizedBox(height: screenHeight * 0.02),
              // Content area
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ticket Options container.
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius:
                            BorderRadius.circular(12), // <-- Rounded corners
                      ),
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
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius:
                            BorderRadius.circular(12), // <-- Rounded corners
                      ),
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
                            iconPath: 'assets/Icons/mastercard.png',
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          _buildPaymentOptionRow(
                            method: PaymentMethod.whish,
                            label: 'Whish Money',
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
                            Icons.lock,
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
                          onPressed: () async {
                            final box = await Hive.openBox('authBox');
                            final clientId =
                                int.tryParse(box.get('userId') ?? '');

                            if (clientId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ User not logged in")),
                              );
                              return;
                            }

                            // ✅ DEBUG LOG
                            print("🟢 Proceed tapped - sending booking");

                            final success = await BookingService.createBooking(
                              activityId: widget.activityId,
                              clientId: clientId,
                              date: widget.eventDate,
                              slot: widget.selectedSlot,
                              totalPrice: totalDue,
                            );

                            if (success) {
                              print("✅ Booking confirmed");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("✅ Booking successful")),
                              );

                              // TODO: Navigate to success screen
                              // Navigator.push(...);
                            } else {
                              print("❌ Booking failed");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "❌ Booking failed. Please try again."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
