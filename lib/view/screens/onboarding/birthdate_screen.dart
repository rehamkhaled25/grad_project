import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:intl/intl.dart'; // Ensure you have intl in pubspec.yaml for formatting

class BirthDateScreen extends StatefulWidget {
  final UserModel? userModel;
  const BirthDateScreen({super.key, this.userModel});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime selectedDate = DateTime(1995, 6, 25);
  bool _isSaving = false;

  void _onContinue() {
    setState(() => _isSaving = true);

    // Format the date to "YYYY-MM-DD" string to match your UserModel and Flask DB
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Retrieve current model and update the birthdate field
    final currentModel = widget.userModel ?? UserModel();
    final updatedUser = currentModel.copyWith(birthdate: formattedDate);

    // Move to the next onboarding screen (Height) with the updated model
    context.push('/onboardingHeight', extra: updatedUser);

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppbar(
              currentStep: 2,
              totalSteps: 9,
              showBackButton: true,
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Enter Your Birthdate",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: height * 0.04),
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
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black))
                  : ContinueButton(
                      txt: "Continue",
                      onPressed: _onContinue,
                    ),
            ),
            SizedBox(height: height * 0.1),
          ],
        ),
      ),
    );
  }
}