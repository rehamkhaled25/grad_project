import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final bool showBackButton;

  const CustomAppbar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Define responsive constants
    // 0.04 represents 4% of the screen width for side padding
    final double sidePadding = screenWidth * 0.0015; 
    final double barHeight = 8.0; 
    final double iconSize = screenWidth * 0.07; // Scales icon based on screen size

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 10),
        child: Row(
          children: [
            if (showBackButton)
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    Navigator.maybePop(context);
                  }
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: iconSize,
                ),
              )
            else
              SizedBox(width: iconSize),

            SizedBox(width: screenWidth * 0.03), // Responsive gap

            Expanded(
              child: Stack(
                children: [
                  // Background Track
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(barHeight),
                    ),
                  ),
                  // Progress Fill
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: barHeight,
                        width: constraints.maxWidth * ((currentStep + 1) / totalSteps),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(barHeight),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // This invisible box balances the back button so the bar stays centered
            SizedBox(width: iconSize * 0.5), 
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}