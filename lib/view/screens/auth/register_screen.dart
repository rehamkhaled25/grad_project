import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/auth_service.dart';
import 'package:graduation_project/services/database_service.dart';
import 'package:graduation_project/view/custom%20_widget/custom_input_field.dart';
import 'package:graduation_project/view/custom%20_widget/social_image_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  
  Future<void> _createUserProfile(User user, String name) async {
    UserModel newUser = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: name, 
    );
    await _dbService.saveUserData(newUser);
  }

 
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
       
        final User? user = await _authService.registerUser(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (user != null) {
       
          await _createUserProfile(user, fullNameController.text.trim());
          
          if (!mounted) return;
          _showSnackBar('Account created successfully!', Colors.green);
          
        
          AuthState.isLoggedIn = true;
          AuthState.isRegistered = true; 
          AuthState.finishedOnboarding = false; 
          context.go('/onboardingGender');
        } else {
          _showSnackBar('Registration failed. Email might be in use.', Colors.red);
        }
      } catch (e) {
        _showSnackBar('An error occurred during registration.', Colors.red);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

 
  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final UserCredential? userCred = await _authService.signInWithGoogle();

      if (userCred != null && userCred.user != null) {
       
        await _createUserProfile(
          userCred.user!, 
          userCred.user!.displayName ?? 'New User'
        );

        if (!mounted) return;
        _showSnackBar('Signed in with Google successfully!', Colors.green);
        
        AuthState.isLoggedIn = true;
        AuthState.isRegistered = true; 
        AuthState.finishedOnboarding = false; 
        context.go('/onboardingGender');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Google Login failed.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
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
                              if (value == null || value.isEmpty) return 'Email cannot be empty';
                              if (!value.contains('@')) return 'Enter a valid email address';
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
                            toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                            validator: (value) =>
                                value!.length < 6 ? 'Password must be at least 6 characters' : null,
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
                            validator: (value) {
                              if (value != passwordController.text) return 'Passwords do not match';
                              return null;
                            },
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
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
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
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
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
                      style: const TextStyle(color: Color(0xFF7C7C7E), fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () => context.go('/login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
        ],
      ),
    );
  }
}