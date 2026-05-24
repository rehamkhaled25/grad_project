import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _generalNotification = prefs.getBool('notif_general') ?? true;
        _sound = prefs.getBool('notif_sound') ?? true;
        _vibrate = prefs.getBool('notif_vibrate') ?? false;
        _appUpdates = prefs.getBool('notif_app_updates') ?? true;
        _billReminder = prefs.getBool('notif_bill_reminder') ?? true;
        _promotion = prefs.getBool('notif_promotion') ?? false;
        _discountAvailable = prefs.getBool('notif_discount') ?? false;
        _paymentRequest = prefs.getBool('notif_payment') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Container(
              color: Colors.white,
              child: ListView(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Common',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildSwitchTile(
                          title: 'General Notification',
                          value: _generalNotification,
                          onChanged: (value) {
                            setState(() => _generalNotification = value);
                            _savePreference('notif_general', value);
                          },
                        ),
                        _buildSwitchTile(
                          title: 'Sound',
                          value: _sound,
                          onChanged: (value) {
                            setState(() => _sound = value);
                            _savePreference('notif_sound', value);
                          },
                        ),
                        _buildSwitchTile(
                          title: 'Vibrate',
                          value: _vibrate,
                          onChanged: (value) {
                            setState(() => _vibrate = value);
                            _savePreference('notif_vibrate', value);
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'System & Services',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildSwitchTile(
                          title: 'App Updates',
                          value: _appUpdates,
                          onChanged: (value) {
                            setState(() => _appUpdates = value);
                            _savePreference('notif_app_updates', value);
                          },
                        ),
                        _buildSwitchTile(
                          title: 'Bill Reminder',
                          value: _billReminder,
                          onChanged: (value) {
                            setState(() => _billReminder = value);
                            _savePreference('notif_bill_reminder', value);
                          },
                        ),
                        _buildSwitchTile(
                          title: 'Promotion',
                          value: _promotion,
                          onChanged: (value) {
                            setState(() => _promotion = value);
                            _savePreference('notif_promotion', value);
                          },
                        ),
                        _buildSwitchTile(
                          title: 'Discount Available',
                          value: _discountAvailable,
                          onChanged: (value) {
                            setState(() => _discountAvailable = value);
                            _savePreference('notif_discount', value);
                          },
                        ),
                        _buildSwitchTile(
                          title: 'Payment Request',
                          value: _paymentRequest,
                          onChanged: (value) {
                            setState(() => _paymentRequest = value);
                            _savePreference('notif_payment', value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchTheme(
      data: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          return Colors.grey.shade200;
        }),
        trackOutlineColor: WidgetStateProperty.all(
          Colors.transparent,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
