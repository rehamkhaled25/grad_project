import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';


class OnboardingGender extends StatefulWidget {
  const OnboardingGender({super.key});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppbar(
            currentStep: 1,
            totalSteps: 7,
            showBackButton: false,
          ),

          const SizedBox(height: 40),

          const Text(
            'Choose your Gender',
            style: TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Spacer(flex: 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              genderButton(
                icon: Icons.male,
                label: "Male",
                gender: "male",
              ),
              const SizedBox(width: 30),
              genderButton(
                icon: Icons.female,
                label: "Female",
                gender: "female",
              ),
            ],
          ),

          const Spacer(flex: 3),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ContinueButton(
    txt: "Continue",
    onPressed: selectedGender == null
        ? () {}                             // ← empty function = disabled look
        : () {
            // print("Selected Gender: $selectedGender");
            context.push('/onboardingBirthdate');
          },
  ),
),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget genderButton({
    required IconData icon,
    required String label,
    required String gender,
  }) {
    final bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        width: 183,
        height: 189,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 239, 239),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xffF20D0D), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected ? const Color(0xffF20D0D) : Colors.black87,
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xffF20D0D) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}