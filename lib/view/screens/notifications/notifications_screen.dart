import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      // Generate notifications from recent food activity
      final history = await FoodService().getFoodHistory();
      final logs = (history['logs'] as List?) ?? [];
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList('read_notification_ids') ?? [];

      final List<Map<String, dynamic>> notifs = [];

      for (final log in logs.take(20)) {
        final foodName = log['food_name'] ?? 'Food';
        final calories = log['calories'] ?? 0;
        final logTime = log['log_time']?.toString() ?? '';
        final logId = log['id']?.toString() ?? '';

        if (logTime.isNotEmpty) {
          notifs.add({
            'id': 'log_$logId',
            'title': 'Food Logged',
            'body': 'You logged $foodName (${(calories is num ? calories.toStringAsFixed(0) : calories)} cal)',
            'time': logTime,
            'is_read': readIds.contains('log_$logId'),
            'icon': Icons.restaurant,
          });
        }
      }

      // Add streak-based notifications
      final streak = await FoodService().getStreak().catchError((_) => <String, dynamic>{});
      final streakCount = streak['streak_count'] ?? 0;
      if (streakCount >= 7) {
        notifs.insert(0, {
          'id': 'streak_$streakCount',
          'title': '🔥 Streak Milestone!',
          'body': 'Amazing! You\'re on a $streakCount-day streak!',
          'time': DateTime.now().toIso8601String(),
          'is_read': readIds.contains('streak_$streakCount'),
          'icon': Icons.local_fire_department,
        });
      }

      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList('read_notification_ids') ?? [];
    if (!readIds.contains(id)) {
      readIds.add(id);
      await prefs.setStringList('read_notification_ids', readIds);
    }
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index >= 0) {
        _notifications[index]['is_read'] = true;
      }
    });
  }

  String _formatTime(String timeStr) {
    try {
      final dt = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return timeStr;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: AppBar(
        backgroundColor: const Color(0xffEDEDED),
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              onPressed: () {
                context.push('/notifications');
              },
              icon: const Icon(Icons.settings, size: 24, color: Colors.black),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _notifications.isEmpty
              ? Center(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            "assets/images/no_notifications_image.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No notifications yet",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Your notification will appear here once you have received them.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              : SlideTransition(
                  position: _slideAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['is_read'] ?? false;

                      return Dismissible(
                        key: Key(notif['id'].toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          _markAsRead(notif['id']);
                          setState(() => _notifications.removeAt(index));
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: GestureDetector(
                          onTap: () => _markAsRead(notif['id']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isRead ? Colors.white : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isRead
                                  ? null
                                  : Border.all(
                                      color: const Color(0xffD90C0C).withOpacity(0.3),
                                      width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? Colors.grey.shade100
                                        : const Color(0xffD90C0C).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    notif['icon'] ?? Icons.notifications,
                                    color: isRead
                                        ? Colors.grey
                                        : const Color(0xffD90C0C),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatTime(notif['time'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif['body'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(left: 8, top: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xffD90C0C),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
