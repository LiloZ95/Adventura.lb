import 'package:adventura/OrderDetail/PurchaseConfiramtion.dart';
import 'package:adventura/Services/booking_service.dart';
import 'package:adventura/Services/interaction_service.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1F1F1F)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: isDarkMode ? Colors.black87 : Colors.white,
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

                    // ✅ Gradient overlay + dynamic dark mode styling
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [
                                    Color.fromARGB(180, 20, 20, 20),
                                    Color.fromARGB(240, 0, 0, 0),
                                  ]
                                : [
                                    Color.fromARGB(80, 100, 100, 100),
                                    Color.fromARGB(200, 0, 0, 0),
                                  ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '${widget.eventTitle}\n${widget.eventDate}\n${widget.eventLocation}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            shadows: isDarkMode
                                ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    )
                                  ]
                                : [],
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
                        color: isDarkMode
                            ? const Color(0xFF2B2B2B)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket Options',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: isDarkMode ? Colors.white : Colors.black,
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
                            isDarkMode: isDarkMode,
                          ),
                          _buildTicketOptionRow(
                            label: 'Barbeque share',
                            quantity: bbqShare,
                            onAdd: () =>
                                increment((val) => bbqShare = val, bbqShare),
                            onRemove: () =>
                                decrement((val) => bbqShare = val, bbqShare),
                            isDarkMode: isDarkMode,
                          ),
                          _buildTicketOptionRow(
                            label: 'Water bottles',
                            quantity: waterBottles,
                            onAdd: () => increment(
                                (val) => waterBottles = val, waterBottles),
                            onRemove: () => decrement(
                                (val) => waterBottles = val, waterBottles),
                            isDarkMode: isDarkMode,
                          ),
                          _buildTicketOptionRow(
                            label: 'Energy drink',
                            quantity: energyDrinks,
                            onAdd: () => increment(
                                (val) => energyDrinks = val, energyDrinks),
                            onRemove: () => decrement(
                                (val) => energyDrinks = val, energyDrinks),
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),
                    // Order Summary container.

                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2B2B2B)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          // Rows
                          _buildSummaryRow('Tickets', tickets, ticketsTotal,
                              isDarkMode: isDarkMode),
                          _buildSummaryRow('BBQ Share', bbqShare, bbqTotal,
                              isDarkMode: isDarkMode),
                          _buildSummaryRow(
                              'Water Bottles', waterBottles, waterTotal,
                              isDarkMode: isDarkMode),
                          _buildSummaryRow(
                              'Energy Drinks', energyDrinks, energyTotal,
                              isDarkMode: isDarkMode),

                          Divider(
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[400],
                          ),

                          _buildSummaryRow('Subtotal', 0, subtotal,
                              isSubtotal: true, isDarkMode: isDarkMode),
                          SizedBox(height: screenHeight * 0.005),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
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

                              // 👇 Log the 'purchase' interaction
                              await InteractionService.logInteraction(
                                userId: clientId,
                                activityId: widget.activityId,
                                type: "purchase",
                              );
                              Box box = await Hive.openBox('authBox');
                              String firstName = box.get('firstName') ?? '';
                              String lastName = box.get('lastName') ?? '';
                              // TODO: Navigate to success screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PurchaseConfirmationPage(
                                    eventTitle: widget.eventTitle,
                                    clientName:
                                        "$firstName $lastName", // or get from Hive
                                    eventTime: widget.selectedSlot,
                                    numberOfAttendees:
                                        tickets, // or however you store it
                                    ticketId: "696969",
                                    // or real bookingId
                                    status:
                                        "Pending", // or the real status from backend
                                  ),
                                ),
                              );
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => MyBookingsPage(
                            //             onScrollChanged: (bool) {},
                            //           )),
                            // );
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
    required bool isDarkMode,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onRemove,
                child: Text(
                  '-',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                quantity.toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onAdd,
                child: Text(
                  '+',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
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
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blue;
              }
              return isDarkMode ? Colors.grey : Colors.black54;
            }),
          ),
        ],
      ),
    );
  }

  // Helper widget for summary rows.
  Widget _buildSummaryRow(String label, int count, double cost,
      {bool isSubtotal = false, required bool isDarkMode}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isSubtotal)
            Text(
              '$count x $label',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            )
          else
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: isSubtotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isSubtotal ? 16 : 14,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
