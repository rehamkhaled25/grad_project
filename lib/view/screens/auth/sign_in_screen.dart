import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/services/auth_service.dart';
import 'package:graduation_project/services/database_service.dart'; 
import 'package:graduation_project/models/user_model.dart';    

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  
  Future<void> _handleUserRouting(User user) async {
    try {
      UserModel? userData = await _dbService.getUserData(user.uid);

      if (!mounted) return;

     
      AuthState.isLoggedIn = true;
      AuthState.isRegistered = true;

      if (userData == null) {
       
        AuthState.finishedOnboarding = false;
        context.go('/onboardingGender');
        return;
      }

     
      if (userData.weight != null) {
        AuthState.finishedOnboarding = true;
        context.go('/home');
      } 
    
      // else if (userData.notificationsEnabled != null) {
      //   context.go('/onboardingAllset');
      // }
      
      else if (userData.weight != null) {
        context.go('/onboardingGoal');
      }
    
      else if (userData.birthdate != null) {
        context.go('/onboardingWeight');
      }
      
      else if (userData.height != null) {
        context.go('/onboardingBirthdate');
      }
      
      else if (userData.gender != null) {
        context.go('/onboardingHeight');
      } 
     
      else {
        AuthState.finishedOnboarding = false;
        context.go('/onboardingGender');
      }
    } catch (e) {
      
      if (mounted) {
        AuthState.isLoggedIn = true;
        AuthState.finishedOnboarding = false;
        context.go('/onboardingGender');
      }
    }
  }

  void _handleEmailLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final User? user = await _authService.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (mounted) setState(() => _isLoading = false);

      if (user != null) {
        _showSnackBar("Login Successful!");
        await _handleUserRouting(user);
      } else {
        _showSnackBar("Login failed. Check your credentials.", isError: true);
      }
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final UserCredential? userCred = await _authService.signInWithGoogle();
      if (mounted) setState(() => _isLoading = false);

      if (userCred != null && userCred.user != null) {
        _showSnackBar("Google Sign-In Successful!");
        await _handleUserRouting(userCred.user!);
      } else {
        _showSnackBar("Google Sign-In cancelled.", isError: true);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("An unexpected error occurred: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IgnorePointer(
        ignoring: _isLoading,
        child: Stack(
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
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) => (value == null || value.length < 6) ? 'Password must be 6+ chars' : null,
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
                        onPressed: _handleEmailLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Login In', style: TextStyle(fontSize: 16)),
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
                        _socialButton('assets/images/Card.png', _handleGoogleLogin),
                        const SizedBox(width: 24),
                        _socialButton('assets/images/mdi_apple.png', () {}),
                        const SizedBox(width: 24),
                        _socialButton('assets/images/logos_facebook.png', () {}),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        text: 'Don\'t have an account? ',
                        style: const TextStyle(color: Color(0xFF7C7C7E), fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: 'Get Started',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => context.go('/register'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Image.asset(assetPath, height: 40),
    );
  }
}