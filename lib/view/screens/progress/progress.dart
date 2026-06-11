import 'package:flutter/material.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:go_router/go_router.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<double> values = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  double get average => values.every((v) => v == 0) ? 0 : values.reduce((a, b) => a + b) / values.length;

  int _currentIndex = 2;

  // Dynamic data
  String _caloriesText = '...';
  String _streakText = '...';
  String _activeText = '...';

  // Dynamic weight data
  double _currentWeight = 170.0;
  double _startWeight = 180.0;
  double _goalWeight = 160.0;
  List<Map<String, dynamic>> _weightLogs = [];
  int selectedSegmentIndex = 1; // Default to '1M' (index 1)
  String _userGoal = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        FoodService().getWeeklyProgress().catchError((_) => <Map<String, dynamic>>[]),
        FoodService().getDailyProgress().catchError((_) => <String, dynamic>{}),
        FoodService().getStreak().catchError((_) => <String, dynamic>{}),
        ApiService().getProfile().catchError((_) => null),
        ApiService().getWeightHistory().catchError((_) => <Map<String, dynamic>>[]),
      ]);

      final weekly = results[0] as List<Map<String, dynamic>>;
      final daily = results[1] as Map<String, dynamic>;
      final streak = results[2] as Map<String, dynamic>;
      final profile = results[3] as UserModel?;
      final weightLogs = results[4] as List<Map<String, dynamic>>;

      final goalCal = ((daily['goals'] as Map?)?['calories'] ?? 2400).toDouble();
      final consumedCal = ((daily['consumed'] as Map?)?['calories'] ?? 0).toDouble();

      if (mounted) {
        setState(() {
          if (weekly.isNotEmpty && goalCal > 0) {
            values = weekly.map<double>((d) {
              final cal = (d['calories'] ?? 0).toDouble();
              return (cal / goalCal).clamp(0.0, 1.0);
            }).toList();
          }

          _caloriesText = consumedCal.toStringAsFixed(0);
          _streakText = '${streak['streak_count'] ?? 0} days';
          _activeText = '${streak['total_days_logged'] ?? 0} days';

          _weightLogs = weightLogs;

          if (profile != null) {
            _currentWeight = (profile.weight as num?)?.toDouble() ?? 170.0;
            _goalWeight = (profile.goalWeight as num?)?.toDouble() ?? 160.0;
            _userGoal = profile.goal ?? '';
          }

          if (_weightLogs.isNotEmpty) {
            _startWeight = (_weightLogs.last['weight'] as num).toDouble();
            if (profile != null && profile.weight == null) {
              _currentWeight = (_weightLogs.first['weight'] as num).toDouble();
            }
          } else {
            _startWeight = _currentWeight;
          }
        });

        _controller.forward();
      }
    } catch (_) {
      if (mounted) _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper date formatter
  String _formatLogDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  List<Map<String, dynamic>> get _filteredWeightLogs {
    if (_weightLogs.isEmpty) {
      return [];
    }

    final now = DateTime.now();
    DateTime cutoff;
    switch (selectedSegmentIndex) {
      case 0: // 1W
        cutoff = DateTime(now.year, now.month, now.day - 7);
        break;
      case 1: // 1M
        cutoff = DateTime(now.year, now.month - 1, now.day);
        break;
      case 2: // 6M
        cutoff = DateTime(now.year, now.month - 6, now.day);
        break;
      case 3: // 1Y
        cutoff = DateTime(now.year - 1, now.month, now.day);
        break;
      default: // ALL
        cutoff = DateTime(2000);
        break;
    }

    final filtered = _weightLogs.where((log) {
      try {
        final d = DateTime.parse(log['log_date'].toString());
        return d.isAfter(cutoff) || d.isAtSameMomentAs(cutoff);
      } catch (_) {
        return true;
      }
    }).toList();

    filtered.sort((a, b) {
      return a['log_date'].toString().compareTo(b['log_date'].toString());
    });

    return filtered;
  }

  List<double> get _filteredWeights {
    final logs = _filteredWeightLogs;
    if (logs.isEmpty) {
      return [_currentWeight];
    }
    return logs.map<double>((log) => (log['weight'] as num).toDouble()).toList();
  }

  List<String> get _chartLabels {
    final now = DateTime.now();
    switch (selectedSegmentIndex) {
      case 0: // 1W
        return List.generate(7, (i) {
          final d = now.subtract(Duration(days: 6 - i));
          return DateFormat('E').format(d);
        });
      case 1: // 1M
        final start = DateTime(now.year, now.month - 1, now.day);
        return List.generate(4, (i) {
          final d = i == 3 ? now : start.add(Duration(days: i * 10));
          return DateFormat('d/M').format(d);
        });
      case 2: // 6M
        return List.generate(6, (i) {
          final d = DateTime(now.year, now.month - (5 - i), 1);
          return DateFormat('MMM').format(d);
        });
      case 3: // 1Y
        return List.generate(12, (i) {
          final d = DateTime(now.year, now.month - (11 - i), 1);
          return DateFormat('MMM').format(d);
        });
      default: // ALL
        return List.generate(6, (i) {
          final d = DateTime(now.year, now.month - (5 - i), 1);
          return DateFormat('MMM').format(d);
        });
    }
  }

  Widget _buildPeriodSummary() {
    final logs = _filteredWeightLogs;
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(
          "Plan: ${_formatGoal(_userGoal)} | No weight logs in this period.",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      );
    }

    final double startW = (logs.first['weight'] as num).toDouble();
    final double endW = (logs.last['weight'] as num).toDouble();
    final double diff = endW - startW;

    String statusText = "";
    Color statusColor = Colors.black87;

    final goalLower = _userGoal.toLowerCase();
    if (goalLower.contains('lose')) {
      if (diff < 0) {
        statusText = "Good progress! You lost ${diff.abs().toStringAsFixed(1)} kg";
        statusColor = Colors.green;
      } else if (diff > 0) {
        statusText = "Needs improvement. You gained ${diff.abs().toStringAsFixed(1)} kg";
        statusColor = Colors.orange;
      } else {
        statusText = "Stable weight";
        statusColor = Colors.blueGrey;
      }
    } else if (goalLower.contains('gain')) {
      if (diff > 0) {
        statusText = "Good progress! You gained ${diff.abs().toStringAsFixed(1)} kg";
        statusColor = Colors.green;
      } else if (diff < 0) {
        statusText = "Needs improvement. You lost ${diff.abs().toStringAsFixed(1)} kg";
        statusColor = Colors.orange;
      } else {
        statusText = "Stable weight";
        statusColor = Colors.blueGrey;
      }
    } else {
      if (diff.abs() <= 1.0) {
        statusText = "Good progress! Maintained weight within 1.0 kg (change: ${diff.toStringAsFixed(1)} kg)";
        statusColor = Colors.green;
      } else {
        statusText = "Weight shifted by ${diff.toStringAsFixed(1)} kg";
        statusColor = Colors.orange;
      }
    }

    if (logs.length < 2) {
      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.black54, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Plan: ${_formatGoal(_userGoal)} | Log at least twice to track period progress.",
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            statusColor == Colors.green ? Icons.check_circle_outline : Icons.info_outline,
            color: statusColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                children: [
                  const TextSpan(text: "Plan: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "${_formatGoal(_userGoal)} | "),
                  const TextSpan(text: "Progress: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGoal(String goal) {
    if (goal.isEmpty) return "N/A";
    final g = goal.replaceAll('_', ' ').toLowerCase();
    if (g.contains('lose')) return "Lose Weight";
    if (g.contains('gain')) return "Gain Weight";
    if (g.contains('maintain')) return "Maintain Weight";
    return g[0].toUpperCase() + g.substring(1);
  }

  double get _progressToGoal {
    if (_startWeight == _goalWeight) return 0.5;
    final progress = (_startWeight - _currentWeight) / (_startWeight - _goalWeight);
    return progress.clamp(0.0, 1.0);
  }

  // --- دالة إظهار الـ Dialog لإضافة وزن جديد ---
  void _showAddWeightDialog(BuildContext context) {
    final TextEditingController weightController = TextEditingController();
    DateTime selectedLogDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Weight Log',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    const SizedBox(height: 16),
                    const Text(
                      'Weight (kg/lbs)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        hintText: 'Enter your weight',
                        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Date',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedLogDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.black,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedLogDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MM/dd/yy').format(selectedLogDate),
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final text = weightController.text.trim();
                              if (text.isEmpty) return;
                              final parsedWeight = double.tryParse(text);
                              if (parsedWeight == null) return;
                              
                              final success = await ApiService().logWeight(
                                parsedWeight,
                                DateFormat('yyyy-MM-dd').format(selectedLogDate),
                              );
                              if (success) {
                                Navigator.pop(context);
                                _loadData();
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Save Log',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // main summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.track_changes, color: Colors.black),
                          SizedBox(width: 6),
                          Text(
                            'CURRENT WEIGHT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _currentWeight.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'kg',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12),
                          children: [
                            const TextSpan(
                              text: 'Start: ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: '${_startWeight.toStringAsFixed(0)}  ',
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const TextSpan(
                              text: 'Goal: ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: _goalWeight.toStringAsFixed(0),
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Progress to goal:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progressToGoal,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE0E0E0),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(_currentWeight - _goalWeight).abs().toStringAsFixed(0)} kg to go',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(_startWeight - _currentWeight).abs().toStringAsFixed(0)} kg ${_currentWeight <= _startWeight ? 'lost' : 'gained'}',
                          style: TextStyle(
                            color: _currentWeight <= _startWeight ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // small stat cards row
            Row(
              children: [
                Expanded(
                    child: _stat(
                        Icons.eco_outlined, _caloriesText, 'Calories', Colors.red)),
                const SizedBox(width: 12),
                Expanded(
                    child: _stat(Icons.local_fire_department_outlined, _streakText,
                        'Streak', Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: _stat(Icons.monitor_heart_outlined, _activeText,
                        'Active', Colors.blueGrey)),
              ],
            ),

            const SizedBox(height: 16),

            // weekly calories chart
            _chart(),

            const SizedBox(height: 16),

            // weight journey graph card
            _weightJourneyCard(),

            const SizedBox(height: 16),

            // weight log timeline card
            _weightLogCard(context), // باصينا الـ context هنا عشان الـ Dialog

            const SizedBox(height: 16),

            // الكارت الخاص بالـ Milestone
            _milestoneCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _milestoneCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEAEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.red.shade600,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_open_rounded,
            size: 44,
            color: Colors.black,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Milestone Unlocked!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD90C0C), // اللون اللي طلبته للـ XP
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '+75 XP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF757575),
                    ),
                    children: [
                      TextSpan(
                        text: 'You have achieved your ',
                      ),
                      TextSpan(
                        text: '7-day streak!\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Unlocked: ',
                        style: TextStyle(
                          color: Colors.black
                        )
                      ),
                      TextSpan(
                        text: 'Consistency Champion ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Avatar',
                        style:
                          TextStyle(
                            color: Colors.black
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      context.push('/badges');
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Check it out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                      ],
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

  Widget _chart() {
    const chartHeight = 160.0;

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Calories',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => context.push('/weeklyBreakdownScreen'),
                child: const Text(
                  'Details >',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final avgY = chartHeight * (1 - average) * _controller.value;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AvgLinePainter(y: avgY),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(values.length, (i) {
                        final isFriday = i == 4;
                        final h = chartHeight * values[i] * _controller.value;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 18,
                              height: h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isFriday
                                      ? [
                                    Colors.red.shade300,
                                    Colors.red.shade800,
                                  ]
                                      : [
                                    Colors.red.withOpacity(0.2),
                                    Colors.red.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[i],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightJourneyCard() {
    final segments = ['1W', '1M', '6M', '1Y', 'ALL'];

    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight Journey',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: List.generate(segments.length, (i) {
                final active = i == selectedSegmentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSegmentIndex = i;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          segments[i],
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          _buildPeriodSummary(),
          const SizedBox(height: 10),
          Expanded(
            child: _InteractiveWeightChart(data: _filteredWeights, labels: _chartLabels),
          ),
        ],
      ),
    );
  }

  Widget _weightLogCard(BuildContext context) {
    final displayLogs = _weightLogs.take(5).toList();

    const dotSize = 12.0;
    const lineX = 22.0;
    const rowHeight = 52.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight Log',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              InkWell(
                onTap: () => _showAddWeightDialog(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayLogs.isEmpty)
            const SizedBox(
              height: rowHeight,
              child: Center(
                child: Text(
                  'No weight logs yet. Click Add to log your weight!',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            )
          else
            SizedBox(
              height: displayLogs.length * rowHeight,
              child: Stack(
                children: [
                  Positioned(
                    left: lineX + dotSize / 2 - 1,
                    top: rowHeight / 2,
                    bottom: rowHeight / 2,
                    child: Container(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  Column(
                    children: List.generate(displayLogs.length, (i) {
                      final log = displayLogs[i];
                      final dateVal = _formatLogDate(log['log_date'].toString());
                      final weightVal = "${(log['weight'] as num).toStringAsFixed(1)} kg";

                      return SizedBox(
                        height: rowHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: lineX),
                            Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dateVal,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 65,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Text(
                                    weightVal,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(10),
      decoration: _box(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '10 lbs to go',
        style: TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _AvgLinePainter extends CustomPainter {
  final double y;

  _AvgLinePainter({required this.y});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.85)
      ..strokeWidth = 2;

    const dash = 6.0;
    const space = 5.0;

    double x = 0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dash, y),
        paint,
      );
      x += dash + space;
    }
  }

  @override
  bool shouldRepaint(covariant _AvgLinePainter oldDelegate) {
    return oldDelegate.y != y;
  }
}

class _InteractiveWeightChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;

  const _InteractiveWeightChart({required this.data, required this.labels});

  @override
  State<_InteractiveWeightChart> createState() =>
      _InteractiveWeightChartState();
}

class _InteractiveWeightChartState extends State<_InteractiveWeightChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _update(details.localPosition),
      onPanUpdate: (details) => _update(details.localPosition),
      onPanEnd: (_) => setState(() => selectedIndex = null),
      child: CustomPaint(
        painter: _WeightLinePainter(
          data: widget.data,
          labels: widget.labels,
          selectedIndex: selectedIndex,
        ),
        child: Container(),
      ),
    );
  }

  void _update(Offset pos) {
    final index = (pos.dx / context.size!.width * (widget.data.length - 1))
        .round()
        .clamp(0, widget.data.length - 1);

    setState(() {
      selectedIndex = index;
    });
  }
}

class _WeightLinePainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final int? selectedIndex;

  _WeightLinePainter({
    required this.data,
    required this.labels,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1;

    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    double minWeight = data.isNotEmpty ? data.reduce((a, b) => a < b ? a : b) : 160.0;
    double maxWeight = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 180.0;

    if (minWeight == maxWeight) {
      minWeight = minWeight - 10.0;
      maxWeight = maxWeight + 10.0;
    } else {
      final diff = maxWeight - minWeight;
      minWeight = minWeight - diff * 0.1;
      maxWeight = maxWeight + diff * 0.1;
    }

    double norm(double v) => (maxWeight - minWeight > 0) ? (v - minWeight) / (maxWeight - minWeight) : 0.5;

    const horizontalPadding = 28.0;
    const bottomPadding = 22.0;

    final chartWidth = size.width - horizontalPadding * 2;
    final chartHeight = size.height - bottomPadding;

    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = (chartHeight / gridLines) * i;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    canvas.drawLine(
      Offset(horizontalPadding, chartHeight),
      Offset(size.width - horizontalPadding, chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(horizontalPadding, 0),
      Offset(horizontalPadding, chartHeight),
      axisPaint,
    );

    if (data.isEmpty) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'No logged weight data yet',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          chartHeight / 2 - textPainter.height / 2,
        ),
      );
      return;
    }

    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? horizontalPadding + chartWidth / 2
          : horizontalPadding + (i / (data.length - 1)) * chartWidth;
      final y = chartHeight - (norm(data[i]) * chartHeight);
      points.add(Offset(x, y));
    }

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
    }

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );

      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, chartHeight)
      ..lineTo(points.first.dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.withOpacity(0.25),
          Colors.red.withOpacity(0.10),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, chartHeight),
      );

    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(path, linePaint);

    if (data.length == 1 && points.isNotEmpty) {
      canvas.drawCircle(points.first, 6, Paint()..color = Colors.black);
    }

    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      final p = points[selectedIndex!];
      final value = data[selectedIndex!];

      canvas.drawLine(
        Offset(p.dx, 0),
        Offset(p.dx, chartHeight),
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 1,
      );

      canvas.drawCircle(
        p,
        5,
        Paint()..color = Colors.black,
      );

      canvas.drawCircle(
        p,
        10,
        Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${value.toStringAsFixed(1)} lbs',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        p.dx - textPainter.width / 2,
        p.dy - 30,
      );

      final bg = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx - 6,
          offset.dy - 4,
          textPainter.width + 12,
          textPainter.height + 8,
        ),
        const Radius.circular(8),
      );

      canvas.drawRRect(
        bg,
        Paint()..color = Colors.white,
      );

      canvas.drawRRect(
        bg,
        Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      textPainter.paint(canvas, offset);
    }

    final labelsCount = labels.length;

    const textStyle = TextStyle(
      fontSize: 11,
      color: Colors.black87,
    );

    for (int i = 0; i < labelsCount; i++) {
      final x = horizontalPadding + (labelsCount > 1 ? (i / (labelsCount - 1)) * chartWidth : 0.0);

      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(x - tp.width / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.labels != labels ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}