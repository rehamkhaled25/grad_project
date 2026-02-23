import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';


class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  double heightCm = 170;
  bool isCm = true;

  double rulerHeight = 0;
  double rulerTop = 0;

  /// Convert cm to ft/in
  String getFeetInches() {
    final inches = heightCm / 2.54;
    final feet = inches ~/ 12;
    final inch = (inches % 12).round();
    return "$feet $inch";
  }

  /// Arrow position
  double getArrowY() => rulerTop + ((220 - heightCm) / 120) * rulerHeight;

  /// Update height from dragging
  void updateHeightFromArrow(double posY) {
    double newHeight = 220 - ((posY - rulerTop) / rulerHeight) * 120;
    setState(() {
      heightCm = newHeight.clamp(100, 220);
    });
  }

  @override
  Widget build(BuildContext context) {
    rulerHeight = MediaQuery.of(context).size.height * 0.6;
    rulerTop = MediaQuery.of(context).size.height * 0.25;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// Top progress bar
            const CustomAppbar(currentStep: 3, totalSteps: 7),

            /// Title under appbar
            const Positioned(
              left: 24,
              top: 80,
              child: Text(
                "How tall are you?",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            /// Vertical Ruler
            Positioned(
              right: 0,
              top: rulerTop,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  double newPos = getArrowY() + details.delta.dy;
                  newPos = newPos.clamp(rulerTop, rulerTop + rulerHeight);
                  updateHeightFromArrow(newPos);
                },
                child: SizedBox(
                  height: rulerHeight,
                  width: 80,
                  child: CustomPaint(painter: _VerticalRulerPainter()),
                ),
              ),
            ),

            /// Red arrow
            Positioned(
              right: 80,
              top: getArrowY(),
              child: const Icon(Icons.play_arrow, color: Colors.red, size: 26),
            ),

            /// Number + unit centered to ruler
            Positioned(
              right: 120,
              top: rulerTop + rulerHeight / 2 - 40,
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: isCm
                          ? [
                              TextSpan(
                                text: "${heightCm.toInt()}",
                                style: const TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: " cm",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ]
                          : [
                              TextSpan(
                                text: getFeetInches().split(" ")[0],
                                style: const TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "ft  ",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              TextSpan(
                                text: getFeetInches().split(" ")[1],
                                style: const TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "in",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onHorizontalDragEnd: (_) => setState(() => isCm = !isCm),
                    child: Text(
                      "swipe to ${isCm ? "ft/in" : "cm"}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Continue Button
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  context.go('/onboardingWeight');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  height: 54,
                  width: 384,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical ruler painter
class _VerticalRulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    double y = 0;
    for (int i = 0; i <= size.height / 10; i++) {
      double len = i % 5 == 0 ? size.width * 0.5 : size.width * 0.25;
      canvas.drawLine(
        Offset(size.width - len, y),
        Offset(size.width, y),
        paint,
      );
      y += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
