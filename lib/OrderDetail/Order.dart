import 'package:adventura/OrderDetail/PurchaseConfiramtion.dart';
import 'package:adventura/OrderDetail/countries.dart';
import 'package:adventura/widgets/payment_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adventura/colors.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Main Blue color
const Color mainBlue = Color(0xFF3D5A8E);

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
  final String selectedSlot;

  const OrderDetailsPage({
    Key? key,
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
    
    // Determine if we're on a large screen (web)
    final bool isLargeScreen = kIsWeb && screenWidth > 1000;
    
    // Adjusted padding for web
    final double horizontalPadding = isLargeScreen ? screenWidth * 0.05 : screenWidth * 0.05;

    return Scaffold(
      // No AppBar to eliminate white space at top
      body: Container(
        color: Colors.white,
        child: isLargeScreen 
            ? _buildWebLayout(
                screenWidth, 
                screenHeight, 
                horizontalPadding, 
                ticketsTotal, 
                bbqTotal, 
                waterTotal, 
                energyTotal, 
                subtotal, 
                totalDue
              ) 
            : _buildMobileLayout(
                screenWidth, 
                screenHeight, 
                horizontalPadding, 
                ticketsTotal, 
                bbqTotal, 
                waterTotal, 
                energyTotal, 
                subtotal, 
                totalDue
              ),
      ),
    );
  }
  
  // Web layout with full-width image and three columns
  Widget _buildWebLayout(
    double screenWidth,
    double screenHeight,
    double horizontalPadding,
    double ticketsTotal,
    double bbqTotal,
    double waterTotal,
    double energyTotal,
    double subtotal,
    double totalDue,
  ) {
    return Column(
      children: [
        // Full-width hero image with overlay at the top
        Stack(
          children: [
            // Full-width image
            Container(
              width: double.infinity,
              height: screenHeight * 0.5,
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
            
            // Back button overlaid on image
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            
            // Order Details title
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Order Details',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            // Event details positioned at the bottom of the image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildEventDetailPill(Icons.calendar_today, widget.eventDate),
                        const SizedBox(width: 16),
                        _buildEventDetailPill(Icons.access_time, widget.selectedSlot),
                        const SizedBox(width: 16),
                        _buildEventDetailPill(Icons.location_on, widget.eventLocation),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Content area with three columns
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Three column layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - Select Your Items
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Your Items',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Ticket Options
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ticket Options',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTicketOptionRow(
                                      label: 'Tickets per person',
                                      quantity: tickets,
                                      onAdd: () => increment((val) => tickets = val, tickets),
                                      onRemove: () => decrement((val) => tickets = val, tickets),
                                      isWeb: true,
                                    ),
                                    const Divider(),
                                    _buildTicketOptionRow(
                                      label: 'Barbeque share',
                                      quantity: bbqShare,
                                      onAdd: () => increment((val) => bbqShare = val, bbqShare),
                                      onRemove: () => decrement((val) => bbqShare = val, bbqShare),
                                      isWeb: true,
                                    ),
                                    const Divider(),
                                    _buildTicketOptionRow(
                                      label: 'Water bottles',
                                      quantity: waterBottles,
                                      onAdd: () => increment((val) => waterBottles = val, waterBottles),
                                      onRemove: () => decrement((val) => waterBottles = val, waterBottles),
                                      isWeb: true,
                                    ),
                                    const Divider(),
                                    _buildTicketOptionRow(
                                      label: 'Energy drink',
                                      quantity: energyDrinks,
                                      onAdd: () => increment((val) => energyDrinks = val, energyDrinks),
                                      onRemove: () => decrement((val) => energyDrinks = val, energyDrinks),
                                      isWeb: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Middle column - Order Summary
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Summary',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Order Summary
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSummaryRow('Tickets', tickets, ticketsTotal, isWeb: true),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow('BBQ Share', bbqShare, bbqTotal, isWeb: true),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow('Water Bottles', waterBottles, waterTotal, isWeb: true),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow('Energy Drinks', energyDrinks, energyTotal, isWeb: true),
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    _buildSummaryRow('Subtotal', 0, subtotal, isSubtotal: true, isWeb: true),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow('Service Fee', 0, 3.50, isSubtotal: true, isWeb: true),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Due',
                                          style: GoogleFonts.poppins(
                                            color: mainBlue,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '\$${totalDue.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: mainBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Right column - Payment Method
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _buildPaymentOptionRow(
                                      method: PaymentMethod.card,
                                      label: 'Credit/Debit Card',
                                      iconPath: 'assets/Icons/mastercard.png',
                                    ),
                                    const Divider(),
                                    _buildPaymentOptionRow(
                                      method: PaymentMethod.whish,
                                      label: 'Whish Money',
                                      iconPath: 'assets/Icons/wish.png',
                                    ),
                                    const SizedBox(height: 20),
                                    // Purchase Button in the payment column
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        label: Text(
                                          'Proceed to Purchase',
                                          style: GoogleFonts.poppins(
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
                                          backgroundColor: mainBlue,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Mobile layout
  Widget _buildMobileLayout(
    double screenWidth,
    double screenHeight,
    double horizontalPadding,
    double ticketsTotal,
    double bbqTotal,
    double waterTotal,
    double energyTotal,
    double subtotal,
    double totalDue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-height image with overlay
        Stack(
          children: [
            // Background image
            Container(
              width: double.infinity,
              height: screenHeight * 0.3,
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
            
            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            
            // Order Details title
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Order Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            // Gradient overlay + text
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color.fromARGB(221, 0, 0, 0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.all(horizontalPadding),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventTitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.9), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.eventDate,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on, color: Colors.white.withOpacity(0.9), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.eventLocation,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Content area
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Ticket Options
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket Options',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTicketOptionRow(
                            label: 'Tickets per person',
                            quantity: tickets,
                            onAdd: () => increment((val) => tickets = val, tickets),
                            onRemove: () => decrement((val) => tickets = val, tickets),
                          ),
                          _buildTicketOptionRow(
                            label: 'Barbeque share',
                            quantity: bbqShare,
                            onAdd: () => increment((val) => bbqShare = val, bbqShare),
                            onRemove: () => decrement((val) => bbqShare = val, bbqShare),
                          ),
                          _buildTicketOptionRow(
                            label: 'Water bottles',
                            quantity: waterBottles,
                            onAdd: () => increment((val) => waterBottles = val, waterBottles),
                            onRemove: () => decrement((val) => waterBottles = val, waterBottles),
                          ),
                          _buildTicketOptionRow(
                            label: 'Energy drink',
                            quantity: energyDrinks,
                            onAdd: () => increment((val) => energyDrinks = val, energyDrinks),
                            onRemove: () => decrement((val) => energyDrinks = val, energyDrinks),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Order Summary
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Tickets', tickets, ticketsTotal),
                          _buildSummaryRow('BBQ Share', bbqShare, bbqTotal),
                          _buildSummaryRow('Water Bottles', waterBottles, waterTotal),
                          _buildSummaryRow('Energy Drinks', energyDrinks, energyTotal),
                          const Divider(),
                          _buildSummaryRow('Subtotal', 0, subtotal, isSubtotal: true),
                          _buildSummaryRow('Service Fee', 0, 3.50, isSubtotal: true),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Due',
                                style: GoogleFonts.poppins(
                                  color: mainBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${totalDue.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: mainBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Payment Method section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentOptionRow(
                            method: PaymentMethod.card,
                            label: 'Credit/Debit Card',
                            iconPath: 'assets/Icons/mastercard.png',
                          ),
                          const Divider(),
                          _buildPaymentOptionRow(
                            method: PaymentMethod.whish,
                            label: 'Whish Money',
                            iconPath: 'assets/Icons/wish.png',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Purchase Button
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: screenWidth * 0.05,
                      ),
                      label: Text(
                        'Proceed to Purchase',
                        style: GoogleFonts.poppins(
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
                        backgroundColor: mainBlue,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Event detail pill for web layout
  Widget _buildEventDetailPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for ticket option rows
  Widget _buildTicketOptionRow({
    required String label,
    required int quantity,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    bool isWeb = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 12.0 : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isWeb ? 16 : 15,
            ),
          ),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(isWeb ? 8 : 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: isWeb ? 18 : 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isWeb ? 20 : 16),
              Text(
                quantity.toString(),
                style: GoogleFonts.poppins(
                  fontSize: isWeb ? 18 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: isWeb ? 20 : 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(isWeb ? 8 : 6),
                    decoration: BoxDecoration(
                      color: mainBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      size: isWeb ? 18 : 16,
                      color: mainBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for payment option rows
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
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
              activeColor: mainBlue,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for summary rows
  Widget _buildSummaryRow(
    String label, 
    int count, 
    double cost, {
    bool isSubtotal = false,
    bool isWeb = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 4.0 : 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isSubtotal)
            Text(
              '$count x $label',
              style: GoogleFonts.poppins(
                fontSize: isWeb ? 15 : 14,
              ),
            )
          else
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isWeb ? 15 : 14,
                fontWeight: isSubtotal ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: isWeb ? 15 : 14,
              fontWeight: isSubtotal ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}