// view/screens/onboarding/birthdate_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';

class BirthDateScreen extends StatefulWidget {
  const BirthDateScreen({super.key});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime selectedDate = DateTime(1995, 6, 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppbar(
              currentStep: 2, // Adjust based on your flow
              totalSteps: 7, // Total onboarding steps
            ),

            const SizedBox(height: 40),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Enter Your Birth Date",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 40),

            // Date Picker
            Expanded(
              child: Center(
                child: Container(
                  height: 350,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
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

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ContinueButton(
                txt: "Continue",
                onPressed: () {
                  // Navigate to next screen (Weight)
                  context.push('/onboardingHeight');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
