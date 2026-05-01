import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/models/user_model.dart';

class HeightScreen extends StatefulWidget {
  final UserModel? userModel;
  const HeightScreen({super.key, this.userModel});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  double heightCm = 185;
  bool isCm = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Logic: Initialize height from existing model if available
    if (widget.userModel?.height != null) {
      heightCm = widget.userModel!.height!;
    }
  }

  String getFeetInches() {
    final double inches = heightCm / 2.54;
    final int feet = inches ~/ 12;
    final int inch = (inches % 12).round();
    return "$feet $inch";
  }

  String getSelectionValue() {
    if (isCm) return "${heightCm.toInt()}";
    return getFeetInches().split(" ")[0]; 
  }

  double getArrowY(double rulerActualHeight) {
    return ((220 - heightCm) / 120) * rulerActualHeight;
  }

  void updateHeightFromArrow(double posY, double rulerActualHeight) {
    double newHeight = 220 - (posY / rulerActualHeight) * 120;
    setState(() {
      heightCm = newHeight.clamp(100, 220);
    });
  }

  void _onContinue() async {
    setState(() => _isSaving = true);
    
    // Logic: Get current model or initialize new one, then copy with height
    final currentModel = widget.userModel ?? UserModel();
    final updatedUser = currentModel.copyWith(height: heightCm);
    
    // Pass the updated model to the next onboarding screen
    context.push('/onboardingWeight', extra: updatedUser);
    
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    final double rulerTopMargin = (screenHeight * 0.05) + 40; 
    final double rulerBottomMargin = (screenHeight * 0.35) + 40; 
    final double rulerActualHeight = screenHeight - rulerTopMargin - rulerBottomMargin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppbar(
        currentStep: 3,
        totalSteps: 8,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              left: 24,
              top: 20,
              child: Text(
                "How tall are you?",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),

            Positioned(
              right: 0,
              top: rulerTopMargin,
              height: rulerActualHeight,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  updateHeightFromArrow(details.localPosition.dy, rulerActualHeight);
                },
                child: SizedBox(
                  width: 60,
                  child: CustomPaint(
                    painter: _VerticalRulerPainter(),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: isCm 
                            ? [
                                TextSpan(
                                  text: "${heightCm.toInt()}",
                                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                                TextSpan(
                                  text: " cm",
                                  style: TextStyle(fontSize: 28, color: Colors.grey.shade500),
                                ),
                              ]
                            : [
                                TextSpan(
                                  text: getFeetInches().split(" ")[0],
                                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                                TextSpan(
                                  text: "ft ",
                                  style: TextStyle(fontSize: 28, color: Colors.grey.shade500),
                                ),
                                TextSpan(
                                  text: getFeetInches().split(" ")[1],
                                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                                TextSpan(
                                  text: "in",
                                  style: TextStyle(fontSize: 28, color: Colors.grey.shade500),
                                ),
                              ],
                        ),
                      ),
                      Text(
                        "swipe for ${isCm ? "ft/in" : "cm"}",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (_) => setState(() => isCm = !isCm),
                child: const SizedBox(width: 250, height: 150),
              ),
            ),

            Positioned(
              right: 45,
              top: rulerTopMargin + getArrowY(rulerActualHeight) - 15,
              child: Row(
                children: [
                  const Icon(Icons.play_arrow, color: Colors.red, size: 30),
                  const SizedBox(width: 4),
                  Text(
                    getSelectionValue(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ],
              ),
            ),

            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : ContinueButton(
                      onPressed: _onContinue,
                      txt: "Continue",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalRulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1.5;
    
    const double steps = 50; 
    double lineSpacing = size.height / steps;
    
    for (int i = 0; i <= steps; i++) {
      double y = i * lineSpacing;
      
      double len = (i % 5 == 0) ? 40 : 20;
      paint.color = (i % 5 == 0) ? Colors.black : Colors.grey.shade400;

      canvas.drawLine(
        Offset(size.width - len, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}