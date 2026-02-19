import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';


class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({super.key});

  @override
  State<NotificationPermissionPage> createState() => _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage> {
  @override
  void initState() {
    super.initState();
    // Show dialog automatically after first frame
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
                debugPrint("Notifications: Denied");
              },
              child: const Text("Don’t Allow"),
            ),
            TextButton(
              style: _dialogButtonStyle(),
              onPressed: () {
                Navigator.pop(context);
                context.push('/onboardingAllset');
                debugPrint("Notifications: Allowed");
                // TODO: Add real permission request here later (e.g. permission_handler package)
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
        return states.contains(MaterialState.pressed) ? Colors.black : Colors.transparent;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.pressed) ? Colors.white : Colors.black;
      }),
      overlayColor: MaterialStateProperty.all(Colors.black12),
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

      
          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: ContinueButton(
              txt: "Continue",
              onPressed: () {
                // If dialog was somehow dismissed → show it again
                // Or just navigate directly — your choice
                _showPermissionDialog();
                // Alternative (if you want to skip dialog on button press):
                // context.push('/onboardingAllset');
              },
            ),
          ),
        ],
      ),
    );
  }
}