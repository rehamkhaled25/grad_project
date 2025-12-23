import 'package:flutter/material.dart';
import 'package:graduation_project/screens/onboarding_gender.dart';
// import 'package:firebase_core/firebase_core.dart';


// import 'package:firebase_auth/firebase_auth.dart';
 // Assuming LoginPage is in a separate file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        
        title: 'Cal Ai',
        home: OnboardingGender(),
        debugShowCheckedModeBanner: false,
      
      );
  }
}