import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';

import 'package:graduation_project/view/screens/database/database_search.dart';
import 'package:graduation_project/view/screens/database/servings_database.dart';
import 'package:graduation_project/view/screens/home/badges.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/home/log_food.dart';
import 'package:graduation_project/view/screens/onboarding/allergies.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
import 'package:graduation_project/view/screens/onboarding/screen_height.dart';
import 'package:graduation_project/view/screens/onboarding/screen_weight.dart';
import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';
import 'package:graduation_project/view/screens/payment/CameraAiUpgrade.dart';
import 'package:graduation_project/view/screens/payment/creditcardinfo.dart';
import 'package:graduation_project/view/screens/payment/payment_application.dart';
import 'package:graduation_project/view/screens/plan/plan.dart';
import 'package:graduation_project/view/screens/plan/premium_plan.dart';
import 'package:graduation_project/view/screens/progress/weekly_progress.dart';
import 'package:graduation_project/view/screens/settings/settings_screen.dart';
import 'firebase_options.dart'; 

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final String androidApiKey = dotenv.get(
    'FIREBASE_ANDROID_API_KEY',
    fallback: '',
  );

  final FirebaseOptions customizedOptions = FirebaseOptions(
    apiKey: androidApiKey,
    appId: DefaultFirebaseOptions.currentPlatform.appId,
    messagingSenderId: DefaultFirebaseOptions.currentPlatform.messagingSenderId,
    projectId: DefaultFirebaseOptions.currentPlatform.projectId,
    storageBucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
    iosBundleId: DefaultFirebaseOptions.currentPlatform.iosBundleId, 
  );

  await Firebase.initializeApp(options: customizedOptions);

  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nutra',

      routerConfig: AppRouter.router,
      // // home:DatabaseSearch() ,


      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Figtree'),
      
      
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
           
            textScaler: TextScaler.noScaling, 
          ),
          child: child!,
        );
      },
    
      // home: const SignInScreen(),
    );
  }
}