import 'package:flutter/material.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTargetScreen extends StatefulWidget {
  const MyTargetScreen({super.key});

  @override
  State<MyTargetScreen> createState() => _MyTargetScreenState();
}

class _MyTargetScreenState extends State<MyTargetScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await ApiService().getProfile();
      final prefs = await SharedPreferences.getInstance();
      final email = await ApiService().getCurrentUserEmail() ?? '';
      final prefix = email.isNotEmpty ? '${email}_' : '';
      final isSub = prefs.getBool('${prefix}premium_active') ?? false;
      if (mounted) {
        setState(() {
          _user = user;
          _isPremium = isSub;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Target',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitness Goals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildGoalRow(
                          'Starting weight',
                          _user?.weight != null ? '${_user!.weight!.toStringAsFixed(0)} kg' : 'N/A',
                          isUnderlined: false,
                        ),
                        const SizedBox(height: 20),
                        _buildGoalRow(
                          'Current Weight',
                          _user?.weight != null ? '${_user!.weight!.toStringAsFixed(0)} kg' : 'N/A',
                          isUnderlined: true,
                          underlineColor: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        _buildGoalRow(
                          'Goal weight',
                          _user?.goalWeight != null ? '${_user!.goalWeight!.toStringAsFixed(0)} kg' : 'N/A',
                          isUnderlined: true,
                          underlineColor: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        _buildGoalRow(
                          'Goal name',
                          _user?.goal ?? 'N/A',
                          isUnderlined: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'Nutrition Goals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      await context.push('/editGoal');
                      _loadProfile();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Calorie, Carbs, Protein and Fat Goals',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Customize your default targets',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildPremiumCard(context, scale),
                ],
              ),
            ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20 * scale),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 35 * scale,
                  height: 31 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD90C0C),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Image.asset(
                    "assets/images/premium_icon.png",
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, color: Colors.white),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: 13 * scale,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'unlock all features',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 11 * scale,
                        color: const Color(0xFFDCDADA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
            ...[
              'unlimited meal plan',
              'advanced analytic',
              'custom macro tracking',
              'priority support',
              'Ad-free experience',
            ].map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/right_icon.png",
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.check, color: Colors.red, size: 16),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      feature,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 11 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            GestureDetector(
              onTap: _isPremium
                  ? null
                  : () => context.push('/paymentApplication', extra: {
                        'id': 1,
                        'name': 'Monthly Premium',
                        'price': 9.99,
                        'period': 'month',
                      }),
              child: Container(
                width: double.infinity,
                height: 33 * scale,
                decoration: BoxDecoration(
                  color: _isPremium ? Colors.grey : const Color(0xFFD90C0C),
                  borderRadius: BorderRadius.circular(13 * scale),
                ),
                child: Center(
                  child: Text(
                    _isPremium ? 'Premium Active' : 'Upgrade to premium',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 13 * scale,
                      color: Colors.white,
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

  Widget _buildGoalRow(String title, String value, {required bool isUnderlined, Color? underlineColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
        Container(
          padding: isUnderlined ? const EdgeInsets.only(bottom: 2) : EdgeInsets.zero,
          decoration: isUnderlined
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: underlineColor ?? Colors.red, width: 1.5),
                  ),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isUnderlined ? (underlineColor ?? Colors.red) : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}