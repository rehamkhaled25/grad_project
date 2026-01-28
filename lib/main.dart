import 'package:flutter/material.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
import 'package:graduation_project/view/screens/onboarding/splash.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        
        title: 'Cal Ai',
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      
      );

   

  }
}
