import 'package:flutter/material.dart';

class AddonsSection extends StatelessWidget {
  final List<Map<String, TextEditingController>> controllers;
  final VoidCallback onAdd;
  final Function(int) onDelete;

  const AddonsSection({
    Key? key,
    required this.controllers,
    required this.onAdd,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔵 Title + Divider
        Row(
          children: [
            Text(
              'Add-ons',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(color: isDarkMode ? Colors.grey : Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 🔁 Dynamic Input Rows
        ...controllers.asMap().entries.map((entry) {
          int i = entry.key;
          var map = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Label
                Expanded(
                  child: TextField(
                    controller: map["label"],
                    decoration: InputDecoration(
                      hintText: "Add-on label",
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[500] : Colors.grey,
                        fontFamily: 'poppins',
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              isDarkMode ? Colors.grey : Colors.grey.shade300,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Price
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: map["price"],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Price",
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[500] : Colors.grey,
                        fontFamily: 'poppins',
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              isDarkMode ? Colors.grey : Colors.grey.shade300,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Delete Button
                if (controllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () => onDelete(i),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 6),
        // ➕ Add More Button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Color(0xFF007AFF)),
            label: const Text(
              "Add more",
              style: TextStyle(
                fontFamily: 'poppins',
                fontWeight: FontWeight.w500,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
