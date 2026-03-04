import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:graduation_project/services/database_service.dart';
import 'package:graduation_project/models/user_model.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final DatabaseService _dbService = DatabaseService();
  double weightKg = 70;
  bool isKg = true;
  bool _isSaving = false;
  bool _isLoadingData = true; 

  final ScrollController _scrollController = ScrollController();

  double get weightLb => weightKg * 2.20462;

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
        
       
        if (userData != null && userData.weight != null && userData.weight! > 0) {
          if (mounted) {
            context.go('/onboardingGoal'); 
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking existing data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo((weightKg - 50) * 40);
          }
        });
      }
    }
  }

  void onScroll() {
    if (!_scrollController.hasClients) return;
    double offset = _scrollController.offset;
    setState(() {
      weightKg = (50 + offset / 40).clamp(50, 95);
    });
  }


  Future<void> _saveWeightAndContinue() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _dbService.saveUserData(UserModel(
          uid: user.uid,
          weight: weightKg, 
          email: user.email ?? "",
        ));

        if (mounted) {
          context.push('/onboardingGoal');
        }
      } else {
        throw Exception("No user logged in");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving weight: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

  
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppbar(currentStep: 4, totalSteps: 7),
          const SizedBox(height: 20),
          const Text(
            "What's your current weight?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Center(
            child: RichText(
              text: TextSpan(
                children: isKg
                    ? [
                        TextSpan(
                          text: "${weightKg.toInt()} ",
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "kg",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ]
                    : [
                        TextSpan(
                          text: weightLb.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: " lb",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => isKg = !isKg),
            child: Text(
              "tap to switch to ${isKg ? "lb" : "kg"}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 100,
            width: screenWidth,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                onScroll();
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: 46,
                itemBuilder: (context, index) {
                  int kgValue = 50 + index;
                  bool isMajor = kgValue % 5 == 0;
                  return Container(
                    width: 40,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: isMajor ? 35 : 18,
                          width: 2,
                          color: Colors.black,
                        ),
                        if (isMajor) ...[
                          const SizedBox(height: 5),
                          Text(
                            "$kgValue",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const Spacer(flex: 2),
          
          InkWell(
            onTap: _isSaving ? null : _saveWeightAndContinue,
            child: Container(
              height: 55,
              width: 360,
              margin: const EdgeInsets.only(bottom: 40),
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
        ],
      ),
    );
  }
}