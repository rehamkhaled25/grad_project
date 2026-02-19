import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/view/screens/auth/register_screen.dart';
import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
import 'package:graduation_project/view/screens/home/home_screen.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
import 'package:graduation_project/view/screens/onboarding/splash.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart'; // For routing

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cal Ai',
      // Setup routes for navigation
      home: RegisterScreen(),
      debugShowCheckedModeBanner: false,
      // Routing configuration with GoRouter
      // Customize your routing here for different screens
      routes: {
        '/signup': (context) => const RegisterScreen(),
        '/onboard': (context) => const OnboardingGoal(),
        '/login': (context) => const SignInScreen(),
      },
    );
  }
}
