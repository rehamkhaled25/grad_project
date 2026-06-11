import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/models/plan_model.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/onboarding_service.dart';
import 'package:graduation_project/view/custom _widget/continue_button.dart';
import 'package:graduation_project/view/custom _widget/custom_appBar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Plan extends StatefulWidget {
  final UserModel? userModel;
  const Plan({super.key, this.userModel});

  @override
  State<Plan> createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  final OnboardingService _onboardingService = OnboardingService();
  PlanModel? _plan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlanData();
  }

  Future<void> _fetchPlanData() async {
    try {
      final plan = await _onboardingService.getCalculatedPlan();
      setState(() {
        _plan = plan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load your nutrition plan")),
        );
      }
    }
  }

  /// Helper to clean up any long decimals sent in the summary string from the backend
  String _formatTargetSummary(String summary) {
    return summary.replaceAllMapped(RegExp(r'(\d+\.\d{2,})'), (match) {
      double val = double.parse(match.group(0)!);
      return val.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    double pageWidth = MediaQuery.of(context).size.width;

    // Logic for dynamic text based on goal direction from backend
    String goalTitle = "You should:";
    if (_plan?.goalDirection == "lose_weight") {
      goalTitle = "You should lose:";
    } else if (_plan?.goalDirection == "gain_weight") {
      goalTitle = "You should gain:";
    } else if (_plan?.goalDirection == "maintain_weight") {
      goalTitle = "You should maintain:";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar(currentStep: 9, totalSteps: 9),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : _plan == null
                      ? const Center(child: Text("No plan data available."))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: pageWidth * 0.07),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const CircleAvatar(
                                backgroundColor: Color(0xff0E683E),
                                radius: 12,
                                child: Icon(Icons.check, color: Colors.white, size: 18),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Congratulations,\nyour plan is ready!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                goalTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xff262626),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  _formatTargetSummary(_plan!.targetSummary),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Daily recommendation",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff141414),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1.1,
                                children: [
                                  CustomItem(
                                    text1: "Calories",
                                    text2: "${_plan!.calories}",
                                    percent: (_plan!.calories / 2500).clamp(0.0, 1.0),
                                    color: 0xffF20D0D,
                                  ),
                                  CustomItem(
                                    text1: "Carbs",
                                    text2: "${_plan!.carbs}g",
                                    percent: (_plan!.carbs / 300).clamp(0.0, 1.0),
                                    color: 0xff2A00C3,
                                  ),
                                  CustomItem(
                                    text1: "Protein",
                                    text2: "${_plan!.protein}g",
                                    percent: (_plan!.protein / 200).clamp(0.0, 1.0),
                                    color: 0xff0E683E,
                                  ),
                                  CustomItem(
                                    text1: "Fats",
                                    text2: "${_plan!.fats}g",
                                    percent: (_plan!.fats / 100).clamp(0.0, 1.0),
                                    color: 0xffF17D11,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xffE3E3E3),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Health score",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        Text("${_plan!.healthScore}/10",
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.favorite_border, color: Color(0xff141414), size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: _plan!.healthScore / 10,
                                              minHeight: 8,
                                              backgroundColor: Colors.white,
                                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff43A047)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: pageWidth * 0.002, vertical: 20),
                                child: ContinueButton(
                                  onPressed: () => context.push('/trialSubscriptionPage'),
                                  txt: "Let's get started!!",
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  final String text1;
  final int color;
  final double percent;
  final String text2;

  const CustomItem({
    required this.text1,
    required this.color,
    required this.percent,
    required this.text2,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffE3E3E3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, size: 14, color: Color(0xff141414)),
              const SizedBox(width: 6),
              Text(text1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: CircularPercentIndicator(
              radius: 38,
              lineWidth: 5,
              percent: percent,
              progressColor: Color(color),
              backgroundColor: const Color(0xffC9C8C8),
              circularStrokeCap: CircularStrokeCap.round,
              center: Text(text2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}