import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom _widget/continue_button.dart';
import 'package:graduation_project/view/custom _widget/custom_appBar.dart';
import 'package:graduation_project/models/user_model.dart';

class OnboardingGoal extends StatefulWidget {
  final UserModel? userModel;

  const OnboardingGoal({super.key, this.userModel});

  @override
  State<OnboardingGoal> createState() => _OnboardingGoalState();
}

class _OnboardingGoalState extends State<OnboardingGoal> {
  int selectedIndex = -1;
  
  final List<String> goals = [
    "Lose Weight",
    "Gain Weight",
    "Maintain Weight",
  ];

  @override
  void initState() {
    super.initState();
    // TEACHER NOTE: If the user came back to this page, show their previous choice
    if (widget.userModel?.goal != null) {
      selectedIndex = goals.indexOf(widget.userModel!.goal!);
    }
  }

  void _updateGoalAndContinue() {
    if (selectedIndex == -1) return;

    // 1. Prepare the model with the existing data plus the new goal
    final currentModel = widget.userModel ?? UserModel();
    final updatedUser = currentModel.copyWith(goal: goals[selectedIndex]);

    // 2. Navigate to the next step
    if (mounted) {
      // Logic: Passing the 'updatedUser' to the next screen via 'extra'
      context.push('/onboardingGoalWeight', extra: updatedUser);
    }
  }

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
              const CustomAppbar(currentStep: 5, totalSteps: 8),

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
                    ? () {} 
                    : _updateGoalAndContinue, 
              ),

              SizedBox(height: screenHeight * 0.1),
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