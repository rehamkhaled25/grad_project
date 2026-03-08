import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/services/database_service.dart';
import 'package:graduation_project/models/user_model.dart';

class BirthDateScreen extends StatefulWidget {
  const BirthDateScreen({super.key});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  final DatabaseService _dbService = DatabaseService();
  DateTime selectedDate = DateTime(1995, 6, 15);
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
      
          bool isComplete = userData.gender != null &&
              userData.birthdate != null &&
              userData.height != null &&
              userData.weight != null &&
              userData.goal != null;

          if (isComplete) {
            if (mounted) {
              context.go('/home'); 
              return;
            }
          }

          if (userData.birthdate != null) {
            if (mounted) {
              _navigateToNextMissingStep(userData);
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking birthdate data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _navigateToNextMissingStep(UserModel data) {
    if (data.height == null) {
      context.go('/onboardingHeight');
    } else if (data.weight == null) {
      context.go('/onboardingWeight');
    } else if (data.goal == null) {
      context.go('/onboardingGoal');
    } else {
      context.go('/home');
    }
  }

  Future<void> _saveBirthDateAndContinue() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _dbService.saveUserData(UserModel(
          uid: user.uid,
          birthdate: selectedDate,
          email: user.email ?? "",
        ));

        if (mounted) {
          
          context.go('/onboardingHeight');
        }
      } else {
        throw Exception("No user authenticated");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save birth date: $e"),
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
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppbar(
              currentStep: 2,
              totalSteps: 7,
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Enter Your Birth Date",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Container(
                  height: 350,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        selectedDate = newDate;
                      });
                    },
                    itemExtent: 64,
                    use24hFormat: false,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.black)
                  : ContinueButton(
                      txt: "Continue",
                      onPressed: _saveBirthDateAndContinue,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}