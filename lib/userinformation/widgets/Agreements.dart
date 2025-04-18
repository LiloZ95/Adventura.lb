import 'package:flutter/material.dart';

class ProviderAgreementPage extends StatefulWidget {
  const ProviderAgreementPage({super.key});

  @override
  State<ProviderAgreementPage> createState() => _ProviderAgreementPageState();
}

class _ProviderAgreementPageState extends State<ProviderAgreementPage> {
  bool isAccepted = false;

  void onSubmit() {
    if (isAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Application submitted!')),
      );
      // Handle next step (send to backend, navigate, etc.)
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Text(
          "Provider Terms & Conditions",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  "By submitting this application to become a provider on the Adventura platform, you agree to the following terms:",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _AgreementPoint(
                          title: "1. Accuracy of Information",
                          content:
                              "You confirm that all information and documents provided in this application are accurate, complete, and up to date.",
                        ),
                        _AgreementPoint(
                          title: "2. Compliance with Laws",
                          content:
                              "You agree to comply with all local, regional, and international laws and regulations related to the services you provide.",
                        ),
                        _AgreementPoint(
                          title: "3. Service Quality",
                          content:
                              "You commit to delivering services in a professional, safe, and customer-friendly manner, maintaining high-quality standards.",
                        ),
                        _AgreementPoint(
                          title: "4. Insurance & Licenses",
                          content:
                              "You confirm that you possess all required licenses, permits, and insurance necessary to operate your services legally.",
                        ),
                        _AgreementPoint(
                          title: "5. Verification Process",
                          content:
                              "You understand that Adventura may conduct identity and background verification checks and that approval is subject to the outcome of this process.",
                        ),
                        _AgreementPoint(
                          title: "6. Content Usage",
                          content:
                              "You grant Adventura the right to use submitted content (business name, logo, service descriptions, etc.) for marketing and promotional purposes.",
                        ),
                        _AgreementPoint(
                          title: "7. Platform Policies",
                          content:
                              "You agree to adhere to Adventura’s platform policies, including but not limited to cancellation policies, dispute resolution, and code of conduct.",
                        ),
                        _AgreementPoint(
                          title: "8. Data Privacy",
                          content:
                              "Your personal and business information will be securely stored and handled in accordance with Adventura’s Privacy Policy.",
                        ),
                        _AgreementPoint(
                          title: "9. Termination Rights",
                          content:
                              "Adventura reserves the right to approve or reject any application and to suspend or terminate provider accounts in case of non-compliance.",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isAccepted,
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.blue;
                        }
                        return isDarkMode ? Colors.white54 : Colors.black54;
                      }),
                      onChanged: (val) => setState(() => isAccepted = val!),
                    ),
                    Expanded(
                      child: Text(
                        "I have read and agree to Adventura’s Provider Terms & Conditions.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isAccepted ? onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Agree & Submit",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgreementPoint extends StatelessWidget {
  final String title;
  final String content;

  const _AgreementPoint({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
