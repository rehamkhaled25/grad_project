import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/services/food_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<Map<String, dynamic>> _badges = [];
  bool _isLoading = true;
  int _streakCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final streak = await FoodService().getStreak().catchError((_) => <String, dynamic>{});
      final streakCount = (streak['streak_count'] ?? 0) as int;
      final badges = await FoodService().getBadges();
      if (mounted) {
        setState(() {
          _badges = badges;
          _streakCount = streakCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'access_time':
        return Icons.access_time;
      case 'menu_book':
        return Icons.menu_book;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'flag':
        return Icons.flag;
      case 'shield':
        return Icons.shield;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'eco':
        return Icons.eco;
      case 'bubble_chart':
        return Icons.bubble_chart;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final featured = _badges.where((b) => b['category'] == 'featured').toList();
    final weekly = _badges.where((b) => b['category'] == 'weekly').toList();

    return Scaffold(
      backgroundColor: const Color(0xffF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF3F3F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Badges",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text(
                    "Featured",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: featured
                        .map((b) => BadgeItem(
                              icon: _iconFromString(b['icon'] ?? ''),
                              title: b['title'] ?? '',
                              isLocked: !(b['is_earned'] ?? false),
                              isNew: b['is_new'] ?? false,
                              streakCount: _streakCount,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Weekly Achievements",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: weekly
                        .map((b) => BadgeItem(
                              icon: _iconFromString(b['icon'] ?? ''),
                              title: b['title'] ?? '',
                              isLocked: !(b['is_earned'] ?? false),
                              isDiamond: true,
                              notificationCount: b['level'] ?? 0,
                              streakCount: _streakCount,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class BadgeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLocked;
  final bool isNew;
  final int notificationCount;
  final bool isDiamond;
  final int streakCount;

  const BadgeItem({
    super.key,
    required this.icon,
    required this.title,
    this.isLocked = false,
    this.isNew = false,
    this.notificationCount = 0,
    this.isDiamond = false,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipPath(
                clipper: HexagonClipper(isDiamond: isDiamond),
                child: Container(
                  width: 55,
                  height: 55,
                  color: isLocked
                      ? Colors.grey.shade300
                      : (streakCount % 5 == 0 && streakCount > 0)
                          ? Colors.black
                          : Colors.grey,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
            ],
          ),
        ),

        if (isNew)
          Positioned(
            top: 10,
            right: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 135, 24, 24),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "New",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        if (notificationCount > 0)
          Positioned(
            right: -3,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  notificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  final bool isDiamond;
  HexagonClipper({this.isDiamond = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    if (isDiamond) {
      path.moveTo(w * 0.5, 0);
      path.lineTo(w, h * 0.5);
      path.lineTo(w * 0.5, h);
      path.lineTo(0, h * 0.5);
    } else {
      path.moveTo(w * 0.5, 0);
      path.lineTo(w, h * 0.25);
      path.lineTo(w, h * 0.75);
      path.lineTo(w * 0.5, h);
      path.lineTo(0, h * 0.75);
      path.lineTo(0, h * 0.25);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}