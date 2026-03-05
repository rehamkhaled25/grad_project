import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool moveToCenter = false;
  bool changeBackground = false;
  bool showContent = false;

  @override
  void initState() {
    super.initState();

    // Move avocado from top to center after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => moveToCenter = true);
    });

    // Change background to white after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      setState(() => changeBackground = true);
    });

    // Show text and buttons after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() => showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: changeBackground ? Colors.white : Colors.red,
      body: Stack(
        children: [
          // Center the avocado properly
          Center(
            child: AnimatedAlign(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              // Start at top, move to center
              alignment: moveToCenter
                  ? Alignment.center
                  : const Alignment(0, -1.5), // Adjusted to start from top
              child: Image.asset('assets/images/Avocado.png', height: 150),
            ),
          ),

          // Text and buttons positioned below the avocado
          if (showContent)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Adjust this value as needed
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Track.Eat.Repeat.
                    const Text(
                      "Track.Eat.Repeat.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color(0xFF000000),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Get Started Button
                    SizedBox(
                      width: 384,
                      height: 54,
                      child: Opacity(
                        opacity: 0.84,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000000),
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

                    // Already have account? Sign in
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
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
        ],
      ),
    );
  }
}
