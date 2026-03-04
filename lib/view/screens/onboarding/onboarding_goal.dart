import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/services/database_service.dart';
import 'package:graduation_project/models/user_model.dart';

class OnboardingGoal extends StatefulWidget {
  const OnboardingGoal({super.key});

  @override
  State<OnboardingGoal> createState() => _OnboardingGoalState();
}

class _OnboardingGoalState extends State<OnboardingGoal> {
  final DatabaseService _dbService = DatabaseService();
  int selectedIndex = -1;
  bool _isSaving = false;

  // List of goals to map index to a string for Firebase
  final List<String> goals = [
    "Lose Weight",
    "Gain Weight",
    "Maintain Weight",
  ];

  /// NEW: Logic to save goal to Firebase
  Future<void> _saveGoalAndContinue() async {
    if (selectedIndex == -1) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
       
        await _dbService.saveUserData(UserModel(
          uid: user.uid,
          goal: goals[selectedIndex], 
          email: user.email ?? "",
        ));

        if (mounted) {
       
          context.push('/onboardingNotification');
        }
      } else {
        throw Exception("No user authenticated");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save goal: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              const CustomAppbar(currentStep: 5, totalSteps: 7),

             
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

          
              _isSaving
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : ContinueButton(
                      txt: "Continue",
                      onPressed: selectedIndex == -1 
                          ? () {} 
                          : _saveGoalAndContinue,
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