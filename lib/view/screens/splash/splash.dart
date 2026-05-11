// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/core/app_router.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   bool moveToCenter = false;
//   bool changeBackground = false;
//   bool showContent = false;

//   @override
//   void initState() {
//     super.initState();

//     // Move avocado from top to center after 2 seconds
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() => moveToCenter = true);
//     });

//     // Change background to white after 4 seconds
//     Future.delayed(const Duration(seconds: 4), () {
//       setState(() => changeBackground = true);
//     });

//     // Show text and buttons after 5 seconds
//     Future.delayed(const Duration(seconds: 5), () {
//       setState(() => showContent = true);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width=MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: changeBackground ? Colors.white : Colors.red,
//       body: Stack(
//         children: [
//           // Center the avocado properly
//           Center(
//             child: AnimatedAlign(
//               duration: const Duration(seconds: 2),
//               curve: Curves.easeInOut,
//               // Start at top, move to center
//               alignment: moveToCenter
//                   ? Alignment.center
//                   : const Alignment(0, -1.5), // Adjusted to start from top
//               child: Image.asset('assets/images/Avocado.png', height: 150),
//             ),
//           ),

//           // Text and buttons positioned below the avocado
//           if (showContent)
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                   bottom: 100,
//                 ), // Adjust this value as needed
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Track.Eat.Repeat.
//                     const Text(
//                       "Track.Eat.Repeat.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w400,
//                         fontSize: 15,
//                         color: Color.fromARGB(255, 0, 0, 0),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // Get Started Button
//                     SizedBox(
//                       width: 384,
//                       height: 54,
//                       child: Opacity(
//                         opacity: 0.84,
//                         child: Padding(
//                           padding:  EdgeInsets.symmetric(horizontal: width*0.05),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               AuthState.hasSeenSplash = true;
//                               context.go('/onboardingGender');
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:  Colors.black,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(27),
//                               ),
//                             ),
//                             child: const Text(
//                               "Get Started",
//                               style: TextStyle(
//                                 fontFamily: 'Figtree',
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                                 color: Colors.white,
//                                 height: 1.5,
//                                 letterSpacing: -1.1,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     // Already have account? Sign in
//                     GestureDetector(
//                       onTap: () {
//                         context.go('/login');
//                       },
//                       child: const Text(
//                         "Already have an account? Sign in",
//                         style: TextStyle(
//                           fontFamily: 'Figtree',
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                           height: 1.5,
//                           letterSpacing: -1.1,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/onboarding_service.dart';
 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
 
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
 
class _SplashScreenState extends State<SplashScreen> {
  bool moveToCenter = false;
  bool changeBackground = false;
  bool showContent = false;
 
  // Whether we found a logged-in returning user (hides buttons, shows spinner)
  bool _checkingSession = true;
 
  @override
  void initState() {
    super.initState();
 
    // Run the animation sequence
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => moveToCenter = true);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => changeBackground = true);
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => showContent = true);
    });
 
    // Simultaneously check if the user is already logged in
    _checkExistingSession();
  }
 
  Future<void> _checkExistingSession() async {
    final token = await ApiService().getToken();
 
    if (token == null) {
      // No token → new user, show splash buttons normally
      if (mounted) setState(() => _checkingSession = false);
      return;
    }
 
    // Token exists → fetch profile to confirm it's still valid
    print("🔀 [SPLASH] Token found, checking profile...");
    final user = await OnboardingService().getUserProfile();
 
    if (!mounted) return;
 
    if (user == null) {
      // Token expired or invalid → treat as new user
      print("🔀 [SPLASH] Token invalid → show splash buttons");
      setState(() => _checkingSession = false);
      return;
    }
 
    // Valid token + profile → skip splash buttons and go straight to home
    final bool onboardingDone =
        user.gender != null &&
        user.gender!.isNotEmpty &&
        user.gender != "N/A" &&
        user.goal != null &&
        user.goal!.isNotEmpty &&
        user.goal != "N/A";
 
    AuthState.isLoggedIn = true;
    AuthState.finishedOnboarding = onboardingDone;
 
    // Wait for animations to finish before navigating (min 5s splash)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
 
    if (onboardingDone) {
      print("🔀 [SPLASH] Returning user, onboarding done → /home");
      context.go('/home');
    } else {
      print("🔀 [SPLASH] Returning user, onboarding incomplete → /login");
      context.go('/login');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
 
    return Scaffold(
      backgroundColor: changeBackground ? Colors.white : Colors.red,
      body: Stack(
        children: [
          // Avocado animation
          Center(
            child: AnimatedAlign(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              alignment: moveToCenter
                  ? Alignment.center
                  : const Alignment(0, -1.5),
              child: Image.asset('assets/images/Avocado.png', height: 150),
            ),
          ),
 
          // Buttons — only shown for NEW users (no saved token)
          if (showContent && !_checkingSession)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Track.Eat.Repeat.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
 
                    // Get Started → goes to onboarding (no account yet)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            // Start onboarding with a blank model
                            context.go('/onboardingGender');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.5,
                              letterSpacing: -1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
 
                    const SizedBox(height: 15),
 
                    // Already have account → sign in
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        "Already have an account? Sign in",
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.5,
                          letterSpacing: -1.1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
 
          // Loading spinner shown while checking token (returning user)
          if (showContent && _checkingSession)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 120),
                child: CircularProgressIndicator(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}