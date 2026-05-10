import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/view/custom _widget/custom_input_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _authService = ApiService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _showSnackBar(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _authService.login(
          emailController.text, 
          passwordController.text
        );

        if (response.statusCode == 200) {
          AuthState.isLoggedIn = true;
          AuthState.finishedOnboarding = true;
          if (mounted) context.go('/home');
        } else {
          _showSnackBar("Invalid email or password", true);
        }
      } catch (e) {
        _showSnackBar("Server connection failed", true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
                        validator: (value) => value!.isEmpty ? 'Password required' : null,
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
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}