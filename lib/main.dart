import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';
import 'package:graduation_project/view/screens/payment/CameraAiUpgrade.dart';
import 'package:graduation_project/view/screens/payment/creditcardinfo.dart';
import 'package:graduation_project/view/screens/plan/plan.dart';
import 'package:graduation_project/view/screens/plan/premium_plan.dart';
import 'firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load your .env file
  await dotenv.load(fileName: ".env");

  // 2. Get the API key from .env
  // Make sure your .env file has the line: FIREBASE_ANDROID_API_KEY=AIza...
  final String androidApiKey = dotenv.get('FIREBASE_ANDROID_API_KEY', fallback: '');

  // 3. Create a custom configuration by copying the default ones 
  // and overriding the apiKey with your secret variable.
  final FirebaseOptions customizedOptions = FirebaseOptions(
    apiKey: androidApiKey, 
    appId: DefaultFirebaseOptions.currentPlatform.appId,
    messagingSenderId: DefaultFirebaseOptions.currentPlatform.messagingSenderId,
    projectId: DefaultFirebaseOptions.currentPlatform.projectId,
    storageBucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
    iosBundleId: DefaultFirebaseOptions.currentPlatform.iosBundleId, // Needed if you run on iOS
  );
  
  await Firebase.initializeApp(
    options: customizedOptions,
  );

  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cal Ai',
      // routerConfig: AppRouter.router,
      home:Creditcardinfo() ,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Figtree'),
    );

  }

}