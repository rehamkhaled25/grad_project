import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/view/screens/database/servings_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  DateTime _selectedDate = DateTime.now();

  late Future<UserModel?> _userFuture;
  late Future<Map<String, dynamic>> _streakFuture;
  late Future<Map<String, dynamic>> _planFuture;

  // Day-specific data (reloaded when the selected day changes)
  Future<Map<String, dynamic>>? _dayFuture;

  // Week data for the bar (loaded once, refreshed on pull-to-refresh)
  Future<List<Map<String, dynamic>>>? _weekFuture;

  // Local storage properties for Water & Workouts
  int _waterIntake = 0;
  bool _tipDismissed = false;

  static const List<Map<String, String>> _tipsPool = [
    {
      'title': 'Stay Hydrated',
      'text': 'Drinking water before meals can help reduce appetite and support weight management.'
    },
    {
      'title': 'Prioritize Protein',
      'text': 'Eating enough protein helps maintain muscle mass, increases satiety, and burns slightly more calories during digestion.'
    },
    {
      'title': 'Mindful Eating',
      'text': 'Try eating slower and without distractions (like screens) to better recognize your body\'s fullness signals.'
    },
    {
      'title': 'Fiber for Digestibility',
      'text': 'Incorporate high-fiber foods like oats, beans, and berries to maintain healthy digestion and steady blood sugar.'
    },
    {
      'title': 'Get Quality Sleep',
      'text': 'Poor sleep can disrupt appetite hormones (ghrelin and leptin), leading to increased cravings.'
    },
    {
      'title': 'Focus on Whole Foods',
      'text': 'Try to fill most of your plate with minimally processed whole foods to maximize nutrient density.'
    },
    {
      'title': 'Limit Liquid Calories',
      'text': 'Sugary drinks, sodas, and fruit juices add empty calories without making you feel full.'
    },
    {
      'title': 'Eat the Rainbow',
      'text': 'Include different colored fruits and vegetables in your meals to get a diverse range of vitamins and antioxidants.'
    },
    {
      'title': 'Don\'t Skip Breakfast',
      'text': 'A high-protein breakfast can help stabilize blood glucose levels and prevent overeating later in the day.'
    },
    {
      'title': 'Healthy Fats Matter',
      'text': 'Include sources of healthy unsaturated fats like avocados, nuts, and olive oil for cellular and hormone health.'
    },
    {
      'title': 'Reduce Added Sugar',
      'text': 'Check ingredients labels for hidden added sugars which can cause energy spikes and crashes.'
    },
    {
      'title': 'Active Breaks',
      'text': 'If you sit for long hours, take a 5-minute walking or stretching break every hour to boost circulation.'
    },
    {
      'title': 'Pre-plan Your Meals',
      'text': 'Pre-planning your meals for the day or week significantly increases the likelihood of hitting your goals.'
    },
    {
      'title': 'Magnesium for Recovery',
      'text': 'Leafy greens, pumpkin seeds, and dark chocolate are rich in magnesium, which supports muscle relaxation and sleep.'
    },
    {
      'title': 'Sodium Awareness',
      'text': 'Reducing processed foods can significantly lower your daily sodium intake and improve cardiovascular health.'
    },
    {
      'title': 'Choose Complex Carbs',
      'text': 'Swap white rice/bread for brown rice, quinoa, and whole wheat to get sustained energy release.'
    },
    {
      'title': 'Limit Late Night Eating',
      'text': 'Try to finish eating at least 2-3 hours before sleep to support digestion and sleep quality.'
    },
    {
      'title': 'Portion Control',
      'text': 'Using smaller plates and bowls can visually trick your brain into feeling satisfied with appropriate portion sizes.'
    },
    {
      'title': 'Calcium for Bones',
      'text': 'Dairy, fortified plant milks, and almonds are excellent sources of calcium to support bone strength.'
    },
    {
      'title': 'Vitamin C Boost',
      'text': 'Citrus fruits, bell peppers, and broccoli help boost immunity and improve iron absorption from plant sources.'
    },
    {
      'title': 'Gut Health Support',
      'text': 'Eat fermented foods like yogurt, kefir, or kimchi to introduce beneficial probiotics to your gut microbiome.'
    },
    {
      'title': 'Strength Training Benefits',
      'text': 'Strength training boosts your resting metabolic rate, meaning you burn more calories even when at rest.'
    },
    {
      'title': 'Use Healthy Herbs',
      'text': 'Flavor meals with spices like turmeric, garlic, or ginger instead of excess salt to get antioxidant benefits.'
    },
    {
      'title': 'Watch Salad Dressings',
      'text': 'Creamy salad dressings can add hundreds of hidden calories. Opt for olive oil and vinegar or lemon juice.'
    },
    {
      'title': 'Post-meal Walk',
      'text': 'A light 10-minute walk after eating helps lower post-meal blood sugar levels and aids digestion.'
    },
    {
      'title': 'Listen to Your Body',
      'text': 'Eat when you are physically hungry, not just bored, stressed, or following a rigid clock schedule.'
    },
    {
      'title': 'Stay Consistent',
      'text': 'Healthy eating is about long-term habits. A single over-budget meal won\'t ruin your overall progress.'
    },
    {
      'title': 'Enjoy Dark Chocolate',
      'text': '70%+ dark chocolate is rich in antioxidants and can help satisfy sweet cravings in moderate amounts.'
    },
    {
      'title': 'Snack Smarter',
      'text': 'Prepare snacks like carrot sticks with hummus or apple slices with nut butter instead of chips.'
    },
    {
      'title': 'Celebrate Wins',
      'text': 'Acknowledge your efforts, whether it\'s logging food consistently or drinking more water. Consistency is key!'
    }
  ];
  final int _waterGoal = 2000;
  double _caloriesBurned = 0.0;
  List<Map<String, dynamic>> _todayWorkouts = [];

  Future<String> _getLocalPrefix() async {
    final email = await ApiService().getCurrentUserEmail() ?? '';
    return email.isNotEmpty ? '${email}_' : '';
  }

  Future<void> _loadLocalData(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getLocalPrefix();
    final dateKey = _dateStr(date);
    
    final waterKey = '${prefix}water_log_$dateKey';
    final workoutKey = '${prefix}workout_log_$dateKey';
    
    final water = prefs.getInt(waterKey) ?? 0;
    final workoutJson = prefs.getString(workoutKey);
    List<Map<String, dynamic>> workouts = [];
    double totalBurned = 0.0;
    
    if (workoutJson != null) {
      try {
        final decoded = jsonDecode(workoutJson) as List;
        workouts = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        for (final w in workouts) {
          totalBurned += (w['burned'] as num).toDouble();
        }
      } catch (e) {
        print("Error parsing workouts: $e");
      }
    }
    
    setState(() {
      _waterIntake = water;
      _todayWorkouts = workouts;
      _caloriesBurned = totalBurned;
    });
  }

  Future<void> _saveWaterIntake(int newVal) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getLocalPrefix();
    final dateKey = _dateStr(_selectedDate);
    final waterKey = '${prefix}water_log_$dateKey';
    
    final clampedVal = newVal.clamp(0, 10000);
    await prefs.setInt(waterKey, clampedVal);
    
    setState(() {
      _waterIntake = clampedVal;
    });
  }

  Future<void> _addWorkout(String activity, int duration, double burned) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getLocalPrefix();
    final dateKey = _dateStr(_selectedDate);
    final workoutKey = '${prefix}workout_log_$dateKey';
    
    final newWorkout = {
      'activity': activity,
      'duration': duration,
      'burned': burned,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final updatedList = List<Map<String, dynamic>>.from(_todayWorkouts)..add(newWorkout);
    await prefs.setString(workoutKey, jsonEncode(updatedList));
    
    setState(() {
      _todayWorkouts = updatedList;
      _caloriesBurned += burned;
    });
  }

  Future<void> _deleteWorkout(int index) async {
    if (index < 0 || index >= _todayWorkouts.length) return;
    
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getLocalPrefix();
    final dateKey = _dateStr(_selectedDate);
    final workoutKey = '${prefix}workout_log_$dateKey';
    
    final removedBurned = (_todayWorkouts[index]['burned'] as num).toDouble();
    
    final updatedList = List<Map<String, dynamic>>.from(_todayWorkouts)..removeAt(index);
    await prefs.setString(workoutKey, jsonEncode(updatedList));
    
    setState(() {
      _todayWorkouts = updatedList;
      _caloriesBurned -= removedBurned;
      if (_caloriesBurned < 0) _caloriesBurned = 0.0;
    });
  }

  void _showAddWorkoutSheet(BuildContext context) {
    _userFuture.then((user) {
      final double weight = user?.weight ?? 70.0;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _AddWorkoutBottomSheet(
          userWeight: weight,
          onSave: (activity, duration, burned) {
            _addWorkout(activity, duration, burned);
          },
        ),
      );
    });
  }

  Future<void> _loadTipState() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getLocalPrefix();
    final todayStr = _dateStr(DateTime.now());
    final dismissedDate = prefs.getString('${prefix}dismissed_tip_date');
    setState(() {
      _tipDismissed = dismissedDate == todayStr;
    });
  }

  Future<void> _dismissTip() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getLocalPrefix();
    final todayStr = _dateStr(DateTime.now());
    await prefs.setString('${prefix}dismissed_tip_date', todayStr);
    setState(() {
      _tipDismissed = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().getProfile();
    _streakFuture = FoodService().getStreak().catchError((_) => <String, dynamic>{});
    _planFuture = FoodService().getCaloriePlan().catchError((_) => <String, dynamic>{});
    _loadDayData(_selectedDate);
    _loadWeekData();
    _loadTipState();
  }

  String _dateStr(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";

  void _loadDayData(DateTime date) {
    setState(() {
      _dayFuture = FoodService()
          .getDayProgress(_dateStr(date))
          .catchError((_) => <String, dynamic>{});
    });
    _loadLocalData(date);
  }

  void _loadWeekData() {
    setState(() {
      _weekFuture = FoodService()
          .getWeekProgress()
          .catchError((_) => <Map<String, dynamic>>[]);
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() => _selectedDate = date);
    _loadDayData(date);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: FutureBuilder<UserModel?>(
                              future: _userFuture,
                              builder: (context, snapshot) {
                                final imageUrl = snapshot.data?.profileImageUrl;
                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  return CircleAvatar(
                                    radius: 23.5,
                                    backgroundImage: NetworkImage(
                                      imageUrl.startsWith('http')
                                          ? imageUrl
                                          : '${ApiService.baseUrl}$imageUrl',
                                    ),
                                  );
                                }
                                return const CircleAvatar(
                                  radius: 23.5,
                                  backgroundImage: AssetImage(
                                    'assets/images/profilee.png',
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FutureBuilder<UserModel?>(
                              future: _userFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading...",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  );
                                }
                                final String displayName =
                                    snapshot.data?.fullName ?? "User";
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hello, $displayName",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff141414)),
                                    ),
                                    const Text(
                                      "Remember why you started..",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff464646),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () =>
                              context.push('/notificationsScreen'),
                          icon: const Icon(
                            Icons.notifications,
                            size: 20,
                            color: Color(0xff210701),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _streakFuture,
                            builder: (context, snap) {
                              final streakCount =
                                  snap.data?['streak_count'] ?? 0;
                              final isActive =
                                  snap.data?['is_active'] ?? false;
                              return InkWell(
                                onTap: () => context.push('/streak'),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/streak.png',
                                      height: 18,
                                      color: isActive
                                          ? null
                                          : const Color(0xffD9D9D9),
                                    ),
                                    Text(
                                      " $streakCount",
                                      style: TextStyle(
                                        color: isActive
                                            ? const Color(0xffD90C0C)
                                            : const Color(0xffD9D9D9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              if (!_tipDismissed && _dateStr(_selectedDate) == _dateStr(DateTime.now())) ...[
                _TipOfTheDayCard(
                  tipTitle: _tipsPool[DateTime.now().day % _tipsPool.length]['title']!,
                  tipText: _tipsPool[DateTime.now().day % _tipsPool.length]['text']!,
                  onDismiss: _dismissTip,
                ),
                const SizedBox(height: 15),
              ],

              // ── Days-of-week bar (fetches its own per-day data) ──────
              DaysOfWeekBar(
                selectedDate: _selectedDate,
                weekFuture: _weekFuture,
                onDateSelected: _onDaySelected,
              ),

              const SizedBox(height: 30),

              // ── Progress cards (PageView) ────────────────────────────
              SizedBox(
                height: 380,
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    _dayFuture ?? Future.value(<String, dynamic>{}),
                    _planFuture,
                  ]),
                  builder: (context, snapshot) {
                    final dayData = snapshot.data?[0] is Map
                        ? Map<String, dynamic>.from(
                            snapshot.data![0] as Map)
                        : <String, dynamic>{};
                    final planData = snapshot.data?[1] is Map
                        ? Map<String, dynamic>.from(
                            snapshot.data![1] as Map)
                        : <String, dynamic>{};

                    final dailyCal =
                        (dayData['goal_calories'] ?? planData['calories'] ?? 2400)
                            .toDouble();
                    final consumed =
                        (dayData['calories'] ?? 0).toDouble();
                    // Remaining = Goal - Consumed + Burned
                    final remaining = dailyCal - consumed + _caloriesBurned;
                    final progress = (dailyCal + _caloriesBurned) > 0
                        ? consumed / (dailyCal + _caloriesBurned)
                        : 0.0;
 final progressClamped = progress.clamp(0.0, 1.5);
                    final fats = (dayData['fats'] ?? 0).toDouble();
                    final protein = (dayData['protein'] ?? 0).toDouble();
                    final carbs = (dayData['carbs'] ?? 0).toDouble();

                    double totalMacros = fats + protein + carbs;
                    double fatPct =
                        totalMacros > 0 ? fats / totalMacros : 0.0;
                    double proteinPct =
                        totalMacros > 0 ? protein / totalMacros : 0.0;
                    double carbsPct =
                        totalMacros > 0 ? carbs / totalMacros : 0.0;

                    final isToday = _dateStr(_selectedDate) ==
                        _dateStr(DateTime.now());
                    final progressLabel = isToday
                        ? "Today's Progress"
                        : "Progress of day ${_selectedDate.day}";

                    // Show loading indicator while fetching
                    final isLoading = snapshot.connectionState ==
                        ConnectionState.waiting;

                    return Stack(
                      children: [
                        PageView(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          children: [
                            _DailyProgressCard(
                              size: size,
                              consumed: consumed,
                              dailyCal: dailyCal,
                              remaining: remaining,
                              progress: progress,
                              title: progressLabel,
                              burned: _caloriesBurned,
                            ),
                            // ── Calories Breakdown card ──────────────
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Calories Breakdown',
                                      style: TextStyle(
                                        color: Color(0xff1E1B39),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularPercentIndicator(
                                            radius: 68.5,
                                            lineWidth: 15.0,
                                            percent: 1.0,
                                            progressColor: consumed == 0
                                                ? Colors.grey.shade300
                                                : Colors.blue,
                                            backgroundColor:
                                                Colors.transparent,
                                            reverse: true,
                                            center: Text(
                                              "${consumed.toStringAsFixed(0)}\nCalories",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                          CircularPercentIndicator(
                                            radius: 68.5,
                                            lineWidth: 15.0,
                                            percent: (proteinPct + fatPct)
                                                .clamp(0.0, 1.0),
                                            progressColor: Colors.red,
                                            backgroundColor:
                                                Colors.transparent,
                                            reverse: true,
                                          ),
                                          CircularPercentIndicator(
                                            radius: 68.5,
                                            lineWidth: 15.0,
                                            percent:
                                                fatPct.clamp(0.0, 1.0),
                                            progressColor: Colors.orange,
                                            backgroundColor:
                                                Colors.transparent,
                                            reverse: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 15,
                                      ),
                                      child: Column(
                                        children: [
                                          _macroBreakdownLabel(
                                              Colors.orange,
                                              "Fats",
                                              "${fats.toStringAsFixed(0)}g"),
                                          const SizedBox(height: 5),
                                          _macroBreakdownLabel(
                                              Colors.red,
                                              "Protein",
                                              "${protein.toStringAsFixed(0)}g"),
                                          const SizedBox(height: 5),
                                          _macroBreakdownLabel(
                                              Colors.blue,
                                              "Carbs",
                                              "${carbs.toStringAsFixed(0)}g"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ── Page indicator dots ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _currentPage == index
                          ? Colors.black
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const _AIHealthHubCard(),
              const SizedBox(height: 20),
              _WaterTrackerCard(
                waterIntake: _waterIntake,
                waterGoal: _waterGoal,
                onAddWater: (amount) => _saveWaterIntake(_waterIntake + amount),
                onSetWater: (amount) => _saveWaterIntake(amount),
              ),
              const SizedBox(height: 15),
              _WorkoutLoggerCard(
                workouts: _todayWorkouts,
                caloriesBurned: _caloriesBurned,
                onAddWorkoutTap: () => _showAddWorkoutSheet(context),
                onDeleteWorkout: _deleteWorkout,
              ),
              const SizedBox(height: 25),

              // ── Recently Logged meals for selected day ───────────────
              FutureBuilder<Map<String, dynamic>>(
                future: _dayFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  final data = snapshot.data ?? {};
                  final List meals =
                      data['meals'] ?? data['logs'] ?? [];

                  if (meals.isEmpty) return const SizedBox.shrink();

                  final isToday = _dateStr(_selectedDate) ==
                      _dateStr(DateTime.now());
                  final sectionTitle = isToday
                      ? "Recently Logged"
                      : "Logged on ${_selectedDate.day} ${DateFormat('MMM').format(_selectedDate)}";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          sectionTitle,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 350,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10),
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              meals.length > 5 ? 5 : meals.length,
                          itemBuilder: (context, index) {
                            final meal = meals[index] is Map
                                ? Map<String, dynamic>.from(
                                    meals[index] as Map)
                                : <String, dynamic>{};
                            return FoodCard(mealData: meal);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroBreakdownLabel(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 3, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
              color: Color(0xff9291A5), fontSize: 12),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// DaysOfWeekBar — fetches per-day data and colours each circle independently
// ════════════════════════════════════════════════════════════════════════

class DaysOfWeekBar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  /// Optional pre-fetched week data from the parent.
  final Future<List<Map<String, dynamic>>>? weekFuture;
 
  const DaysOfWeekBar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.weekFuture,
  });
 
  @override
  State<DaysOfWeekBar> createState() => _DaysOfWeekBarState();
}
 
class _DaysOfWeekBarState extends State<DaysOfWeekBar> {
  late Future<List<Map<String, dynamic>>> _future;
  late final List<DateTime> _dateRange;
 
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange =
        List.generate(8, (i) => now.subtract(Duration(days: 7 - i)));
    _future = widget.weekFuture ?? _fetchWeek();
  }
 
  @override
  void didUpdateWidget(covariant DaysOfWeekBar old) {
    super.didUpdateWidget(old);
    if (widget.weekFuture != null &&
        widget.weekFuture != old.weekFuture) {
      setState(() => _future = widget.weekFuture!);
    }
  }
 
  Future<List<Map<String, dynamic>>> _fetchWeek() async {
    // Implementation here
    return [];
  }
 
  String _fmt(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";
 
  /// Determine color based on calorie intake vs goal
  Color _dayColor(Map<String, dynamic>? dayData) {
    if (dayData == null) return Colors.grey.shade300;
    
    final hasData =
        dayData['has_data'] == true || (dayData['calories'] ?? 0) > 0;
    if (!hasData) return Colors.grey.shade300;
 
    final consumed = (dayData['calories'] ?? 0).toDouble();
    final goal = (dayData['goal_calories'] ?? 2400).toDouble();
    if (goal <= 0) return Colors.grey.shade300;
 
    // Calculate difference percentage
    final diff = ((consumed - goal) / goal).abs();
    
    // Green: ±5% of goal
    if (diff <= 0.05) return Colors.green;
    // Orange: ±5% to ±15% of goal
    if (diff <= 0.15) return Colors.orange;
    // Red: >±15% of goal
    return Colors.red;
  }
 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        final Map<String, Map<String, dynamic>> byDate = {};
        if (snapshot.hasData) {
          for (final day in snapshot.data!) {
            final d = day['date']?.toString() ?? '';
            if (d.isNotEmpty) byDate[d] = day;
          }
        }
 
        final loading =
            snapshot.connectionState == ConnectionState.waiting;
 
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              final date = _dateRange[index];
              final dateStr = _fmt(date);
              final isSelected = dateStr == _fmt(widget.selectedDate);
              final dayData = byDate[dateStr];
 
              // FIX: Only color if selected, otherwise always gray
              final Color bgColor = loading
                  ? Colors.grey.shade200
                  : isSelected
                      ? _dayColor(dayData)  // ← Show color only when selected
                      : Colors.grey.shade300;  // ← Always gray otherwise
 
              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: bgColor,
                      child: loading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            )
                          : Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('E').format(date),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
 

// ════════════════════════════════════════════════════════════════════════
// _DailyProgressCard
// ════════════════════════════════════════════════════════════════════════

class _DailyProgressCard extends StatelessWidget {
  final Size size;
  final double consumed;
  final double dailyCal;
  final double remaining;
  final double progress; // uncapped — can be > 1.0
  final String title;
  final double burned;

  const _DailyProgressCard({
    required this.size,
    required this.consumed,
    required this.dailyCal,
    required this.remaining,
    required this.progress,
    required this.title,
    this.burned = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final double budget = dailyCal + burned;
    final bool isOver = consumed > budget;
    // Label reflects over-goal state
    final String statusLabel = consumed == 0
        ? "No Data"
        : isOver
            ? "Goal Exceeded!"
            : progress >= 0.8
                ? "Almost There"
                : progress >= 0.5
                    ? "On Track"
                    : "In Progress";

    Color progressColor = Colors.grey.shade300;
    if (consumed > 0 && budget > 0) {
      final diff = ((consumed - budget) / budget).abs();
      if (diff <= 0.05) {
        progressColor = Colors.green;
      } else if (diff <= 0.15) {
        progressColor = Colors.orange;
      } else {
        progressColor = Colors.red;
      }
    }

    final Color statusColor = consumed == 0
        ? Colors.grey
        : progressColor;

    // How many calories over the goal (positive = over)
    final double overBy = consumed - budget;

    // Remaining label: show negative (over by X) or positive
    final String remainingLabel = consumed == 0
        ? '--'
        : isOver
            ? '+${overBy.toStringAsFixed(0)}'
            : remaining.toStringAsFixed(0);

    return Container(
      width: size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 64,
            lineWidth: 5,
            // Clamp to 1.0 for the visual ring — the label shows the real %
            percent: progress.clamp(0.0, 1.0),
            progressColor: progressColor,
            backgroundColor: Colors.grey.shade100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  consumed == 0 ? "--" : consumed.toStringAsFixed(0),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  consumed == 0
                      ? "No logs"
                      : "of ${budget.toStringAsFixed(0)}",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ProgressItem(
                    img: 'assets/images/bultorone fireee.png',
                    label:
                        "${consumed == 0 ? '--' : consumed.toStringAsFixed(0)}\nConsumed"),
              ),
              Expanded(
                child: ProgressItem(
                    img: 'assets/images/target.png',
                    label:
                        // When over-goal show "+X over" instead of "0 Remaining"
                        "$remainingLabel\n${isOver ? 'Over Goal' : 'Remaining'}"),
              ),
              Expanded(
                child: ProgressItem(
                    img: 'assets/images/chart.png',
                    label:
                        "${consumed == 0 ? '--' : (progress * 100).toStringAsFixed(1) + '%'}\nProgress"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// FoodCard
// ════════════════════════════════════════════════════════════════════════

class FoodCard extends StatelessWidget {
  final Map<String, dynamic>? mealData;
  const FoodCard({super.key, this.mealData});

  @override
  Widget build(BuildContext context) {
    final name =
        mealData?['food_name'] ?? mealData?['meal_name'] ?? "Meal";
    final timestamp =
        mealData?['logged_at'] ?? mealData?['log_time'] ?? mealData?['timestamp'] ?? "";
    String timeStr = "Logged";
    if (timestamp.toString().isNotEmpty) {
      try {
        String ts = timestamp.toString();
        if (ts.contains(' ') && !ts.contains('T')) {
          ts = ts.replaceFirst(' ', 'T');
        }
        final parsed = DateTime.parse(ts);
        timeStr = DateFormat.jm().format(parsed.isUtc ? parsed.toLocal() : parsed);
      } catch (_) {
        try {
          final parsed = DateTime.parse(timestamp.toString());
          timeStr = DateFormat.jm().format(parsed.isUtc ? parsed.toLocal() : parsed);
        } catch (_) {}
      }
    }

    final proteinVal = (mealData?['protein'] ?? 0).toDouble();
    final carbsVal = (mealData?['carbs'] ?? 0).toDouble();
    final fatsVal = (mealData?['fats'] ?? 0).toDouble();
    final calories = (mealData?['calories'] ?? 0).toDouble();
    final totalMacro = proteinVal + carbsVal + fatsVal;

    // image_url is pre-resolved by FoodService._enrichLogsWithImages()
    final imageUrl = mealData?['image_url']?.toString();
    final fallbackUrl = 'https://loremflickr.com/150/150/food,${Uri.encodeComponent(name)}?lock=${name.hashCode.abs()}';
    final resolvedUrl = imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null' ? imageUrl : fallbackUrl;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15, bottom: 10, left: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.network(
              resolvedUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/food.png',
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      "$name",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    )),
                    Column(
                      children: [
                        Text("${calories.toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text("Calories",
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ],
                ),
                Text(timeStr,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _macroCircle(
                        totalMacro > 0 ? proteinVal / totalMacro : 0,
                        Colors.red),
                    const SizedBox(width: 8),
                    _macroCircle(
                        totalMacro > 0 ? carbsVal / totalMacro : 0,
                        Colors.black),
                    const SizedBox(width: 8),
                    _macroCircle(
                        totalMacro > 0 ? fatsVal / totalMacro : 0,
                        Colors.grey),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        final name = mealData?['food_name'] ?? mealData?['meal_name'] ?? 'Meal';
                        final imageUrl = mealData?['image_url']?.toString();
                        
                        final String source;
                        if (mealData?['fdc_id'] != null) {
                          source = 'usda_fdc';
                        } else if (mealData?['barcode'] != null) {
                          source = 'open_food_facts';
                        } else if (mealData?['scan_id'] != null) {
                          source = 'saved_scans';
                        } else if (mealData?['meal_type'] != null) {
                          source = 'my_meals';
                        } else {
                          source = 'my_foods';
                        }

                        context.push(
                          '/servingsDatabase',
                          extra: {
                            'source': source,
                            'fdcId': mealData?['fdc_id']?.toString(),
                            'barcode': mealData?['barcode']?.toString(),
                            'scanId': mealData?['scan_id']?.toString(),
                            'logId': mealData?['log_id']?.toString() ?? mealData?['id']?.toString(),
                            'mealType': mealData?['meal_type']?.toString(),
                            'imageUrl': imageUrl,
                            'item': mealData,
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Text("View Details",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroLabel(Colors.red,
                        "Protein ${proteinVal.toStringAsFixed(0)}g"),
                    _macroLabel(Colors.black,
                        "Carbs ${carbsVal.toStringAsFixed(0)}g"),
                    _macroLabel(
                        Colors.grey, "Fats ${fatsVal.toStringAsFixed(0)}g"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroCircle(double percent, Color color) {
    return CircularPercentIndicator(
      radius: 16,
      lineWidth: 5,
      percent: percent.clamp(0.0, 1.0),
      progressColor: color,
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _macroLabel(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ProgressItem
// ════════════════════════════════════════════════════════════════════════

class ProgressItem extends StatelessWidget {
  final String img;
  final String label;
  const ProgressItem({super.key, required this.img, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(img, height: 22),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// _WaterTrackerCard
// ════════════════════════════════════════════════════════════════════════

class _WaterTrackerCard extends StatelessWidget {
  final int waterIntake;
  final int waterGoal;
  final ValueChanged<int> onAddWater;
  final ValueChanged<int> onSetWater;

  const _WaterTrackerCard({
    required this.waterIntake,
    required this.waterGoal,
    required this.onAddWater,
    required this.onSetWater,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_drink_rounded, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Water Tracker",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1B39),
                    ),
                  ),
                ],
              ),
              Text(
                "$waterIntake / $waterGoal ml",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              final cupVol = (index + 1) * 250;
              final isFilled = waterIntake >= cupVol;
              return Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => onSetWater(cupVol),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isFilled ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: isFilled ? Colors.blueAccent : Colors.grey.shade300,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: waterIntake > 0 ? () => onAddWater(-250) : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove, size: 16),
                      SizedBox(width: 4),
                      Text("-250 ml", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onAddWater(250),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    foregroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 4),
                      Text("+250 ml", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onAddWater(500),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_drink_rounded, size: 16),
                      SizedBox(width: 4),
                      Text("+500 ml", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// _WorkoutLoggerCard
// ════════════════════════════════════════════════════════════════════════

class _WorkoutLoggerCard extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  final double caloriesBurned;
  final VoidCallback onAddWorkoutTap;
  final ValueChanged<int> onDeleteWorkout;

  const _WorkoutLoggerCard({
    required this.workouts,
    required this.caloriesBurned,
    required this.onAddWorkoutTap,
    required this.onDeleteWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: Color(0xFFD90C0C), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Workout Logger",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1B39),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE1E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (workouts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  "No workouts logged for today yet.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workouts.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final workout = workouts[index];
                final activity = workout['activity'] ?? 'Workout';
                final duration = workout['duration'] ?? 0;
                final burned = (workout['burned'] ?? 0.0) as num;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFFFE1E1),
                          child: Icon(Icons.fitness_center_rounded, size: 16, color: Color(0xFFD90C0C)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "$duration min",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "-${burned.toStringAsFixed(0)} kcal",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD90C0C)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmation(context, index),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddWorkoutTap,
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Log Active Workout", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFFE1E1),
                foregroundColor: const Color(0xFF8C0B0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFFD90C0C), width: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Workout Log?"),
        content: const Text("Are you sure you want to delete this workout entry? This will adjust your daily calorie budget."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              onDeleteWorkout(index);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// _AddWorkoutBottomSheet
// ════════════════════════════════════════════════════════════════════════

class _AddWorkoutBottomSheet extends StatefulWidget {
  final double userWeight;
  final Function(String activity, int duration, double burned) onSave;

  const _AddWorkoutBottomSheet({
    super.key,
    required this.userWeight,
    required this.onSave,
  });

  @override
  State<_AddWorkoutBottomSheet> createState() => _AddWorkoutBottomSheetState();
}

class _AddWorkoutBottomSheetState extends State<_AddWorkoutBottomSheet> {
  String _selectedActivity = 'Running';
  int _duration = 30;
  double _customCalories = 0.0;
  final TextEditingController _customCalController = TextEditingController();

  final Map<String, double> _metValues = {
    'Running': 8.0,
    'Walking': 3.5,
    'Cycling': 6.0,
    'Weightlifting': 4.0,
    'Yoga': 2.5,
    'Swimming': 6.0,
    'Custom': 5.0,
  };

  double get _estimatedBurn {
    if (_selectedActivity == 'Custom') {
      return _customCalories;
    }
    final met = _metValues[_selectedActivity] ?? 5.0;
    return met * 3.5 * widget.userWeight / 200.0 * _duration;
  }

  @override
  void dispose() {
    _customCalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(25, 25, 25, 25 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Log Active Workout",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Activity",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: _metValues.keys.map((activity) {
                  final isSelected = _selectedActivity == activity;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(activity),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFFE1E1),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF8C0B0B) : Colors.black87,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedActivity = activity;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Duration",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  "$_duration min",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8C0B0B)),
                ),
              ],
            ),
            Slider(
              value: _duration.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              activeColor: const Color(0xFFD90C0C),
              inactiveColor: const Color(0xFFFFE1E1),
              onChanged: (val) {
                setState(() {
                  _duration = val.round();
                });
              },
            ),
            if (_selectedActivity == 'Custom') ...[
              const SizedBox(height: 10),
              const Text(
                "Calories Burned (kcal)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customCalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter burned calories",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {
                    _customCalories = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
            ],
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1E1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFD90C0C), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Estimated Burn",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8C0B0B)),
                        ),
                        Text(
                          "${_estimatedBurn.toStringAsFixed(0)} kcal",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD90C0C)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "(${widget.userWeight.toStringAsFixed(0)} kg weight)",
                    style: TextStyle(fontSize: 12, color: const Color(0xFF8C0B0B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_selectedActivity, _duration, _estimatedBurn);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD90C0C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Save Workout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// _AIHealthHubCard
// ════════════════════════════════════════════════════════════════════════

class _AIHealthHubCard extends StatelessWidget {
  const _AIHealthHubCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Color(0xff1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Health Hub",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "Powered by Gemini AI",
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/ai_coach'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.forum_rounded, color: Colors.white, size: 22),
                        SizedBox(height: 6),
                        Text(
                          "AI Coach Chat",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/recipe_generator'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 22),
                        SizedBox(height: 6),
                        Text(
                          "Recipe Maker",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// _TipOfTheDayCard
// ════════════════════════════════════════════════════════════════════════

class _TipOfTheDayCard extends StatelessWidget {
  final String tipTitle;
  final String tipText;
  final VoidCallback onDismiss;

  const _TipOfTheDayCard({
    required this.tipTitle,
    required this.tipText,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 0, 0, 0), const Color.fromARGB(255, 59, 60, 60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.teal.withOpacity(0.15),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_rounded, color: Colors.yellowAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tip of the Day",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tipTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tipText,
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), height: 1.3),
                    ),
                ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: Colors.white.withOpacity(0.8), size: 18),
            ),
          ),
        ],
      ),
    );
  }
}