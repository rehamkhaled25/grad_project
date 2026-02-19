// import 'package:flutter/material.dart';

// class CustomAppbar extends StatelessWidget {
//   const CustomAppbar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const double sidePadding = 20.0;
//     final double progressBarWidth =
//         MediaQuery.of(context).size.width - (sidePadding * 2) - 80;
//     return  Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.maybePop(context),
//                     icon: const Icon(Icons.arrow_back, color: Colors.black),
//                   ),
//                   Expanded(
//                     child: Container(
//                       height: 6,
//                       margin: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: const Color(0x33787878),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       child: Stack(
//                         children: [
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Container(
//                               width: progressBarWidth * 0.1,
//                               height: 6,
//                               decoration: BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.circular(3),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 ],
//               );
//   }
// }
// custom_widget/custom_appbar.dart
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool showBackButton;

  const CustomAppbar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 48), // Placeholder for alignment

          Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0x33787878),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentStep + 1) / totalSteps,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.language, color: Colors.black, size: 24),
            onPressed: () {}, // Add language selection logic
          ),
        ],
      ),
    );
  }
}
