import 'package:flutter/material.dart';
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
           padding: const EdgeInsets.all(20.0),
           child: ContinueButton(onPressed: (){}, txt: "Continue"),
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
    bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() => selectedGender = gender);
      },
      child: Container(
        width: 183,
        height: 189,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 239, 239),
          borderRadius: BorderRadius.circular(12),
          
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: isSelected ? Color(0xffF20D0D) : Colors.black),
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color:  Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
