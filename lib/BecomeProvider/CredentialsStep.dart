import 'package:adventura/Services/provider_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class CredentialsStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CredentialsStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CredentialsStep> createState() => _CredentialsStepState();
}

class _CredentialsStepState extends State<CredentialsStep> {
  bool _agreeToTerms = false;

  XFile? _govIDImage;
  XFile? _selfieImage;
  XFile? _certificateImage;

  Future<void> pickImage(Function(XFile) setImage) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setImage(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: const [
              Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              SizedBox(width: 12),
              Text(
                "Credential & Verification",
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
          const SizedBox(height: 12),
          Text(
            "Upload necessary documents for verification.",
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 13.2,
              fontFamily: 'poppins',
            ),
          ),
          const SizedBox(height: 24),

          buildUploadSection("Government ID", _govIDImage, (file) {
            setState(() => _govIDImage = file);
          }),
          const SizedBox(height: 20),

          buildUploadSection("Personal Selfie", _selfieImage, (file) {
            setState(() => _selfieImage = file);
          }),
          const SizedBox(height: 20),

          buildUploadSection("Certifications", _certificateImage, (file) {
            setState(() => _certificateImage = file);
          }, optional: true),

          const SizedBox(height: 6),
          const Text(
            "ⓘ If applicable, like tour guide license, diving certification, etc.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontStyle: FontStyle.italic,
              fontFamily: 'poppins',
            ),
          ),
          const SizedBox(height: 24),

          // Terms Agreement
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() => _agreeToTerms = value!);
                },
                activeColor: Colors.blue,
                checkColor: Colors.white,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: "I agree to the ",
                    style: const TextStyle(fontSize: 13, fontFamily: 'poppins'),
                    children: const [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: " and Privacy Policy"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Buttons
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
                      style:
                          TextStyle(color: Colors.red, fontFamily: 'poppins')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _agreeToTerms
                      ? () async {
                          if (_govIDImage == null || _selfieImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Please upload required documents."),
                              ),
                            );
                            return;
                          }

                          try {
                            final box = await Hive.openBox('providerFlow');
                            await box.put('govIdPath', _govIDImage!.path);
                            await box.put('selfiePath', _selfieImage!.path);

                            if (_certificateImage != null) {
                              await box.put(
                                  'certificatePath', _certificateImage!.path);
                            }

                            widget.onNext(); // ✅ Go to next step
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Something went wrong: $e")),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    disabledBackgroundColor: Colors.blue.shade200,
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
    );
  }

  Widget buildUploadSection(
    String title,
    XFile? image,
    Function(XFile) onImagePicked, {
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
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
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => pickImage(onImagePicked),
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade100,
            ),
            alignment: Alignment.center,
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 36, color: Colors.grey),
                      SizedBox(height: 6),
                      Text("Add Photo",
                          style: TextStyle(
                              fontFamily: 'poppins',
                              color: Colors.grey,
                              fontSize: 13)),
                    ],
                  )
                : FutureBuilder(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            snapshot.data!,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
          ),
        )
      ],
    );
  }
}
