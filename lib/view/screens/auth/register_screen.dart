import 'dart:convert';
 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/onboarding_service.dart';
import 'package:graduation_project/view/custom _widget/custom_input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
class RegisterScreen extends StatefulWidget {
  // The full UserModel collected during onboarding is passed in here from AllSet
  final UserModel? userModel;
  const RegisterScreen({super.key, this.userModel});
 
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
 
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _authService = ApiService();
  final OnboardingService _onboardingService = OnboardingService();
 
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
 
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
 
  @override
  void initState() {
    super.initState();
    // Pre-fill full name if it was collected during onboarding
    if (widget.userModel?.fullName != null) {
      fullNameController.text = widget.userModel!.fullName!;
    }
  }
 
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
 
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      print("⚠️ [VALIDATION]: Form is not valid. Check input fields.");
      return;
    }
 
    print("🚀 [CHECKPOINT 1]: Create Account button clicked.");
    setState(() => _isLoading = true);
 
    try {
      // ── STEP 1: Create the account ────────────────────────────────────────
      final registerUser = UserModel(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text.trim(),
      );
 
      print("📡 [CHECKPOINT 2]: Calling ApiService.register...");
      final response = await _authService.register(registerUser);
 
      print("✅ [CHECKPOINT 3]: Server responded with status: ${response.statusCode}");
      print("📄 [RESPONSE BODY]: ${response.body}");
 
      if (response.statusCode != 201 && response.statusCode != 200) {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Registration failed. Email might already exist.';
        _showSnackBar(message, Colors.red);
        return;
      }
 
      // Save the token returned by the register endpoint
      final data = jsonDecode(response.body);
      await _authService.saveToken(data['token']);

      // Save current user email to SharedPreferences!
      final emailVal = emailController.text.trim().toLowerCase();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_email', emailVal);
 
      // ── STEP 2: Save onboarding data if we have it ────────────────────────
      // widget.userModel holds everything collected from the onboarding screens
      final onboarding = widget.userModel;
      if (onboarding != null &&
          onboarding.gender != null &&
          onboarding.birthdate != null) {
        print("➡️ [ONBOARDING SAVE]: Saving onboarding profile data...");
 
        final saved = await _onboardingService.saveOnboardingData(
          fullName: fullNameController.text.trim(),
          birthdate: onboarding.birthdate ?? '',
          gender: onboarding.gender ?? '',
          goal: onboarding.goal ?? '',
          weight: onboarding.weight ?? 0,
          height: onboarding.height ?? 0,
          goalWeight: onboarding.goalWeight,
          allergies: onboarding.allergies ?? [],
        );
 
        if (!saved) {
          print("⚠️ [ONBOARDING SAVE]: Profile save failed — user can update later.");
          // Non-fatal: we still proceed to the plan screen
        } else {
          print("✅ [ONBOARDING SAVE]: Profile saved successfully.");
        }
      }
 
      // ── STEP 3: Update AuthState and navigate ─────────────────────────────
      AuthState.isLoggedIn = true;
      AuthState.finishedOnboarding = false; // Plan screen comes next
 
      _showSnackBar('Account created! Here\'s your plan.', Colors.green);
 
      if (mounted) {
        print("➡️ [NAVIGATION]: Moving to plan screen");
        context.go('/onboardingPlan');
      }
    } catch (e) {
      print("🔥 [CRITICAL ERROR]: $e");
      _showSnackBar(
        'Connection Error: Check Laptop IP and Firewall.',
        Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              Image.asset('assets/images/nutra_logo.png', height: 100),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFDFD),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
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
                        validator: (value) =>
                            value!.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        assetIcon: 'assets/images/Message.png',
                        validator: (value) =>
                            (value == null || !value.contains('@'))
                                ? 'Invalid email'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        assetIcon: 'assets/images/Lock.png',
                        isPassword: true,
                        obscureText: _obscurePassword,
                        toggleObscure: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (value) =>
                            value!.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        assetIcon: 'assets/images/Lock.png',
                        isPassword: true,
                        obscureText: _obscureConfirmPassword,
                        toggleObscure: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        validator: (value) => value != passwordController.text
                            ? 'Passwords mismatch'
                            : null,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Account',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
