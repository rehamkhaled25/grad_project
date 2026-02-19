import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';

class AllSet extends StatefulWidget {
  const AllSet({super.key});

  @override
  State<AllSet> createState() => _AllSetState();
}

class _AllSetState extends State<AllSet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rocketAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rocketAnimation = Tween<double>(
      begin: 400,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Change from Timer to manual navigation via button
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppbar(
            currentStep: 7,
            totalSteps: 7,
          ), // Update steps as needed
          const Spacer(),
          AnimatedBuilder(
            animation: _rocketAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _rocketAnimation.value),
                child: child,
              );
            },
            child: Image.asset('assets/images/space rocket.png', height: 180),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 10,
                backgroundColor: Color(0xff0E683E),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 6),
              const Text(
                'All done!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Time to generate\nyour custom plan!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),

          // Add Continue Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Use pushReplacement to replace current screen
                  context.pushReplacement('/subscription');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
