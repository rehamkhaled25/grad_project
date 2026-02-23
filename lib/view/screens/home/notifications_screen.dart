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

  // Promotion section switches
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
          const Text(
            'Common',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('General Notification'),
                  value: _generalNotification,
                  onChanged: (bool value) {
                    setState(() {
                      _generalNotification = value;
                    });
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const Divider(height: 0, indent: 56),
                SwitchListTile(
                  title: const Text('Sound'),
                  value: _sound,
                  onChanged: (bool value) {
                    setState(() {
                      _sound = value;
                    });
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.volume_up, color: Colors.green.shade700),
                  ),
                ),
                const Divider(height: 0, indent: 56),
                SwitchListTile(
                  title: const Text('Vibrate'),
                  value: _vibrate,
                  onChanged: (bool value) {
                    setState(() {
                      _vibrate = value;
                    });
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.vibration, color: Colors.purple.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'System & services update',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('App updates'),
                  value: _appUpdates,
                  onChanged: (bool value) {
                    setState(() {
                      _appUpdates = value;
                    });
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.system_update,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                const Divider(height: 0, indent: 56),
                SwitchListTile(
                  title: const Text('Bill Reminder'),
                  value: _billReminder,
                  onChanged: (bool value) {
                    setState(() {
                      _billReminder = value;
                    });
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.receipt, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Promotion',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Discount Available'),
                  value: _discountAvailable,
                  onChanged: (bool value) {
                    setState(() {
                      _discountAvailable = value;
                    });
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.discount, color: Colors.teal.shade700),
                  ),
                ),
                const Divider(height: 0, indent: 56),
                SwitchListTile(
                  title: const Text('Payment Request'),
                  value: _paymentRequest,
                  onChanged: (bool value) {
                    setState(() {
                      _paymentRequest = value;
                    });
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.payment, color: Colors.indigo.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
