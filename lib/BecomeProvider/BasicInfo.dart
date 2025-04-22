import 'package:flutter/material.dart';
import 'package:adventura/BecomeProvider/widgets/TextFieldWidget.dart';
import 'package:hive/hive.dart';

class BasicInfoScreen extends StatefulWidget {
  final VoidCallback onNext;

  const BasicInfoScreen({super.key, required this.onNext});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  String? _selectedCity;

  final List<String> cities = [
    'Beirut',
    'Tripoli',
    'Sidon',
    'Tyre',
    'Zahle',
    'Jounieh',
    'Byblos',
    'Baalbek',
    'Aley',
    'Batroun',
    'Nabatieh',
    'Halba',
    'Hermel',
    'Rachaya',
    'Bent Jbeil'
  ];

  final List<String> days =
      List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> months =
      List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> years =
      List.generate(100, (i) => (DateTime.now().year - i).toString());

  Future<void> loadUserInfo() async {
    final authBox = await Hive.openBox('authBox');
    final flowBox = await Hive.openBox('providerFlow');

    _firstNameController.text = authBox.get("firstName", defaultValue: "");
    _lastNameController.text = authBox.get("lastName", defaultValue: "");
    _emailController.text = authBox.get("userEmail", defaultValue: "");

    _selectedDay = flowBox.get("selectedDay");
    _selectedMonth = flowBox.get("selectedMonth");
    _selectedYear = flowBox.get("selectedYear");
    _selectedCity = flowBox.get("selectedCity");
    _addressController.text = flowBox.get("address", defaultValue: "");
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  @override
  @override
   @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.blue[200] : Colors.blue[600];
    final dividerColor = isDarkMode ? Colors.grey.shade700 : Colors.grey;
  return Scaffold(
    backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white, // 🌙 Full background switch
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Expanded(child: Divider(thickness: 1, color: dividerColor)),
                const SizedBox(width: 12),
                Text(
                  "Basic Information",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Divider(thickness: 1, color: dividerColor)),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              "Tell us about yourself to get started.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: subtitleColor,
              ),
            ),

            const SizedBox(height: 32),
            buildLabel("First Name", textColor),
            const SizedBox(height: 6),
            CustomTextField(hint: "First Name", controller: _firstNameController, enabled: false),

            const SizedBox(height: 16),
            buildLabel("Last Name", textColor),
            const SizedBox(height: 6),
            CustomTextField(hint: "Last Name", controller: _lastNameController, enabled: false),

            const SizedBox(height: 16),
            buildLabel("Personal Email", textColor),
            const SizedBox(height: 6),
            CustomTextField(hint: "Email", controller: _emailController, enabled: false),

            const SizedBox(height: 16),
            buildLabel("Birth Date", textColor),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: buildDropdown("DD", days, _selectedDay, (val) => setState(() => _selectedDay = val))),
                const SizedBox(width: 8),
                Expanded(child: buildDropdown("MM", months, _selectedMonth, (val) => setState(() => _selectedMonth = val))),
                const SizedBox(width: 8),
                Expanded(child: buildDropdown("YYYY", years, _selectedYear, (val) => setState(() => _selectedYear = val))),
              ],
            ),

            const SizedBox(height: 16),
            buildLabel("City", textColor),
            const SizedBox(height: 6),
            buildDropdown("Select your city", cities, _selectedCity, (val) => setState(() => _selectedCity = val)),

            const SizedBox(height: 16),
            buildLabel("Address Line 1", textColor, optional: true),
            const SizedBox(height: 6),
            CustomTextField(hint: "Enter your address", controller: _addressController),

            const SizedBox(height: 36),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final box = await Hive.openBox('providerFlow');
                      await box.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _selectedDay != null &&
                          _selectedMonth != null &&
                          _selectedYear != null &&
                          _selectedCity != null) {
                        final box = await Hive.openBox('providerFlow');
                        await box.put("selectedDay", _selectedDay);
                        await box.put("selectedMonth", _selectedMonth);
                        await box.put("selectedYear", _selectedYear);
                        await box.put("selectedCity", _selectedCity);
                        await box.put("address", _addressController.text);
                        widget.onNext();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all required fields.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  Widget buildLabel(String text, Color textColor,
      {bool optional = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Text.rich(
      TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        children: optional
            ? [
                TextSpan(
                  text: " (optional)",
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                )
              ]
            : [],
      ),
    );
  }

  Widget buildDropdown<T>(
    String hint,
    List<T> items,
    T? selectedValue,
    ValueChanged<T?> onChanged,
  ) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return DropdownButtonFormField<T>(
          value: selectedValue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: isDarkMode ? Colors.white : Colors.black),
          dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontFamily: 'Poppins',
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white24 : Colors.black26,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white24 : Colors.black26,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blueAccent,
                width: 1.5,
              ),
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'Poppins',
          ),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
        );
      },
    );
  }

InputDecoration inputDecoration(String hint, bool isDarkMode) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      fontFamily: 'Poppins',
    ),
    filled: true,
    fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.white24 : Colors.black26,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.white24 : Colors.black26,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.blueAccent,
        width: 1.5,
      ),
    ),
  );
}
}