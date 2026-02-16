import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';

import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';

class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({super.key});

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
            '"Appname" Would Like to Send You Notifications',
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
                context.push('/onboardingAllset');

                debugPrint("Denied");
              },

              child: const Text("Don’t Allow"),
            ),

            TextButton(
              style: _dialogButtonStyle(),

              onPressed: () {
                Navigator.pop(context);
                context.push('/onboardingAllset');

                //navigate to the next page ya bibo
                //alb bibo walahi
                debugPrint("Allowed");
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
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.black;
        }
        return Colors.transparent;
      }),

      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return Colors.black;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomAppbar(currentStep: 6, totalSteps: 7),

          const SizedBox(),

          Padding(
            padding: const EdgeInsets.all(20),

            child: ContinueButton(
              onPressed: () {
                // Navigate to next page
                context.push('/onboardingAllset');
              },
            ),
          ),
        ],
      ),
    );
  }
}
