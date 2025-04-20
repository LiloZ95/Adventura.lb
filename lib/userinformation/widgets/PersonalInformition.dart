import 'package:adventura/OTP/OTPVerification.dart';
import 'package:adventura/Services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = await UserService.fetchUserProfile();
    if (user == null) return;

    setState(() {
      fullNameController.text =
          "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".trim();
      emailController.text = user['email'] ?? '';
      phoneController.text = user['phone_number'] ?? '';
    });
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final nameParts = fullNameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final updated = await UserService.updateUserDetails({
      "first_name": firstName,
      "last_name": lastName,
      "email": emailController.text.trim(),
      "phone_number": phoneController.text.trim(),
    });

    if (updated) {
      setState(() => isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed. Please try again.')),
      );
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: !isEditing,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
            hintText: 'Enter $label',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.blue.withOpacity(0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) =>
              value == null || value.trim().isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Text(
          "Personal Details",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.pencil,
                color: isDarkMode ? Colors.white70 : Colors.grey),
            onPressed: () => setState(() => isEditing = !isEditing),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 10,
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  buildField(
                    label: "Full Name",
                    controller: fullNameController,
                    icon: LucideIcons.user,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  buildField(
                    label: "Email",
                    controller: emailController,
                    icon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  buildField(
                    label: "Phone Number",
                    controller: phoneController,
                    icon: LucideIcons.phone,
                    keyboardType: TextInputType.phone,
                    isDarkMode: isDarkMode,
                  ),
                  if (isEditing)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.sms, size: 18),
                        label: const Text("Verify Phone"),
                        onPressed: () {
                          final phone = phoneController.text.trim();
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Please enter a phone number first.")),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerificationScreen(
                                target: phone,
                                targetType: "phone",
                                isForSignup: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 30),
                  if (isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: saveChanges,
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
