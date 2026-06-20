import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/models/user_model.dart';

class OnboardingGender extends StatefulWidget {
  final UserModel? userModel; 
  const OnboardingGender({super.key, this.userModel});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender> {
  String? selectedGender;
  bool _isSaving = false;

  void _onContinue() {
    if (selectedGender == null) return;

    setState(() => _isSaving = true);
    
   
    final currentModel = widget.userModel ?? UserModel();
    
  
    final updatedUser = currentModel.copyWith(gender: selectedGender);

    context.push('/onboardingBirthdate', extra: updatedUser);

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppbar(
            currentStep: 1,
            totalSteps: 9,
            showBackButton: true,
            onBack: () => context.go('/splash'),
          ),
          SizedBox(height: height * 0.04),
          const Text(
            'Choose your gender',
            style: TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: genderButton(
                    icon: Icons.male,
                    label: "Male",
                    gender: "male",
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: genderButton(
                    icon: Icons.female,
                    label: "Female",
                    gender: "female",
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _isSaving
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black))
                : ContinueButton(
                    txt: "Continue",
                    onPressed:
                        selectedGender == null ? () {} : _onContinue,
                  ),
          ),
          SizedBox(height: height * 0.1),
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
        height: 189,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 239, 239),
          borderRadius: BorderRadius.circular(12),
       
         
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
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}