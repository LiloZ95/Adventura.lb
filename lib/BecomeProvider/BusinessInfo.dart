import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'successfully_provider.dart';

class BusinessInfoStep extends StatefulWidget {
  final VoidCallback onBack;

  const BusinessInfoStep({super.key, required this.onBack, required void Function() onNext});

  @override
  State<BusinessInfoStep> createState() => _BusinessInfoStepState();
}

class _BusinessInfoStepState extends State<BusinessInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  File? _logoImage;

  Future<void> pickLogoImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoImage = File(picked.path));
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_logoImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a business logo.')),
        );
        return;
      }
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const ProviderWelcomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                SizedBox(width: 12),
                Text(
                  "Business Information",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppins',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Tell us more about your business.",
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'poppins',
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 24),

            // Business Name
            buildLabel("Business Name"),
            const SizedBox(height: 6),
            buildTextField(_businessNameController, hint: "Business name"),
            const SizedBox(height: 16),

            // Description
            buildLabel("Business Description"),
            const SizedBox(height: 6),
            buildTextField(_descriptionController,
                hint: "Describe what you offer", maxLines: 4),
            const SizedBox(height: 16),

            // Email
            buildLabel("Business Email"),
            const SizedBox(height: 6),
            buildTextField(_emailController, hint: "Business@gmail.com"),
            const SizedBox(height: 16),

            // City
            buildLabel("City"),
            const SizedBox(height: 6),
            buildTextField(_cityController, hint: "City name"),
            const SizedBox(height: 20),

            // Logo
            buildLabel("Business Logo"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickLogoImage,
              child: Center(
                child: _logoImage == null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.add_photo_alternate_outlined,
                            size: 32, color: Colors.grey),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_logoImage!),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Social Media (optional)
            buildLabel("Social Media Links", optional: true),
            const SizedBox(height: 8),
            buildSocialField(_instagramController, hint: "Instagram", leading: Icons.camera_alt_outlined, leadingColor: Color(0xFFE1306C)),
            const SizedBox(height: 10),
            buildSocialField(_tiktokController, hint: "TikTok", leading: Icons.music_note, leadingColor: Color(0xFF010101)),
            const SizedBox(height: 10),
            buildSocialField(_facebookController, hint: "Facebook", leading: Icons.facebook, leadingColor: Color(0xFF4267B2)),
            const SizedBox(height: 24),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Back",
                        style: TextStyle(
                            color: Colors.red, fontFamily: 'poppins')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ],
            ),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'poppins',
        ),
        children: optional
            ? [
                const TextSpan(
                  text: " (optional)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              ]
            : [],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller,
      {required String hint, int maxLines = 1, IconData? icon, bool required = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: required
          ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
          : null,
      style: const TextStyle(fontFamily: 'poppins'),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.blue) : null,
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'poppins', color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget buildSocialField(TextEditingController controller,
      {required String hint, required IconData leading, required Color leadingColor}) {
    return TextFormField(
      controller: controller,
      validator: (value) => null,
      style: const TextStyle(fontFamily: 'poppins'),
      decoration: InputDecoration(
        prefixIcon: Icon(leading, color: leadingColor),
        suffixIcon: const Icon(Icons.link, color: Colors.blue),
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'poppins', color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}