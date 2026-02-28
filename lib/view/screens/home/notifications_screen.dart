import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Common section switches
  bool _generalNotification = true;
  bool _sound = true;
  bool _vibrate = false;

  // System & services section switches
  bool _appUpdates = true;
  bool _billReminder = true;
  bool _promotion = false;
  bool _discountAvailable = false;
  bool _paymentRequest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Common Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Common',
                    style: TextStyle(
                      fontSize: 16, // Slightly larger
                      fontWeight: FontWeight.bold, // Bold
                      color: Colors.black87, // Darker color
                      letterSpacing: 0.5, // Optional: adds slight spacing
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _buildSwitchTile(
                  title: 'General Notification',
                  value: _generalNotification,
                  onChanged: (value) {
                    setState(() {
                      _generalNotification = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Sound',
                  value: _sound,
                  onChanged: (value) {
                    setState(() {
                      _sound = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Vibrate',
                  value: _vibrate,
                  onChanged: (value) {
                    setState(() {
                      _vibrate = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // System & Services Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'System & Services',
                    style: TextStyle(
                      fontSize: 16, // Slightly larger
                      fontWeight: FontWeight.bold, // Bold
                      color: Colors.black87, // Darker color
                      letterSpacing: 0.5, // Optional: adds slight spacing
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _buildSwitchTile(
                  title: 'App Updates',
                  value: _appUpdates,
                  onChanged: (value) {
                    setState(() {
                      _appUpdates = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Bill Reminder',
                  value: _billReminder,
                  onChanged: (value) {
                    setState(() {
                      _billReminder = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Promotion',
                  value: _promotion,
                  onChanged: (value) {
                    setState(() {
                      _promotion = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Discount Available',
                  value: _discountAvailable,
                  onChanged: (value) {
                    setState(() {
                      _discountAvailable = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Payment Request',
                  value: _paymentRequest,
                  onChanged: (value) {
                    setState(() {
                      _paymentRequest = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal, // Normal weight
          color: Colors.black, // Lighter color than header
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.black,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
