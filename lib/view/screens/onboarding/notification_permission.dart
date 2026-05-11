import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/models/user_model.dart'; // Import your model
import 'package:graduation_project/view/custom _widget/continue_button.dart';
import 'package:graduation_project/view/custom _widget/custom_appBar.dart';

class NotificationPermissionPage extends StatefulWidget {
  // 1. Accept the userModel from the previous screen (Goal Weight)
  final UserModel? userModel;

  const NotificationPermissionPage({super.key, this.userModel});

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPermissionDialog();
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            '"Cal Ai" Would Like to Send You Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Notifications may include alerts, sounds, and icon badges. '
            'These can be configured in Settings.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              style: _dialogButtonStyle(),
              onPressed: () {
                Navigator.pop(context);
               
                context.push('/onboardingAllset', extra: widget.userModel);
                debugPrint("Notifications: Denied");
              },
              child: const Text("Don’t Allow"),
            ),
            TextButton(
              style: _dialogButtonStyle(),
              onPressed: () {
                Navigator.pop(context);
                // 2. Pass the model forward to All Set
                context.push('/onboardingAllset', extra: widget.userModel);
                debugPrint("Notifications: Allowed");
              },
              child: const Text("Allow"),
            ),
          ],
        );
      },
    );
  }

  ButtonStyle _dialogButtonStyle() {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? Colors.black
            : Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? Colors.white
            : Colors.black;
      }),
      overlayColor: WidgetStateProperty.all(Colors.black12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomAppbar(currentStep: 9, totalSteps: 9),

          const Spacer(),

          // Padding(
          //   padding: const EdgeInsets.all(20),
          //   child: ContinueButton(
          //     txt: "Continue",
          //     onPressed: () {
          //       _showPermissionDialog();
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}