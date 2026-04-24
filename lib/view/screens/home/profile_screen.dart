import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = screenWidth < 430 ? screenWidth : 430.0;
    final scaleFactor = baseWidth / 430.0;

    return Scaffold(
      backgroundColor: const Color(
        0xFF141414,
      ), // Match header color for top area
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: baseWidth,
                decoration: BoxDecoration(color: const Color(0xFFF4F4F4)),
                child: Column(
                  children: [
                    // Header Section - No SafeArea, use padding instead
                    _buildHeader(context, scaleFactor),

                    // Stats Cards
                    _buildStatsCards(scaleFactor),

                    // Edit Profile Button
                    _buildEditProfileButton(context, scaleFactor),

                    // Body Stats Card
                    _buildBodyStatsCard(scaleFactor),

                    // Weight Progress Card
                    _buildWeightProgressCard(scaleFactor),

                    // Daily Goals Card
                    _buildDailyGoalsCard(scaleFactor),

                    // Food Preferences Card
                    _buildFoodPreferencesCard(scaleFactor),

                    // Premium Card
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow content to overflow if needed
        children: [
          // Main content
          Column(
            children: [
              SizedBox(height: 13 * scale),
              // Status Bar Row
              SizedBox(height: 30 * scale),
              // Title Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 19 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24 * scale,
                      ),
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
                      child: Icon(
                        Icons.settings_outlined,
                        color: const Color(0xFFF8F9FD),
                        size: 22 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 27 * scale),
              // Profile Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25 * scale),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset("assets/images/placeholder_profile.png"),

                        Positioned(
                          right: -5 * scale,
                          bottom: -5 * scale,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 27 * scale,
                              height: 27 * scale,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: const Color(0xFF605A5A),
                                size: 18 * scale,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15 * scale),
                    // Name and Username
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mohannad Hany',
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w600,
                              fontSize: 17 * scale,
                              color: const Color(0xFFF4F4F4),
                            ),
                          ),
                          SizedBox(height: 3 * scale),
                          Text(
                            '@moe_hani',
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w600,
                              fontSize: 13 * scale,
                              color: const Color(0xFFF4F4F4),
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          // Streak Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12 * scale,
                              vertical: 4 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF680909).withOpacity(0.19),
                              border: Border.all(
                                color: const Color(0xFFE50101),
                              ),
                              borderRadius: BorderRadius.circular(15 * scale),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: const Color(0xFFF81E1E),
                                  size: 14 * scale,
                                ),
                                SizedBox(width: 4 * scale),
                                Text(
                                  '12 Day Streak',
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13 * scale,
                                    color: const Color(0xFFF81E1E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24 * scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(double scale) {
    return Column(
      children: [
        // First row - overlaps the black header (negative margin)
        Transform.translate(
          offset: Offset(0, -30 * scale), // Pull up over the header
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '24',
                    'Days Logged',
                    Icons.water_drop_outlined,
                    const Color(0xFFF1F0F0),
                    const Color(0xFF605A5A),
                    Colors.black,
                    scale,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildStatCard(
                    '18',
                    'Best Streak',
                    Icons.emoji_events,
                    const Color(0xFFFFE2E2),
                    const Color(0xFFD90C0C),
                    const Color(0xFFD90C0C),
                    scale,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Second row - on white background
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '-3.5kg',
                  'Weight Lost',
                  Icons.trending_down,
                  const Color(0xFFFFE2E2),
                  const Color(0xFFD90C0C),
                  const Color(0xFFD90C0C),
                  scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _buildStatCard(
                  'Jan 25',
                  'Member Since',
                  Icons.calendar_today,
                  const Color(0xFFF1F0F0),
                  const Color(0xFF605A5A),
                  Colors.black,
                  scale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
    Color valueColor,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36 * scale, // Fixed: Increased size
            height: 36 * scale, // Fixed: Increased size
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(icon, color: iconColor, size: 18 * scale),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 11 * scale,
                    color: const Color(0xFF605A5A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2 * scale),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * scale,
                    color: valueColor,
                  ),
                ),
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
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Edit Profile tapped')));
        },
        child: Container(
          width: 238 * scale,
          height: 42 * scale,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, color: Colors.white, size: 20 * scale),
              SizedBox(width: 8 * scale),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * scale,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyStatsCard(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 16 * scale,
      ),
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
              'Body Stats',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 16 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    'Current Weight',
                    '68 kg',
                    Icons.monitor_weight_outlined,
                    scale,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildMetricBox(
                    'Goal Weight',
                    '62 kg',
                    Icons.flag_outlined,
                    scale,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(child: _buildSmallMetricBox('Height', '170cm', scale)),
                SizedBox(width: 8 * scale),
                Expanded(child: _buildSmallMetricBox('Age', '28', scale)),
                SizedBox(width: 8 * scale),
                Expanded(child: _buildSmallMetricBox('BMI', '25.0', scale)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(
    String label,
    String value,
    IconData icon,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD90C0C), size: 16 * scale),
          SizedBox(height: 4 * scale),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 11 * scale,
              color: const Color(0xFF605A5A),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 14 * scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricBox(String label, String value, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 11 * scale,
              color: const Color(0xFF605A5A),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 14 * scale,
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Weight Progress Card with visible chart
  Widget _buildWeightProgressCard(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 8 * scale,
      ),
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
                    Text(
                      'Weight Progress',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w600,
                        fontSize: 16 * scale,
                      ),
                    ),
                    Text(
                      '-3.5 kg',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * scale,
                        color: const Color(0xFFD90C0C),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildWeightRow('Current Weight', '68', scale),
                    _buildWeightRow('Start Weight', '85', scale),
                    _buildWeightRow('Goal Weight', '65', scale),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            // FIXED: Chart with proper constraints
            Container(
              height: 120 * scale,
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8 * scale),
              child: CustomPaint(painter: _WeightChartPainter()),
            ),
            // Month labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep']
                  .map(
                    (month) => Text(
                      month,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10 * scale,
                        color: const Color(0xFF8A8C90),
                      ),
                    ),
                  )
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
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 8 * scale,
      ),
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
                _buildGoalBox('Calories', '1,800', 'cal/day', true, scale),
                _buildGoalBox('Protein', '120', 'grams', false, scale),
                _buildGoalBox('Carbs', '180', 'grams', false, scale),
                _buildGoalBox('Fat', '60', 'grams', false, scale),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalBox(
    String label,
    String value,
    String unit,
    bool isHighlighted,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFFFFE1E1)
            : const Color(0xFFE9E8E8),
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

  Widget _buildFoodPreferencesCard(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 8 * scale,
      ),
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
            Text(
              'Diet Type',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 11 * scale,
                color: const Color(0xFF141414),
              ),
            ),
            SizedBox(height: 8 * scale),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 6 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Text(
                'Vegetarian',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Text(
                  'Allergies & Restrictions',
                  style: TextStyle(fontFamily: 'SF Pro', fontSize: 10 * scale),
                ),
                SizedBox(width: 8 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 2 * scale,
                  ),
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
            SizedBox(height: 8 * scale),
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              children: [
                _buildChip('Peanuts', scale),
                _buildChip('Shellfish', scale),
                _buildAddChip(scale),
              ],
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Disliked Foods',
              style: TextStyle(fontFamily: 'SF Pro', fontSize: 10 * scale),
            ),
            SizedBox(height: 8 * scale),
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              children: [
                _buildChip('Fish', scale),
                _buildChip('Mushrooms', scale),
                _buildAddChip(scale),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Figtree',
              fontSize: 10 * scale,
              color: const Color(0xFFD90C0C),
            ),
          ),
          SizedBox(width: 4 * scale),
          Icon(Icons.close, color: const Color(0xFFD90C0C), size: 11 * scale),
        ],
      ),
    );
  }

  Widget _buildAddChip(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDB9AA), width: 0.3),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: const Color(0xFFD90C0C), size: 10 * scale),
          Text(
            'Add',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontSize: 10 * scale,
              color: const Color(0xFFD90C0C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 8 * scale,
      ),
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
              onTap: () => context.push('/subscription'),
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

// FIXED: Weight Chart Painter with proper rendering
class _WeightChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE1E1E2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points (normalized)
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.55),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.45),
      Offset(size.width, size.height * 0.4),
    ];

    // Draw gradient fill
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Use quadratic bezier for smooth curve
      final p1 = points[i - 1];
      final p2 = points[i];
      final controlPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      fillPath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        p2.dx,
        p2.dy,
      );
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

    // Draw line
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
        controlPoint.dx,
        controlPoint.dy,
        p2.dx,
        p2.dy,
      );
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    for (final p in points) {
      // Outer white border
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      // Inner red dot
      canvas.drawCircle(p, 3, Paint()..color = const Color(0xFFD90C0C));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
