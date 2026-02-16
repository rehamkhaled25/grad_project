import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_input_field.dart';
import 'package:graduation_project/view/custom%20_widget/social_image_button.dart';
import 'sign_in_screen.dart'; // your sign in screen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                  image: const DecorationImage(
                    image: AssetImage('assets/images/Rectangle 285.png'),
                    fit: BoxFit.cover,
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        controller: fullNameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        assetIcon: 'assets/images/Profile.png',
                        validator: (value) =>
                            value!.isEmpty ? 'Full name cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        assetIcon: 'assets/images/Message.png',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email cannot be empty';
                          if (!value.contains('@'))
                            return 'Enter a valid email address';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        assetIcon: 'assets/images/Lock.png',
                        isPassword: true,
                        obscureText: _obscurePassword,
                        toggleObscure: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: (value) =>
                            value!.length < 6 ? 'Password too short' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        assetIcon: 'assets/images/Lock.png',
                        isPassword: true,
                        obscureText: _obscureConfirmPassword,
                        toggleObscure: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                        validator: (value) => value != passwordController.text
                            ? 'Passwords do not match'
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
                  // In your RegisterScreen, after successful registration:
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Set registration state
                      AuthState.isRegistered = true;
                      AuthState.finishedOnboarding = false;

                      // Navigate to onboarding gender
                      context.go('/onboardingGender');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registering...')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              //------------------ DIVIDER ------------------
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Or continue with'),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialImageButton(
                    imagePath: 'assets/images/Card.png',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 24),
                  SocialImageButton(
                    imagePath: 'assets/images/mdi_apple.png',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 24),
                  SocialImageButton(
                    imagePath: 'assets/images/logos_facebook.png',
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: const TextStyle(
                    color: Color(0xFF7C7C7E),
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.go('/login'); // navigate to onboarding
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
