import 'package:adventura/OrderDetail/PurchaseConfiramtion.dart';
import 'package:adventura/OrderDetail/ViewTicket.dart';
import 'package:adventura/OrderDetail/countries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            // Full-width image container.
            Container(
              width: double.infinity,
              height: screenHeight * 0.3,
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
                    colors: [Colors.black54, Colors.black87],
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
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          // Instead of showDialog, use showModalBottomSheet
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const PaymentModal(),
                          );
                        },
                        child: const Text(
                          'Purchase',
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

//
// PaymentModal BELOW
//

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
  final List<String> _countries = ['Lebanon', 'USA', 'Canada', 'UK'];

  // We can keep isExpanded if you like the "expand" animation
  bool isExpanded = false;

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
    //
    // The key part is:
    // We want a fractionally sized box with a top border radius
    // so it slides up from the bottom like a bottom sheet.
    //
    return FractionallySizedBox(
        heightFactor: 0.65, // 90% of screen height
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Material(
              color: Colors.white,
              child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Row with a grey arrow and title.
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: const Color.fromARGB(255, 19, 19, 19),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Add card details',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // NEW: Independent Card Number Field Container.
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey, width: 1),
                              color: Colors.white,
                            ),
                            child: _buildFieldRow(
                              child: TextField(
                                controller: _cardNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(16),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Card Number',
                                  hintText: '---- ---- ---- ----',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.black54,
                                  ),
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.black45,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Container for Card Number, Expiration, and CVV.
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey, width: 1),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                // Original Card Number field (hidden now).
                                Visibility(
                                  visible: false,
                                  child: _buildFieldRow(
                                    child: TextField(
                                      controller: _expirationController,
                                      keyboardType: TextInputType.datetime,
                                      decoration: const InputDecoration(
                                        labelText: 'Card Number',
                                        hintText: '---- ---- ---- ----',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black54,
                                        ),
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black45,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _buildFieldRow(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _expirationController,
                                          keyboardType: TextInputType.datetime,
                                          decoration: const InputDecoration(
                                            labelText: 'Expiration',
                                            hintText: 'MM / YY',
                                            labelStyle: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black54,
                                            ),
                                            hintStyle: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black45,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 1,
                                        color: Colors.grey[200],
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _cvvController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(3),
                                            MaxDigitsEnforcer(3),
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'CVV',
                                            hintText: '555',
                                            labelStyle: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black54,
                                            ),
                                            hintStyle: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black45,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
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
                          const SizedBox(height: 16),

                          // Container for Zip Code.
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey, width: 1),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                _buildFieldRow(
                                  child: TextField(
                                    controller: _zipController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Zip code',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.black54,
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.black45,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Container for Country/region.
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey, width: 1),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                _buildFieldRow(
                                    child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Country>(
                                    // ignore: unnecessary_cast
                                    
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: allCountries.map((Country country) {
                                      return DropdownMenuItem<Country>(
                                        value: country,
                                        child: Center(
                                          child: Text(
                                            '${country.flag} ${country.name}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (Country? value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedCountry = value as String ; 
                                        });
                                      }
                                    },
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    dropdownColor: Colors.white,
                                    hint: Center(
                                      child: const Text(
                                        'Country/region',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    selectedItemBuilder:
                                        (BuildContext context) {
                                      return allCountries
                                          .map((Country country) {
                                        return Center(
                                          child: Text(
                                            '${country.flag} ${country.name}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ))
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Cancel / Done Row.
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PurchaseConfirmationPage(),
                                    ),
                                  );
                                  setState(() {
                                    isExpanded = true;
                                  });
                                  // Then close after 300ms
                                },
                                child: const Text(
                                  'Done',
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
                  )),
            )));
  }

  Widget _buildFieldRow({required Widget child}) {
    return Container(
      padding: EdgeInsets.zero,
      child: child,
    );
  }
}
