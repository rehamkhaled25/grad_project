import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart'; 
import 'package:graduation_project/services/onboarding_service.dart'; // Added for onboarding sync
import 'package:graduation_project/view/custom _widget/custom_input_field.dart';

class RegisterScreen extends StatefulWidget {
  final UserModel? userModel;
  const RegisterScreen({super.key, this.userModel});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _authService = ApiService(); // Initialize Service

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      print("🚀 [CHECKPOINT 1]: Create Account button clicked.");
      setState(() => _isLoading = true);

      // 1. Update the existing model with final screen data
      final finalUser = widget.userModel ?? UserModel();
      finalUser.fullName = fullNameController.text.trim();
      finalUser.email = emailController.text.trim().toLowerCase();
      finalUser.password = passwordController.text.trim();

      print("📦 [DATA PREP]: Sending User: ${finalUser.email}");

      try {
        // 2. Call the registration service first to get the token[cite: 1]
        print("📡 [CHECKPOINT 2]: Calling ApiService.register...");
        final response = await _authService.register(finalUser);

        print("✅ [CHECKPOINT 3]: Server responded with status: ${response.statusCode}");
        print("📄 [RESPONSE BODY]: ${response.body}");

        if (response.statusCode == 201 || response.statusCode == 200) {
          // LOGIC UPDATE: User is registered, so the token now exists in SharedPreferences.
          // Now sync the onboarding data collected from previous screens.[cite: 1]
          print("🔄 [SYNCING]: Sending onboarding data to database...");
          
          await OnboardingService().saveOnboardingData(
            fullName: finalUser.fullName ?? "User",
            birthdate: finalUser.birthdate ?? "",
            gender: finalUser.gender ?? "",
            goal: finalUser.goal ?? "",
            weight: finalUser.weight ?? 0.0,
            height: finalUser.height ?? 0.0,
          );
          _showSnackBar('Account created successfully!', Colors.green);
          
          AuthState.isLoggedIn = true;
          AuthState.finishedOnboarding = true; 
          
          if (mounted) {
            print("🏠 [NAVIGATION]: Moving to /home");
            context.go('/home'); 
          }
        } else {
          print("❌ [SERVER REJECTION]: Registration failed.");
          _showSnackBar('Registration failed. Email might already exist.', Colors.red);
        }
      } catch (e) {
        print("🔥 [CRITICAL ERROR]: $e");
        _showSnackBar('Connection Error: Check Laptop IP and Firewall.', Colors.red);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      print("⚠️ [VALIDATION]: Form is not valid. Check input fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset('assets/images/logo-78.png', height: 100),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFDFD),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInputField(
                        controller: fullNameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        assetIcon: 'assets/images/Profile.png',
                        validator: (value) => value!.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        assetIcon: 'assets/images/Message.png',
                        validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        assetIcon: 'assets/images/Lock.png',
                        isPassword: true,
                        obscureText: _obscurePassword,
                        toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (value) => value!.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        assetIcon: 'assets/images/Lock.png',
                        isPassword: true,
                        obscureText: _obscureConfirmPassword,
                        toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        validator: (value) => value != passwordController.text ? 'Passwords mismatch' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: screenWidth > 400 ? 400 : double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Account', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}