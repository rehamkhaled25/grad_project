import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/services/database_service.dart';
import 'package:graduation_project/models/user_model.dart';

class OnboardingGender extends StatefulWidget {
  const OnboardingGender({super.key});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender> {
  final DatabaseService _dbService = DatabaseService();
  String? selectedGender;
  bool _isSaving = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _checkExistingData();
  }

  Future<void> _checkExistingData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        UserModel? userData = await _dbService.getUserData(user.uid);

        if (userData != null) {
          // 1. If everything is filled, go to Home (Profile)
          bool isComplete = userData.gender != null &&
              userData.birthdate != null &&
              userData.height != null &&
              userData.weight != null &&
              userData.goal != null;

          if (isComplete) {
            if (mounted) context.go('/home');
            return;
          }

          // 2. Resume Logic: Check fields in order of the flow
          if (userData.gender != null && userData.gender!.isNotEmpty) {
            if (mounted) {
              // Gender is done, check next step or navigate to it
              // This logic should be repeated in each onboarding screen's initState
              _navigateToNextMissingStep(userData);
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking onboarding progress: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _navigateToNextMissingStep(UserModel data) {
    if (data.gender == null) {
      
    } else if (data.birthdate == null) {
      context.go('/onboardingBirthdate');
    } else if (data.height == null) {
      context.go('/onboardingHeight');
    } else if (data.weight == null) {
      context.go('/onboardingWeight');
    } else if (data.goal == null) {
      context.go('/onboardingGoal');
    } else {
      context.go('/home');
    }
  }

  Future<void> _saveGenderAndContinue() async {
    if (selectedGender == null) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
     
        await _dbService.saveUserData(UserModel(
          uid: user.uid,
          gender: selectedGender,
          email: user.email ?? "",
        ));

        if (mounted) {
          
          context.go('/onboardingBirthdate');
        }
      } else {
        throw Exception("No user authenticated");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save gender: $e"),
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
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

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
                        selectedGender == null ? () {} : _saveGenderAndContinue,
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