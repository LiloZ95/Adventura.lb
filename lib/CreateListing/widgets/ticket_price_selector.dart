import 'package:flutter/material.dart';

class TicketPriceSelector extends StatelessWidget {
  final TextEditingController controller;
  final String selectedType;
  final List<String> types;
  final Function(String?) onTypeChanged;

  const TicketPriceSelector({
    Key? key,
    required this.controller,
    required this.selectedType,
    required this.types,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Ticket Price',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Text(
                      '\$',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '/',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  isExpanded: true,
                  items: types.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onTypeChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const InfoRow(
          icon: Icons.info,
          message: 'Putting 0 will make this ticket for Free.',
        ),
        const InfoRow(
          icon: Icons.info,
          message: 'Select whether the ticket is per (Person, Hour, Day, etc..)',
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String message;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
