import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/api_service.dart';

class LogFood extends StatefulWidget {
  const LogFood({super.key});

  @override
  State<LogFood> createState() => _LogFoodState();
}

class _LogFoodState extends State<LogFood> {
  Map<String, dynamic>? _historyData;
  Map<String, dynamic>? _planData;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final futures = await Future.wait([
        FoodService().getFoodHistory().catchError((_) => <String, dynamic>{}),
        FoodService().getCaloriePlan().catchError((_) => <String, dynamic>{}),
      ]);
      if (mounted) {
        setState(() {
          _historyData = futures[0];
          _planData = futures[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;

    // Extract totals from history
    final totals = (_historyData?['totals'] as Map<String, dynamic>?) ?? {};
    final consumed = (totals['calories'] ?? 0).toDouble();
    final dailyCal = (_planData?['calories'] ?? 2400).toDouble();
    final burned = 0.0; // Backend doesn't track burned yet
    final remaining = (dailyCal - consumed).clamp(0, dailyCal);
    final progress = dailyCal > 0 ? (consumed / dailyCal).clamp(0.0, 1.0) : 0.0;

    // Extract grouped meals
    final grouped = (_historyData?['grouped'] as Map<String, dynamic>?) ?? {};
    final breakfastList = (grouped['breakfast'] as List?) ?? [];
    final lunchList = (grouped['lunch'] as List?) ?? [];
    final dinnerList = (grouped['dinner'] as List?) ?? [];
    final snackList = (grouped['snack'] as List?) ?? [];

    // Calorie advisories from plan
    final breakfastCal = (dailyCal * 0.3).toInt();
    final lunchCal = (dailyCal * 0.35).toInt();
    final dinnerCal = (dailyCal * 0.25).toInt();

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: size.height * 0.02,
                ),
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/placeholder_profile.png',
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          });
                          _loadData();
                        },
                        child: Icon(Icons.arrow_back_ios, color: const Color(0xffD9D9D9), size: width * 0.04),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_selectedDate),
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = _selectedDate.add(const Duration(days: 1));
                          });
                          _loadData();
                        },
                        child: Icon(Icons.arrow_forward_ios, color: const Color(0xffD9D9D9), size: width * 0.04),
                      ),
                      const Spacer(),
                      SizedBox(width: width * 0.1),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const DaysOfWeekBar(),
                  const SizedBox(height: 25),

                  // Progress card with real data
                  _DailyProgressCard(
                    size: size,
                    consumed: consumed,
                    dailyCal: dailyCal,
                    burned: burned,
                    remaining: remaining.toDouble(),
                    progress: progress.toDouble(),
                  ),
                  const SizedBox(height: 30),

                  // Meal cards with real logged items
                  _MealCardWithItems(title: "Breakfast", subtitle: "$breakfastCal calories advised", items: breakfastList),
                  const SizedBox(height: 15),
                  _MealCardWithItems(title: "Lunch", subtitle: "$lunchCal calories advised", items: lunchList),
                  const SizedBox(height: 15),
                  _MealCardWithItems(title: "Dinner", subtitle: "$dinnerCal calories advised", items: dinnerList),
                  const SizedBox(height: 15),
                  _MealCardWithItems(title: "Snack", subtitle: "Snacks", items: snackList),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }
}

class _DailyProgressCard extends StatelessWidget {
  final Size size;
  final double consumed;
  final double dailyCal;
  final double burned;
  final double remaining;
  final double progress;

  const _DailyProgressCard({
    required this.size,
    required this.consumed,
    required this.dailyCal,
    required this.burned,
    required this.remaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                progress >= 0.8 ? "Almost There" : progress >= 0.5 ? "On Track" : "Getting Started",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: size.width * 0.35,
                width: size.width * 0.35,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: const Color(0xffEEEEEE),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffD90C0C)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size.width * 0.28,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("${consumed.toStringAsFixed(0)}", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Text("of ${dailyCal.toStringAsFixed(0)}", style: const TextStyle(color: Colors.black, fontSize: 10)),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('assets/images/flame bta3et saf7et el database.png', "${burned.toStringAsFixed(0)}", "Burned"),
              _buildStat('assets/images/target.png', "${remaining.toStringAsFixed(0)}", "Remaining"),
              _buildStat('assets/images/chart.png', "${(progress * 100).toStringAsFixed(1)}%", "Progress"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String assetPath, String value, String label) {
    return Column(
      children: [
        Image.asset(assetPath, height: 20, color: Colors.black),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

class _MealCardWithItems extends StatelessWidget {
  final String title;
  final String subtitle;
  final List items;

  const _MealCardWithItems({required this.title, required this.subtitle, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Row(
              children: [
                Image.asset(
                  'assets/images/flame bta3et saf7et el database.png',
                  color: const Color(0xffB3B3B3),
                  height: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const AddFoodButton(),
              ],
            )
          else
            ...items.map((item) {
              final logItem = item as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            logItem['food_name'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                "${logItem['serving_name'] ?? '1 serving'}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(width: 10),
                              Image.asset(
                                'assets/images/flame bta3et saf7et el database.png',
                                color: const Color(0xffB3B3B3),
                                height: 14,
                              ),
                              Text(
                                " ${(logItem['calories'] ?? 0).toStringAsFixed(0)}",
                                style: const TextStyle(color: Color(0xffB3B3B3), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerRight, child: AddFoodButton()),
          ],
        ],
      ),
    );
  }
}

class AddFoodButton extends StatelessWidget {
  const AddFoodButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      
      onTap: () {
          context.push("/log");
     
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xffF2F2F2),
          boxShadow: const [
            BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
          ],
        ),
        child: const Text(
          "Add food",
          style: TextStyle(color: Color(0xffD90C0C), fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}