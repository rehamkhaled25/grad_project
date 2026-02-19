import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/onboarding/allset.dart';
import 'package:graduation_project/view/screens/onboarding/notification_permission.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
import 'package:graduation_project/view/screens/onboarding/splash.dart';
import 'package:graduation_project/view/screens/payment/creditcardinfo.dart';
import 'package:graduation_project/view/screens/payment/payment_application.dart';



=======
import 'package:graduation_project/core/app_router.dart';
>>>>>>> 9f35d034f33c9a1dfd88a24d466173ee7b142dbb

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
        home: Creditcardinfo(),
        debugShowCheckedModeBanner: false,
      
      );

   

=======
    return MaterialApp.router(
      title: 'Cal Ai',
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
>>>>>>> 9f35d034f33c9a1dfd88a24d466173ee7b142dbb
  }
}
