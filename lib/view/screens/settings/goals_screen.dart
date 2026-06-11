import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/onboarding_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _calorieController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // Plan-computed defaults (from backend)
  double _planCalories = 2400;
  double _planProtein = 120;
  double _planCarbs = 250;
  double _planFats = 60;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    try {
      // First get the backend-computed plan as defaults (raw backend calculations)
      final plan = await OnboardingService().getCalculatedPlan();
      if (plan != null) {
        _planCalories = plan.calories.toDouble();
        _planProtein = plan.protein.toDouble();
        _planCarbs = plan.carbs.toDouble();
        _planFats = plan.fats.toDouble();
      }

      // Then check if user has custom overrides in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = await ApiService().getCurrentUserEmail() ?? '';
      final prefix = email.isNotEmpty ? '${email}_' : '';
      final customCalories = prefs.getDouble('${prefix}plan_calories');
      final customProtein = prefs.getDouble('${prefix}plan_protein');
      final customCarbs = prefs.getDouble('${prefix}plan_carbs');
      final customFats = prefs.getDouble('${prefix}plan_fats');

      if (mounted) {
        setState(() {
          _calorieController.text = (customCalories ?? _planCalories).toStringAsFixed(0);
          _proteinController.text = (customProtein ?? _planProtein).toStringAsFixed(0);
          _carbsController.text = (customCarbs ?? _planCarbs).toStringAsFixed(0);
          _fatsController.text = (customFats ?? _planFats).toStringAsFixed(0);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _calorieController.text = _planCalories.toStringAsFixed(0);
          _proteinController.text = _planProtein.toStringAsFixed(0);
          _carbsController.text = _planCarbs.toStringAsFixed(0);
          _fatsController.text = _planFats.toStringAsFixed(0);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveGoals() async {
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = await ApiService().getCurrentUserEmail() ?? '';
      final prefix = email.isNotEmpty ? '${email}_' : '';
      final calories = double.tryParse(_calorieController.text) ?? _planCalories;
      final protein = double.tryParse(_proteinController.text) ?? _planProtein;
      final carbs = double.tryParse(_carbsController.text) ?? _planCarbs;
      final fats = double.tryParse(_fatsController.text) ?? _planFats;

      await prefs.setDouble('${prefix}plan_calories', calories);
      await prefs.setDouble('${prefix}plan_protein', protein);
      await prefs.setDouble('${prefix}plan_carbs', carbs);
      await prefs.setDouble('${prefix}plan_fats', fats);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Goals saved successfully!"),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to save: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await ApiService().getCurrentUserEmail() ?? '';
    final prefix = email.isNotEmpty ? '${email}_' : '';
    await prefs.remove('${prefix}plan_calories');
    await prefs.remove('${prefix}plan_protein');
    await prefs.remove('${prefix}plan_carbs');
    await prefs.remove('${prefix}plan_fats');

    setState(() {
      _calorieController.text = _planCalories.toStringAsFixed(0);
      _proteinController.text = _planProtein.toStringAsFixed(0);
      _carbsController.text = _planCarbs.toStringAsFixed(0);
      _fatsController.text = _planFats.toStringAsFixed(0);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Goals reset to plan defaults"),
          backgroundColor: Colors.black54,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Goals',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: const Text(
              'Reset',
              style: TextStyle(color: Color(0xffD90C0C), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Set your daily nutrition targets",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Plan defaults: ${_planCalories.toStringAsFixed(0)} cal · "
                    "${_planProtein.toStringAsFixed(0)}g P · "
                    "${_planCarbs.toStringAsFixed(0)}g C · "
                    "${_planFats.toStringAsFixed(0)}g F",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _GoalInputCard(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xffD90C0C),
                    label: 'Calories',
                    suffix: 'cal',
                    controller: _calorieController,
                  ),
                  const SizedBox(height: 16),
                  _GoalInputCard(
                    icon: Icons.fitness_center,
                    iconColor: Colors.red,
                    label: 'Protein',
                    suffix: 'g',
                    controller: _proteinController,
                  ),
                  const SizedBox(height: 16),
                  _GoalInputCard(
                    icon: Icons.grain,
                    iconColor: Colors.blue,
                    label: 'Carbs',
                    suffix: 'g',
                    controller: _carbsController,
                  ),
                  const SizedBox(height: 16),
                  _GoalInputCard(
                    icon: Icons.water_drop,
                    iconColor: Colors.orange,
                    label: 'Fats',
                    suffix: 'g',
                    controller: _fatsController,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveGoals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Save Goals",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

class _GoalInputCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String suffix;
  final TextEditingController controller;

  const _GoalInputCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.suffix,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    suffixText: suffix,
                    suffixStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
