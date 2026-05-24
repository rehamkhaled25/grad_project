import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:image_picker/image_picker.dart';
 
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
 
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
 
class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _planData;
  Map<String, dynamic>? _streakData;
  bool _isLoading = true;
 
  // Allergies state
  List<String> _allergies = [];
  final TextEditingController _customAllergyController = TextEditingController();
 
  @override
  void initState() {
    super.initState();
    _loadData();
  }
 
  @override
  void dispose() {
    _customAllergyController.dispose();
    super.dispose();
  }
 
  Future<void> _loadData() async {
    try {
      final profile = await ApiService().getProfile();
      Map<String, dynamic>? plan;
      Map<String, dynamic>? streak;
      try {
        plan = await FoodService().getCaloriePlan();
      } catch (_) {}
      try {
        streak = await FoodService().getStreak();
      } catch (_) {}
 
      if (mounted) {
        setState(() {
          if (profile != null) {
            _profileData = {
              'full_name': profile.fullName,
              'email': profile.email,
              'gender': profile.gender,
              'goal': profile.goal,
              'weight': profile.weight,
              'height': profile.height,
              'goal_weight': profile.goalWeight,
              'birthdate': profile.birthdate,
              'profile_image_url': profile.profileImageUrl,
            };
            // Load allergies from the fetched profile
            _allergies = List<String>.from(profile.allergies ?? []);
          }
          _planData = plan;
          _streakData = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
 
  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
 
    final newUrl = await ApiService().uploadProfileImage(image.path);
    if (newUrl != null && mounted) {
      setState(() {
        _profileData?['profile_image_url'] = newUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile image updated!'),
            backgroundColor: Colors.green),
      );
    }
  }
 
  // Adds allergy optimistically to UI then persists to backend via PUT /user/profile
  Future<void> _addAllergy(String text) async {
    setState(() {
      _allergies.add(text);
    });
 
    final success = await ApiService().updateAllergies(_allergies);
 
    if (!success && mounted) {
      // Roll back if the backend rejected it
      setState(() {
        _allergies.remove(text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save allergy. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
 
  // Shows the add-allergy popup dialog (same style as allergies.dart Popup)
  void _showAddAllergyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        content: Material(
          color: Colors.transparent,
          child: _AllergyPopup(
            controller: _customAllergyController,
            onCancel: () {
              _customAllergyController.clear();
              Navigator.pop(context);
            },
            onAdd: () {
              final text = _customAllergyController.text.trim();
              Navigator.pop(context);
              _customAllergyController.clear();
              if (text.isEmpty) return;
              // Fire async add — VoidCallback stays sync
              _addAllergy(text);
            },
          ),
        ),
      ),
    );
  }
 
  // Helper getters
  String get _name => _profileData?['full_name'] ?? 'User';
  String get _gender => _profileData?['gender'] ?? 'Not set';
  String get _goal => _profileData?['goal'] ?? 'Not set';
  double get _weight => (_profileData?['weight'] as num?)?.toDouble() ?? 0;
  double get _height => (_profileData?['height'] as num?)?.toDouble() ?? 0;
  double get _goalWeight =>
      (_profileData?['goal_weight'] as num?)?.toDouble() ?? 0;
  String? get _profileImageUrl => _profileData?['profile_image_url'];
  int get _age {
    final bd = _profileData?['birthdate'];
    if (bd == null) return 0;
    try {
      final date = DateTime.parse(bd.toString());
      return DateTime.now().difference(date).inDays ~/ 365;
    } catch (_) {
      return 0;
    }
  }
 
  double get _bmi {
    if (_height <= 0 || _weight <= 0) return 0;
    final hm = _height / 100;
    return _weight / (hm * hm);
  }
 
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = screenWidth < 430 ? screenWidth : 430.0;
    final scaleFactor = baseWidth / 430.0;
 
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
 
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: baseWidth,
                decoration: BoxDecoration(color: const Color(0xFFF4F4F4)),
                child: Column(
                  children: [
                    _buildHeader(context, scaleFactor),
                    _buildStatsCards(scaleFactor),
                    _buildEditProfileButton(context, scaleFactor),
                    _buildBadgesButton(context, scaleFactor),
                    _buildBodyStatsCard(scaleFactor),
                    _buildWeightProgressCard(scaleFactor),
                    _buildDailyGoalsCard(scaleFactor),
                    _buildFoodPreferencesCard(scaleFactor),
                    _buildPremiumCard(context, scaleFactor),
                    SizedBox(height: 20 * scaleFactor),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
 
  // Header Section
  Widget _buildHeader(BuildContext context, double scale) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
      ),
      child: Column(
        children: [
          SizedBox(height: 50 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 19 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back,
                      color: Colors.white, size: 24 * scale),
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 17 * scale,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Icon(Icons.settings_outlined,
                      color: const Color(0xFFF8F9FD), size: 22 * scale),
                ),
              ],
            ),
          ),
          SizedBox(height: 35 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30 * scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _profileImageUrl != null
                        ? CircleAvatar(
                            radius: 60 * scale,
                            backgroundImage: NetworkImage(
                              _profileImageUrl!.startsWith('http')
                                  ? _profileImageUrl!
                                  : '${ApiService.baseUrl}$_profileImageUrl',
                            ),
                          )
                        : CircleAvatar(
                            radius: 60 * scale,
                            backgroundImage:
                                const AssetImage('assets/images/profilee.png'),
                          ),
                    GestureDetector(
                      onTap: _pickAndUploadProfileImage,
                      child: Container(
                        width: 28 * scale,
                        height: 28 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD90C0C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 14 * scale),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 18 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 20 * scale,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        _goal,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 13 * scale,
                          color: const Color(0xFFF4F4F4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * scale),
        ],
      ),
    );
  }
 
  Widget _buildStatsCards(double scale) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(0, -30 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      '${_streakData?['total_days_logged'] ?? 0}',
                      'Days Logged',
                      Icons.water_drop_outlined,
                      const Color(0xFFF1F0F0),
                      const Color(0xFF605A5A),
                      Colors.black,
                      scale),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildStatCard(
                      '${_streakData?['longest_streak'] ?? 0}',
                      'Best Streak',
                      Icons.emoji_events,
                      const Color(0xFFFFE2E2),
                      const Color(0xFFD90C0C),
                      const Color(0xFFD90C0C),
                      scale),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Row(
            children: [
              Expanded(
                child: Builder(builder: (_) {
                  final diff = (_weight - _goalWeight).abs();
                  final isGaining = _goalWeight > _weight;
                  return _buildStatCard(
                    '${diff.toStringAsFixed(1)} kg',
                    isGaining ? 'Weight to be Gained' : 'Weight to be Lost',
                    isGaining ? Icons.trending_up : Icons.trending_down,
                    const Color(0xFFFFE2E2),
                    const Color(0xFFD90C0C),
                    const Color(0xFFD90C0C),
                    scale,
                  );
                }),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _buildStatCard(
                    '2026',
                    'Member Since',
                    Icons.calendar_today,
                    const Color(0xFFF1F0F0),
                    const Color(0xFF605A5A),
                    Colors.black,
                    scale),
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _buildStatCard(String value, String label, IconData icon,
      Color bgColor, Color iconColor, Color valueColor, double scale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8 * scale)),
            child: Icon(icon, color: iconColor, size: 18 * scale),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 11 * scale,
                        color: const Color(0xFF605A5A))),
                SizedBox(height: 2 * scale),
                Text(value,
                    style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w600,
                        fontSize: 16 * scale,
                        color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildEditProfileButton(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20),
      child: GestureDetector(
        onTap: () => context.push('/edit-profile'),
        child: Container(
          width: 238 * scale,
          height: 42 * scale,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12 * scale)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, color: Colors.white, size: 20 * scale),
              SizedBox(width: 8 * scale),
              Text('Edit Profile',
                  style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildBadgesButton(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
      child: GestureDetector(
        onTap: () => context.push('/badges'),
        child: Container(
          width: 238 * scale,
          height: 42 * scale,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined,
                  color: Colors.black, size: 20 * scale),
              SizedBox(width: 8 * scale),
              Text('View Badges',
                  style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyStatsCard(double scale) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 16 * scale),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10 * scale)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Body Stats',
                style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * scale)),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Expanded(
                    child: _buildMetricBox('Current Weight',
                        '${_weight.toInt()} kg', Icons.monitor_weight_outlined, scale)),
                SizedBox(width: 12 * scale),
                Expanded(
                    child: _buildMetricBox('Goal Weight',
                        '${_goalWeight.toInt()} kg', Icons.flag_outlined, scale)),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(
                    child: _buildSmallMetricBox(
                        'Height', '${_height.toInt()}cm', scale)),
                SizedBox(width: 8 * scale),
                Expanded(
                    child: _buildSmallMetricBox('Age', '$_age', scale)),
                SizedBox(width: 8 * scale),
                Expanded(
                    child: _buildSmallMetricBox(
                        'BMI', _bmi.toStringAsFixed(1), scale)),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildMetricBox(
      String label, String value, IconData icon, double scale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10 * scale)),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD90C0C), size: 16 * scale),
          SizedBox(height: 4 * scale),
          Text(label,
              style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 11 * scale,
                  color: const Color(0xFF605A5A))),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale)),
        ],
      ),
    );
  }
 
  Widget _buildSmallMetricBox(String label, String value, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10 * scale)),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 11 * scale,
                  color: const Color(0xFF605A5A))),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale)),
        ],
      ),
    );
  }
 
  Widget _buildWeightProgressCard(double scale) {
    final diff = _weight - _goalWeight;
    final diffStr = diff > 0
        ? '-${diff.toStringAsFixed(1)} kg'
        : '+${diff.abs().toStringAsFixed(1)} kg';
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 8 * scale),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight Progress',
                        style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale)),
                    Text(diffStr,
                        style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w600,
                            fontSize: 14 * scale,
                            color: const Color(0xFFD90C0C))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildWeightRow(
                        'Current Weight', '${_weight.toInt()}', scale),
                    _buildWeightRow(
                        'Start Weight', '${_weight.toInt()}', scale),
                    _buildWeightRow(
                        'Goal Weight', '${_goalWeight.toInt()}', scale),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Container(
              height: 120 * scale,
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8 * scale),
              child: CustomPaint(painter: _WeightChartPainter()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep']
                  .map((month) => Text(month,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10 * scale,
                          color: const Color(0xFF8A8C90))))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildWeightRow(String label, String value, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2 * scale),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10 * scale,
              color: const Color(0xFF8A8C90),
            ),
          ),
          SizedBox(width: 6 * scale),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 13 * scale,
              color: const Color(0xFF272932),
            ),
          ),
          Text(
            'kg',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9 * scale,
              color: const Color(0xFF8A8C90),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildDailyGoalsCard(double scale) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 8 * scale),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Goals',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 16 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12 * scale,
              crossAxisSpacing: 12 * scale,
              childAspectRatio: 2.2,
              children: [
                _buildGoalBox('Calories',
                    '${_planData?['calories'] ?? 0}', 'cal/day', true, scale),
                _buildGoalBox('Protein',
                    '${_planData?['protein'] ?? 0}', 'grams', false, scale),
                _buildGoalBox('Carbs',
                    '${_planData?['carbs'] ?? 0}', 'grams', false, scale),
                _buildGoalBox('Fat',
                    '${_planData?['fats'] ?? 0}', 'grams', false, scale),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildGoalBox(
      String label, String value, String unit, bool isHighlighted, double scale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color:
            isHighlighted ? const Color(0xFFFFE1E1) : const Color(0xFFE9E8E8),
        borderRadius: BorderRadius.circular(12 * scale),
        border: isHighlighted
            ? Border.all(color: const Color(0xFF8C0B0B), width: 0.3)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 11 * scale,
              color: const Color(0xFF4A4646),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              color: isHighlighted
                  ? const Color(0xFFD90C0C)
                  : const Color(0xFF141414),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 9 * scale,
              color: const Color(0xFF4A4646),
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────────────────────
  //  Food Preferences card — Diet Type & Disliked Foods removed.
  //  Only Allergies & Restrictions remain, with the same chip
  //  style and add-button as allergies.dart.
  // ─────────────────────────────────────────────────────────────
  Widget _buildFoodPreferencesCard(double scale) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 8 * scale),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Preferences',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 16 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
 
            // ── Allergies & Restrictions label ──
            Row(
              children: [
                Text(
                  'Allergies & Restrictions',
                  style: TextStyle(
                      fontFamily: 'SF Pro', fontSize: 10 * scale),
                ),
                SizedBox(width: 8 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale, vertical: 2 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Text(
                    'Important',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 9 * scale,
                      color: const Color(0xFFD90C0C),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * scale),
 
            // ── Allergy chips + add button ──
            // Using Wrap so it expands naturally without overflow
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Existing allergy chips (same style as allergies.dart custom chip)
                ..._allergies.map(
                  (allergy) => _buildAllergyChip(allergy, scale),
                ),
 
                // "Add custom allergy" dotted-border button (exact copy from allergies.dart)
                GestureDetector(
                  onTap: _showAddAllergyDialog,
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: Radius.circular(40),
                      color: const Color(0xffD9D9D9),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add,
                              color: const Color(0xFFD90C0C),
                              size: 16 * scale),
                          SizedBox(width: 4 * scale),
                          Text(
                            'Add ',
                            style: TextStyle(
                              fontSize: 11 * scale,
                              color: const Color(0xFFD90C0C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
 
            SizedBox(height: 8 * scale),
          ],
        ),
      ),
    );
  }
 
  Widget _buildAllergyChip(String text, double scale) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color:const Color(0xffFFF1F1)
          ),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 11 * scale, color: const Color(0xffD90C0C)),
          ),
        ),
        
      ],
    );
  }
 
  Widget _buildPremiumCard(BuildContext context, double scale) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 8 * scale),
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
                  child: Image.asset("assets/images/premium_icon.png"),
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
                    Image.asset("assets/images/right_icon.png"),
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
              onTap: () => context.push('/premiumPlan'),
              child: Container(
                width: double.infinity,
                height: 33 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFD90C0C),
                  borderRadius: BorderRadius.circular(13 * scale),
                ),
                child: Center(
                  child: Text(
                    'Upgrade to premium',
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
}
 
// ─────────────────────────────────────────────────────────────────────────────
//  Allergy popup dialog — identical to Popup in allergies.dart
// ─────────────────────────────────────────────────────────────────────────────
class _AllergyPopup extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onAdd;
 
  const _AllergyPopup({
    required this.controller,
    required this.onCancel,
    required this.onAdd,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add a custom allergy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'e.g, Strawberries, apples',
                hintStyle: TextStyle(
                  color: Color(0xffBBBABA),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffD90C0C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffD90C0C)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    width: 80,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 80,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
//  Weight chart painter (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class _WeightChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE1E1E2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
 
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
 
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.55),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.45),
      Offset(size.width, size.height * 0.4),
    ];
 
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final controlPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      fillPath.quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
 
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF6565).withOpacity(0.24),
          const Color(0xFFFFA365).withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
 
    final linePaint = Paint()
      ..color = const Color(0xFFD90C0C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
 
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final controlPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      linePath.quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);
    }
    canvas.drawPath(linePath, linePaint);
 
    for (final p in points) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3, Paint()..color = const Color(0xFFD90C0C));
    }
  }
 
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}