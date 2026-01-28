import 'package:flutter/material.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/screens/trialsubscriptionpage.dart';


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
        home: TrialSubscriptionPage(),
        debugShowCheckedModeBanner: false,
      
      );

   

  }
}
