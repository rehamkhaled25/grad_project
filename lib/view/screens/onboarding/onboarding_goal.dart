import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';


class OnboardingGoal extends StatefulWidget {
  const OnboardingGoal({super.key});

  @override
  State<OnboardingGoal> createState() => _OnboardingGoalState();
}

class _OnboardingGoalState extends State<OnboardingGoal> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const CustomAppbar(currentStep: 5, totalSteps: 7),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.04),

                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "What is your goal?",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.1),

                    GoalWidget(
                      image: "assets/images/apple.png",
                      name: "Lose Weight",
                      isSelected: selectedIndex == 0,
                      onTap: () => setState(() => selectedIndex = 0),
                    ),

                    const SizedBox(height: 24),

                    GoalWidget(
                      image: "assets/images/chocolate-bar.png",
                      name: "Gain Weight",
                      isSelected: selectedIndex == 1,
                      onTap: () => setState(() => selectedIndex = 1),
                    ),

                    const SizedBox(height: 24),

                    GoalWidget(
                      image: "assets/images/trophy.png",
                      name: "Maintain Weight",
                      isSelected: selectedIndex == 2,
                      onTap: () => setState(() => selectedIndex = 2),
                    ),
                  ],
                ),
              ),

             ContinueButton(
  txt: "Continue",
  onPressed: selectedIndex == -1
      ? () {}   // ← empty function → button looks disabled
      : () {
          print("Selected goal index: $selectedIndex");
          context.push('/onboardingNotification');
        },
),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalWidget extends StatelessWidget {
  final String image;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalWidget({
    super.key,
    required this.image,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.black : const Color(0xffEEEEEE),
          border: isSelected ? Border.all(color: Colors.black, width: 1.5) : null,
        ),
        child: Row(
          children: [
            Image.asset(image, width: 32, height: 32),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xff605A5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
