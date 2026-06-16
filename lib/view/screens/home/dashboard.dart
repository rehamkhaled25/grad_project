import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/view/screens/database/servings_database.dart';

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

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().getProfile();
    _streakFuture = FoodService().getStreak().catchError((_) => <String, dynamic>{});
    _planFuture = FoodService().getCaloriePlan().catchError((_) => <String, dynamic>{});
    _loadDayData(_selectedDate);
    _loadWeekData();
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

              const SizedBox(height: 40),

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
                    // NOTE: NOT clamped — negative value means calories exceeded goal.
                    // _DailyProgressCard handles the display of over-goal state.
                    final remaining = dailyCal - consumed;
                    final progress = dayData['progress'] != null
                        ? (dayData['progress'] as num).toDouble()
                        : (dailyCal > 0
                            ? (consumed / dailyCal)
                            : 0.0);
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

  const _DailyProgressCard({
    required this.size,
    required this.consumed,
    required this.dailyCal,
    required this.remaining,
    required this.progress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOver = progress > 1.0;
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
    if (consumed > 0 && dailyCal > 0) {
      final diff = ((consumed - dailyCal) / dailyCal).abs();
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
    final double overBy = consumed - dailyCal;

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
                      : "of ${dailyCal.toStringAsFixed(0)}",
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