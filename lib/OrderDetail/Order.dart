import 'package:flutter/material.dart';

enum PaymentMethod {
  card,
  whish,
}

class OrderDetailsPage extends StatefulWidget {
  final String selectedImage; // Receives the selected image
  final String eventTitle;    // Event title
  final String eventDate;     // Event date
  final String eventLocation; // Event location

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
  // Quantities for ticket options
  int tickets = 0;
  int bbqShare = 0;
  int waterBottles = 0;
  int energyDrinks = 0;

  // Example cost data
  double ticketPrice = 15.0;
  double bbqPrice = 5.0;
  double waterPrice = 1.0;
  double energyPrice = 2.0;

  // Which payment method is selected by default?
  PaymentMethod _selectedMethod = PaymentMethod.card;

  // Helper functions to increment/decrement
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

    // Screen dimensions for responsive sizing
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with back arrow and centered "Order Details" text
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.04,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Order Details',
                        style: Theme.of(context).appBarTheme.titleTextStyle ??
                            const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  // Placeholder for symmetry
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Full-width image container (no horizontal padding)
            Container(
              width: double.infinity,
              height: screenHeight * 0.3, // Responsive height (30% of screen)
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.selectedImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.black87,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
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

            // The rest of the content wrapped with horizontal padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  // Ticket Options with white background
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket Options',
                          style: const TextStyle(
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
                          onAdd: () =>
                              increment((val) => waterBottles = val, waterBottles),
                          onRemove: () =>
                              decrement((val) => waterBottles = val, waterBottles),
                        ),
                        _buildTicketOptionRow(
                          label: 'Energy drink',
                          quantity: energyDrinks,
                          onAdd: () =>
                              increment((val) => energyDrinks = val, energyDrinks),
                          onRemove: () =>
                              decrement((val) => energyDrinks = val, energyDrinks),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Order Summary
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: const TextStyle(
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
                            Text(
                              'Total Due',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              '\$${totalDue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Payment Method (no background color here, so the
                  // confirm purchase button section won't have a white background)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // First payment option (Credit/Debit Card)
                        _buildPaymentOptionRow(
                          method: PaymentMethod.card,
                          label: 'Credit/Debit Card',
                          trailingText: '**67',
                          iconPath: 'assets/Icons/mastercard.png',
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Second payment option (Whish Money)
                        _buildPaymentOptionRow(
                          method: PaymentMethod.whish,
                          label: 'Whish Money',
                          trailingText: '**49',
                          iconPath: 'assets/Icons/wish.png',
                        ),
                      ],
                    ),
                  ),

                  // Confirm Button (styled)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50, // Fixed height for consistent styling
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Blue background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Rounded corners
                          ),
                        ),
                        onPressed: () {
                          // handle purchase confirmation
                        },
                        child: const Text(
                          'Confirm purchase',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
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

  /// Helper widget to build each ticket option row responsively
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
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onRemove,
                child: const Text(
                  '-',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onAdd,
                child: const Text(
                  '+',
                  style: TextStyle(
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

  /// Helper widget to build a single payment option row
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
          // Payment method icon
          Image.asset(
            iconPath,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),

          // Payment label
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),

          // Masked trailing text (e.g., "**67" or "**49")
          Text(
            trailingText,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),

          // Radio button
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
            activeColor: Colors.blue, // radio color
          ),
        ],
      ),
    );
  }

  /// Helper widget for the summary row
  Widget _buildSummaryRow(
    String label,
    int count,
    double cost, {
    bool isSubtotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isSubtotal)
            Text(
              '$count x $label',
              style: const TextStyle(fontFamily: 'Poppins'),
            )
          else
            Text(
              label,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
