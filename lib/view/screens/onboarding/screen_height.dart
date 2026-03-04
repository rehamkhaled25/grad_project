import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/services/database_service.dart';
import 'package:graduation_project/models/user_model.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  final DatabaseService _dbService = DatabaseService();
  double heightCm = 170;
  bool isCm = true;
  bool _isSaving = false;
  bool _isLoadingData = true; 
  double rulerHeight = 0;
  double rulerTop = 0;

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
        
        
        if (userData != null && userData.height != null && userData.height! > 0) {
          if (mounted) {
            context.go('/onboardingWeight');
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking height data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

 
  String getFeetInches() {
    final inches = heightCm / 2.54;
    final feet = inches ~/ 12;
    final inch = (inches % 12).round();
    return "$feet $inch";
  }

 
  double getArrowY() => rulerTop + ((220 - heightCm) / 120) * rulerHeight;

  
  void updateHeightFromArrow(double posY) {
    double newHeight = 220 - ((posY - rulerTop) / rulerHeight) * 120;
    setState(() {
      heightCm = newHeight.clamp(100, 220);
    });
  }


  Future<void> _saveHeightAndContinue() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _dbService.saveUserData(UserModel(
          uid: user.uid,
          height: heightCm, 
          email: user.email ?? "",
        ));

        if (mounted) {
          context.push('/onboardingWeight');
        }
      } else {
        throw Exception("No user authenticated");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save height: $e"),
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
   
    rulerHeight = MediaQuery.of(context).size.height * 0.6;
    rulerTop = MediaQuery.of(context).size.height * 0.25;

   
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// Top progress bar
            const CustomAppbar(currentStep: 3, totalSteps: 7),

            /// Title
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

            /// Selection Arrow
            Positioned(
              right: 80,
              top: getArrowY(),
              child: const Icon(Icons.play_arrow, color: Colors.red, size: 26),
            ),

            /// Display Value
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
                onTap: _isSaving ? null : _saveHeightAndContinue,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  height: 54,
                  width: 384,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
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