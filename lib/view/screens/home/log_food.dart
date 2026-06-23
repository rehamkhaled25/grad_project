import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  DateTime _selectedDate = FoodService.globalSelectedDate;
  double _caloriesBurned = 0.0;

  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<String> _getLocalPrefix() async {
    final email = await ApiService().getCurrentUserEmail() ?? '';
    return email.isNotEmpty ? '${email}_' : '';
  }

  Future<void> _loadLocalData(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getLocalPrefix();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    final workoutKey = '${prefix}workout_log_$dateStr';
    final workoutJson = prefs.getString(workoutKey);
    double totalBurned = 0.0;
    
    if (workoutJson != null) {
      try {
        final decoded = jsonDecode(workoutJson) as List;
        for (final w in decoded) {
          totalBurned += (w['burned'] as num).toDouble();
        }
      } catch (e) {
        print("Error parsing workouts in LogFood: $e");
      }
    }
    
    if (mounted) {
      setState(() {
        _caloriesBurned = totalBurned;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await _loadLocalData(_selectedDate);
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

  Future<void> _handleDelete(Map<String, dynamic> item) async {
    final logId = item['id'];
    if (logId == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete food log?"),
        content: Text("Are you sure you want to delete ${item['food_name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await FoodService().deleteFoodLog(logId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Food log deleted"), backgroundColor: Colors.black),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to delete food log: $e"), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  void _handleEdit(Map<String, dynamic> item) {
    final logId = item['id'];
    if (logId == null) return;

    final String foodName = item['food_name'] ?? 'Unknown';
    final double baseCal = double.tryParse((item['base_calories'] ?? (item['portion_multiplier'] != null && item['portion_multiplier'] > 0 ? (item['calories'] / item['portion_multiplier']) : item['calories'])).toString()) ?? 0.0;
    final double basePro = double.tryParse((item['base_protein'] ?? (item['portion_multiplier'] != null && item['portion_multiplier'] > 0 ? (item['protein'] / item['portion_multiplier']) : item['protein'])).toString()) ?? 0.0;
    final double baseCar = double.tryParse((item['base_carbs'] ?? (item['portion_multiplier'] != null && item['portion_multiplier'] > 0 ? (item['carbs'] / item['portion_multiplier']) : item['carbs'])).toString()) ?? 0.0;
    final double baseFat = double.tryParse((item['base_fats'] ?? (item['portion_multiplier'] != null && item['portion_multiplier'] > 0 ? (item['fats'] / item['portion_multiplier']) : item['fats'])).toString()) ?? 0.0;

    double baseSize = double.tryParse((item['portion_multiplier'] != null && item['portion_multiplier'] > 0 ? (item['serving_size'] / item['portion_multiplier']) : (item['serving_size'] ?? 1.0)).toString()) ?? 1.0;
    final String servingName = item['serving_name'] ?? 'serving';

    double multiplier = double.tryParse(item['portion_multiplier']?.toString() ?? '1.0') ?? 1.0;

    final TextEditingController controller = TextEditingController(text: multiplier.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double scaledCal = baseCal * multiplier;
            final double scaledPro = basePro * multiplier;
            final double scaledCar = baseCar * multiplier;
            final double scaledFat = baseFat * multiplier;
            final double scaledSize = baseSize * multiplier;

            final List<Map<String, dynamic>> quickChips = [
              {'label': '1/4', 'val': 0.25},
              {'label': '1/2', 'val': 0.5},
              {'label': '3/4', 'val': 0.75},
              {'label': '1', 'val': 1.0},
              {'label': '1.5', 'val': 1.5},
              {'label': '2', 'val': 2.0},
              {'label': '3', 'val': 3.0},
            ];

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Edit Portion: $foodName",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Live Preview Row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffF9F9F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Portion Preview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                              Text("${scaledSize.toStringAsFixed(1)} $servingName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _previewItem("Calories", "${scaledCal.toStringAsFixed(0)} kcal", Colors.redAccent.withOpacity(0.1), Colors.redAccent),
                              _previewItem("Protein", "${scaledPro.toStringAsFixed(1)}g", Colors.green.withOpacity(0.1), Colors.green),
                              _previewItem("Carbs", "${scaledCar.toStringAsFixed(1)}g", Colors.blue.withOpacity(0.1), Colors.blue),
                              _previewItem("Fats", "${scaledFat.toStringAsFixed(1)}g", Colors.orange.withOpacity(0.1), Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
  
                    // Quick Select Chips
                    const Text("Quick Select Serving", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickChips.map((chip) {
                        final val = chip['val'] as double;
                        final isSelected = (multiplier - val).abs() < 0.01;
                        return ChoiceChip(
                          label: Text(chip['label'], style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedColor: Colors.black,
                          backgroundColor: const Color(0xffEEEEEE),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                multiplier = val;
                                controller.text = val.toString();
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
  
                    // Custom Input
                    const Text("Custom Portion Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: "Enter custom serving multiplier (e.g. 1.25)",
                        suffixText: "servings",
                        filled: true,
                        fillColor: const Color(0xffF2F2F2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (text) {
                        final val = double.tryParse(text);
                        if (val != null && val > 0) {
                          setModalState(() {
                            multiplier = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
  
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              try {
                                final payload = {
                                  'calories': scaledCal,
                                  'protein': scaledPro,
                                  'carbs': scaledCar,
                                  'fats': scaledFat,
                                  'portion_multiplier': multiplier,
                                  'serving_size': scaledSize,
                                };
                                await FoodService().updateFoodLog(logId, payload);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("✅ Food log updated"), backgroundColor: Colors.black),
                                );
                                _loadData();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("❌ Failed to update: $e"), backgroundColor: Colors.red),
                                );
                                setState(() => _isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _previewItem(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.8), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _changeDate(DateTime date) {
    FoodService.globalSelectedDate = date;
    setState(() {
      _selectedDate = date;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (FoodService.globalSelectedDate != _selectedDate) {
      _selectedDate = FoodService.globalSelectedDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
    if (FoodService.needsRefresh) {
      FoodService.needsRefresh = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }

    final Size size = MediaQuery.of(context).size;
    final double width = size.width;

    final totals = _historyData?['totals'] is Map ? Map<String, dynamic>.from(_historyData!['totals']) : <String, dynamic>{};
    final consumed = (totals['calories'] ?? 0).toDouble();
    final dailyCal = (_planData?['calories'] ?? 2400).toDouble();
    final remaining = dailyCal - consumed + _caloriesBurned;
    final progress = (dailyCal + _caloriesBurned) > 0 ? consumed / (dailyCal + _caloriesBurned) : 0.0;

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
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: _profileImageUrl != null
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
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          _changeDate(_selectedDate.subtract(const Duration(days: 1)));
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
                          _changeDate(_selectedDate.add(const Duration(days: 1)));
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
                  DaysOfWeekBar(
                    selectedDate: _selectedDate,
                    consumed: consumed,
                    dailyCal: dailyCal + _caloriesBurned,
                    onDateSelected: _changeDate,
                  ),
                  const SizedBox(height: 25),
                  _DailyProgressCard(
                    size: size,
                    consumed: consumed,
                    dailyCal: dailyCal,
                    remaining: remaining,
                    progress: progress,
                    title: progressTitle,
                    burned: _caloriesBurned,
                  ),
                  const SizedBox(height: 30),
                  _MealCardWithItems(
                    title: "Breakfast",
                    subtitle: "$breakfastCal calories advised",
                    items: breakfastList,
                    onDelete: _handleDelete,
                    onEdit: _handleEdit,
                  ),
                  const SizedBox(height: 15),
                  _MealCardWithItems(
                    title: "Lunch",
                    subtitle: "$lunchCal calories advised",
                    items: lunchList,
                    onDelete: _handleDelete,
                    onEdit: _handleEdit,
                  ),
                  const SizedBox(height: 15),
                  _MealCardWithItems(
                    title: "Dinner",
                    subtitle: "$dinnerCal calories advised",
                    items: dinnerList,
                    onDelete: _handleDelete,
                    onEdit: _handleEdit,
                  ),
                  const SizedBox(height: 15),
                  _MealCardWithItems(
                    title: "Snack",
                    subtitle: "Snacks",
                    items: snackList,
                    onDelete: _handleDelete,
                    onEdit: _handleEdit,
                  ),
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
    final double diff = budget > 0 ? (consumed - budget) / budget : 0.0;
    final double absDiff = diff.abs();

    Color progressColor = Colors.grey.shade400;
    String statusLabel = "In Progress";

    if (consumed > 0 && budget > 0) {
      if (absDiff <= 0.05) {
        progressColor = Colors.green;
        statusLabel = "Goal Reached";
      } else if (absDiff <= 0.15) {
        progressColor = Colors.orange;
        statusLabel = "Almost There";
      } else {
        progressColor = Colors.red;
        if (diff > 0.15) {
          statusLabel = "Goal Exceeded!";
        } else {
          statusLabel = "In Progress";
        }
      }
    }

    final Color statusColor = consumed == 0
        ? Colors.grey
        : progressColor;

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
                statusLabel,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
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
                  value: progress.clamp(0.0, 1.0),
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
                  Text("of ${budget.toStringAsFixed(0)}", style: const TextStyle(color: Colors.black, fontSize: 10)),
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
  final Function(Map<String, dynamic> item) onDelete;
  final Function(Map<String, dynamic> item) onEdit;

  const _MealCardWithItems({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onDelete,
    required this.onEdit,
  });

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
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => onEdit(logItem),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => onDelete(logItem),
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
  final Function(DateTime)? onDateSelected;

  const DaysOfWeekBar({
    super.key,
    required this.selectedDate,
    this.consumed = 0,
    this.dailyCal = 0,
    this.onDateSelected,
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

          return GestureDetector(
            onTap: () {
              if (onDateSelected != null) {
                onDateSelected!(dateRange[index]);
              }
            },
            child: Column(
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
            ),
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