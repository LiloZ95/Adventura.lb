import 'dart:ui';
import 'package:flutter/material.dart';

class SecurityPrivacyPage extends StatefulWidget {
  const SecurityPrivacyPage({super.key});

  @override
  State<SecurityPrivacyPage> createState() => _SecurityPrivacyPageState();
}

class _SecurityPrivacyPageState extends State<SecurityPrivacyPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool isPasswordVisible = false;
  bool isConfirmVisible = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFEAF2FB),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDarkMode ? Colors.white : Colors.blue,
                      size: 24,
                    ),
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 500),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.06)
                                : Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white,
                                    child: const Icon(Icons.shield_rounded,
                                        size: 20, color: Color(0xFF3B82F6)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Security & Privacy",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              _buildInputField(
                                controller: emailController,
                                label: "New Email",
                                icon: Icons.email_outlined,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 20),

                              _buildPasswordField(
                                controller: passwordController,
                                label: "New Password",
                                visible: isPasswordVisible,
                                toggle: () => setState(() =>
                                    isPasswordVisible = !isPasswordVisible),
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 20),

                              _buildPasswordField(
                                controller: confirmController,
                                label: "Confirm Password",
                                visible: isConfirmVisible,
                                toggle: () => setState(() =>
                                    isConfirmVisible = !isConfirmVisible),
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 30),

                              _buildGradientButton(
                                label: "Save Changes",
                                onPressed: () {
                                  _showSuccess("Changes saved successfully!");
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Focus(
      onFocusChange: (_) => setState(() {}),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF3B82F6),
              width: 2,
            ),
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback toggle,
    required bool isDarkMode,
  }) {
    return Focus(
      onFocusChange: (_) => setState(() {}),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueGrey),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              visible ? Icons.visibility : Icons.visibility_off,
              color: Colors.blueAccent,
            ),
          ),
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF3B82F6),
              width: 2,
            ),
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.blueAccent.withOpacity(0.2),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
