import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:intl/intl.dart';

class LogFood extends StatefulWidget {
  const LogFood({super.key});

  @override
  State<LogFood> createState() => _LogFoodState();
}

class _LogFoodState extends State<LogFood> {
  Map<String, dynamic>? _historyData;
  Map<String, dynamic>? _planData;
  bool _isLoading = true;
  String? _profileImageUrl;
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
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final results = await Future.wait([
        FoodService().getFoodHistory(date: dateStr).catchError((_) => <String, dynamic>{}),
        FoodService().getCaloriePlan().catchError((_) => <String, dynamic>{}),
        ApiService().getProfile().catchError((_) => null),
      ]);

      if (mounted) {
        setState(() {
          _historyData = results[0] is Map ? Map<String, dynamic>.from(results[0] as Map) : null;
          _planData = results[1] is Map ? Map<String, dynamic>.from(results[1] as Map) : null;
          final profile = results[2];
          if (profile != null) {
            _profileImageUrl = (profile as dynamic).profileImageUrl as String?;
          }
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

    final totals = _historyData?['totals'] is Map ? Map<String, dynamic>.from(_historyData!['totals']) : <String, dynamic>{};
    final consumed = (totals['calories'] ?? 0).toDouble();
    final dailyCal = (_planData?['calories'] ?? 2400).toDouble();
    final remaining = (dailyCal - consumed).clamp(0.0, dailyCal);
    final progress = dailyCal > 0 ? (consumed / dailyCal).clamp(0.0, 1.0) : 0.0;

    final grouped = _historyData?['grouped'] is Map ? Map<String, dynamic>.from(_historyData!['grouped']) : <String, dynamic>{};
    final breakfastList = (grouped['breakfast'] as List?) ?? [];
    final lunchList = (grouped['lunch'] as List?) ?? [];
    final dinnerList = (grouped['dinner'] as List?) ?? [];
    final snackList = (grouped['snack'] as List?) ?? [];

    final breakfastCal = (dailyCal * 0.3).toInt();
    final lunchCal = (dailyCal * 0.35).toInt();
    final dinnerCal = (dailyCal * 0.25).toInt();

    final bool isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String progressTitle = isToday ? "Today's Progress" : "Progress of day ${_selectedDate.day}";

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
                      _profileImageUrl != null
                          ? CircleAvatar(
                              radius: 23.5,
                              backgroundImage: NetworkImage(
                                _profileImageUrl!.startsWith('http')
                                    ? _profileImageUrl!
                                    : '${ApiService.baseUrl}$_profileImageUrl',
                              ),
                            )
                          : const CircleAvatar(
                              radius: 23.5,
                              backgroundImage: AssetImage(
                                'assets/images/profilee.png',
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
                          final isCurrentToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());
                          if (isCurrentToday) return; 
                          setState(() {
                            _selectedDate = _selectedDate.add(const Duration(days: 1));
                          });
                          _loadData();
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: isToday
                              ? const Color(0xFFE8E8E8)
                              : const Color(0xffD9D9D9),
                          size: width * 0.04,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: width * 0.1),
                    ],
                  ),
                  const SizedBox(height: 25),
                  DaysOfWeekBar(selectedDate: _selectedDate, consumed: consumed, dailyCal: dailyCal),
                  const SizedBox(height: 25),
                  _DailyProgressCard(
                    size: size,
                    consumed: consumed,
                    dailyCal: dailyCal,
                    remaining: remaining,
                    progress: progress,
                    title: progressTitle,
                  ),
                  const SizedBox(height: 30),
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
  final double remaining;
  final double progress;
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
    Color progressColor = Colors.grey.shade400;
    if (dailyCal > 0 && consumed > 0) {
      final diff = ((consumed - dailyCal) / dailyCal).abs();
      if (diff <= 0.05) {
        progressColor = Colors.green;
      } else if (diff <= 0.15) {
        progressColor = Colors.orange;
      } else {
        progressColor = Colors.red;
      }
    }

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
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                progress >= 0.8 ? "Almost There" : progress >= 0.5 ? "On Track" : "In Progress",
                style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 14),
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
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
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
              _buildStat('assets/images/flame bta3et saf7et el database.png', "${consumed.toStringAsFixed(0)}", "Consumed"),
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
                    style: const TextStyle(color:Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                AddFoodButton(mealType: title.toLowerCase()),
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
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              logItem['food_name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xffB3B3B3)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/images/flame bta3et saf7et el database.png',
                            color: Color(0xffB3B3B3),
                            height: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(logItem['calories'] ?? 0).toStringAsFixed(0)}",
                            style: const TextStyle(color: Color(0xffB3B3B3), fontSize: 12, fontWeight: FontWeight.bold),
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
            Align(alignment: Alignment.centerRight, child: AddFoodButton(mealType: title.toLowerCase())),
          ],
        ],
      ),
    );
  }
}

class DaysOfWeekBar extends StatelessWidget {
  final DateTime selectedDate;
  final double consumed;
  final double dailyCal;

  const DaysOfWeekBar({
    super.key,
    required this.selectedDate,
    this.consumed = 0,
    this.dailyCal = 0,
  });

  Color _calorieDotColor() {
    if (dailyCal <= 0 || consumed <= 0) return Colors.grey.shade400;
    final diff = ((consumed - dailyCal) / dailyCal).abs();
    if (diff <= 0.05) return Colors.green;
    if (diff <= 0.15) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> dateRange = List.generate(8, (index) => now.subtract(Duration(days: 7 - index)));

    final days = dateRange.map((d) => DateFormat('E').format(d)).toList();
    final dates = dateRange.map((d) => d.day).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(8, (index) {
          final isSelected = DateFormat('yyyy-MM-dd').format(dateRange[index]) == DateFormat('yyyy-MM-dd').format(selectedDate);

          Color bgColor = Colors.grey.shade300;
          if (isSelected) {
            bgColor = _calorieDotColor();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: bgColor,
                child: Text(
                  dates[index].toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class AddFoodButton extends StatelessWidget {
  final String? mealType;
  const AddFoodButton({super.key, this.mealType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push("/log", extra: mealType),
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