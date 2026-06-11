import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/onboarding_service.dart';
import 'package:go_router/go_router.dart';

class EditGoalPage extends StatefulWidget {
  const EditGoalPage({super.key});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  String selectedGoal = 'Maintain';
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _fatsController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await OnboardingService().getUserProfile();
      final plan = await FoodService().getCaloriePlan();

      if (profile != null) {
        if (profile.goal != null) {
          final g = profile.goal!.toLowerCase();
          if (g.contains('lose')) {
            selectedGoal = 'Lose';
          } else if (g.contains('gain')) {
            selectedGoal = 'Gain';
          } else {
            selectedGoal = 'Maintain';
          }
        }
        _goalWeightController.text = (profile.goalWeight ?? 70).toStringAsFixed(0);
      }

      if (plan != null) {
        _caloriesController.text = (plan['calories'] ?? 2400).toStringAsFixed(0);
        _fatsController.text = (plan['fats'] ?? 60).toStringAsFixed(0);
        _proteinController.text = (plan['protein'] ?? 120).toStringAsFixed(0);
        _carbsController.text = (plan['carbs'] ?? 250).toStringAsFixed(0);
      }
    } catch (e) {
      debugPrint("Error loading goal data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    final double? cal = double.tryParse(_caloriesController.text);
    final double? fat = double.tryParse(_fatsController.text);
    final double? prot = double.tryParse(_proteinController.text);
    final double? carb = double.tryParse(_carbsController.text);
    final double? goalW = double.tryParse(_goalWeightController.text);

    if (cal == null || fat == null || prot == null || carb == null || goalW == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter valid numbers for calories, macros, and goal weight."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Save locally to SharedPreferences to sync plan values
      final prefs = await SharedPreferences.getInstance();
      final email = await ApiService().getCurrentUserEmail() ?? '';
      final prefix = email.isNotEmpty ? '${email}_' : '';
      await prefs.setDouble('${prefix}plan_calories', cal);
      await prefs.setDouble('${prefix}plan_fats', fat);
      await prefs.setDouble('${prefix}plan_protein', prot);
      await prefs.setDouble('${prefix}plan_carbs', carb);

      // 2. Map & update the goal on the backend
      final mappedGoal = selectedGoal == 'Lose'
          ? 'Lose Weight'
          : selectedGoal == 'Gain'
              ? 'Gain Weight'
              : 'Maintain Weight';

      final success = await ApiService().updateProfileGoal(mappedGoal, goalWeight: goalW);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? "✅ Goals and Plan updated successfully!"
                : "⚠️ Plan updated locally, but failed to sync goal with server."),
            backgroundColor: success ? Colors.black : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error saving goals: $e"),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => context.pop(),
                              child: const Icon(Icons.arrow_back, size: 24),
                            ),
                            const SizedBox(width: 24),
                            const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : InkWell(
                                onTap: _saveChanges,
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save changes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const Text(
                      'Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF706B6B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildGoalButton('Lose'),
                        const SizedBox(width: 12),
                        _buildGoalButton('Maintain'),
                        const SizedBox(width: 12),
                        _buildGoalButton('Gain'),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Goal Weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF706B6B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _goalWeightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: _inputStyle().copyWith(
                        suffixText: 'kg',
                        suffixStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Daily calories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF706B6B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: _inputStyle(),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Macros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF706B6B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildMacroColumn('🧈', 'Fats', _fatsController),
                        const SizedBox(width: 16),
                        _buildMacroColumn('🍗', 'Protein', _proteinController),
                        const SizedBox(width: 16),
                        _buildMacroColumn('🍞', 'Carbs', _carbsController),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGoalButton(String title) {
    bool isActive = selectedGoal == title;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedGoal = title;
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? Colors.black : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroColumn(String icon, String label, TextEditingController controller) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 20),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'g',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }
}