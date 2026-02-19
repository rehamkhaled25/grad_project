import 'package:flutter/material.dart';
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
      body: Column(
        children: [
          CustomAppbar(),

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
                borderColor: const Color(0xff5F68E8),
                iconColor: const Color(0xff5F68E8),
              ),
              const SizedBox(width: 30),
              genderButton(
                icon: Icons.female,
                label: "Female",
                gender: "female",
                borderColor: const Color(0xffFF5878),
                iconColor: const Color(0xffFF5878),
              ),
            ],
          ),

          const Spacer(flex: 3),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: 384,
              height: 54,
              child: ElevatedButton(
                onPressed: selectedGender == null
                    ? null
                    : () {
                        // Save gender if needed
                        print("Selected Gender: $selectedGender");

                        // Navigation to Home
                        // context.go('/home');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,

                  disabledBackgroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
    required Color borderColor,
    required Color iconColor,
  }) {
    bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() => selectedGender = gender);
      },
      child: Container(
        width: 170,
        height: 189,
        decoration: BoxDecoration(
          color: const Color(0xffDDDDDD),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: borderColor, width: 3) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 69, color: isSelected ? iconColor : Colors.black),
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? iconColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
