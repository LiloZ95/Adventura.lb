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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                SizedBox(width: 12),
                Text("Basic Information",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'poppins')),
                SizedBox(width: 12),
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Tell us about yourself to get started.",
              style: TextStyle(
                  fontSize: 14, fontFamily: 'poppins', color: Colors.blue[600]),
            ),
            const SizedBox(height: 32),
            buildLabel("First Name"),
            const SizedBox(height: 6),
            CustomTextField(
              hint: "First Name",
              controller: _firstNameController,
              enabled: false,
            ),
            const SizedBox(height: 16),
            buildLabel("Last Name"),
            const SizedBox(height: 6),
            CustomTextField(
                hint: "Last Name",
                controller: _lastNameController,
                enabled: false),
            const SizedBox(height: 16),
            buildLabel("Personal Email"),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: inputDecoration("Email"),
            ),
            const SizedBox(height: 16),
            buildLabel("Birth Date"),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                    child: buildDropdown("DD", days, _selectedDay,
                        (val) => setState(() => _selectedDay = val))),
                const SizedBox(width: 8),
                Expanded(
                    child: buildDropdown("MM", months, _selectedMonth,
                        (val) => setState(() => _selectedMonth = val))),
                const SizedBox(width: 8),
                Expanded(
                    child: buildDropdown("YYYY", years, _selectedYear,
                        (val) => setState(() => _selectedYear = val))),
              ],
            ),
            const SizedBox(height: 16),
            buildLabel("City"),
            const SizedBox(height: 6),
            buildDropdown("Select your city", cities, _selectedCity,
                (val) => setState(() => _selectedCity = val)),
            const SizedBox(height: 16),
            buildLabel("Address Line 1", optional: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _addressController,
              decoration: inputDecoration("Enter your address"),
            ),
            const SizedBox(height: 36),
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
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            color: Colors.red)),
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
                          const SnackBar(
                              content:
                                  Text("Please fill all required fields.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Next",
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text, {bool optional = false}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'poppins'),
        children: optional
            ? [
                const TextSpan(
                  text: " (optional)",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic),
                )
              ]
            : [],
      ),
    );
  }

  Widget buildDropdown(String hint, List<String> items, String? value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: (val) => val == null ? "Required" : null,
      decoration: inputDecoration(hint),
      items: items
          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
          .toList(),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'poppins', color: Colors.grey),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
