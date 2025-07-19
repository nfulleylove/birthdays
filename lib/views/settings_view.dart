import 'package:birthdays/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:birthdays/helpers/preferences_helper.dart';
import 'package:intl/intl.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int selectedTabIndex = 0;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  bool _groupedNotifications = true;
  bool isLoading = true;

  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final index = await _preferencesHelper.getDefaultTabIndex();
    final time = await _preferencesHelper.getNotificationTime();
    final grouped = await _preferencesHelper.getGroupedNotifications();

    if (!mounted) return;
    setState(() {
      selectedTabIndex = index;
      _notificationTime = time;
      _groupedNotifications = grouped;
      isLoading = false;
    });
  }

  Future<void> _updateDefaultTab(int value) async {
    await _preferencesHelper.setDefaultTabIndex(value);
    if (!mounted) return;
    setState(() => selectedTabIndex = value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default tab updated')),
    );
  }

  Future<void> _updateNotificationTime(TimeOfDay value) async {
    final last = await _preferencesHelper.getLastScheduledTime();

    if (last == null ||
        last.hour != value.hour ||
        last.minute != value.minute) {
      await _preferencesHelper.setLastScheduledTime(value);
    }
    await _preferencesHelper.setNotificationTime(value);
    await _notificationService.onTimeChanged(value);

    if (!mounted) return;
    setState(() => _notificationTime = value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification time updated')),
    );
  }

  Future<void> _updateGroupedNotifications(bool value) async {
    await _preferencesHelper.setGroupedNotifications(value);
    if (!mounted) return;
    setState(() => _groupedNotifications = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Notifications will now be grouped'
              : 'Notifications will be sent individually',
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _buildCardSection(_buildNotificationSection()),
                    _buildCardSection(_buildDefaultTabSection()),
                    _buildCardSection(_buildGroupedNotificationToggle()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCardSection(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🕒 Notification Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text(
          'Choose the time birthday notifications are delivered.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.schedule),
            label: Text(_formatTimeOfDay(_notificationTime)),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _notificationTime,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: false),
                  child: child!,
                ),
              );
              if (picked != null && mounted) {
                await _updateNotificationTime(picked);
              }
            },
          ),
        ),
        if (kDebugMode)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Send Test Notification'),
              onPressed: () async {
                await _notificationService.sendBirthdayNotifications();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notifications sent')),
                  );
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultTabSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🗃️ Default Tab',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text(
          'Select which tab appears when the app launches.',
        ),
        RadioListTile<int>(
          value: 0,
          groupValue: selectedTabIndex,
          title: const Text('List'),
          onChanged: (value) => _updateDefaultTab(value!),
        ),
        RadioListTile<int>(
          value: 1,
          groupValue: selectedTabIndex,
          title: const Text('Calendar'),
          onChanged: (value) => _updateDefaultTab(value!),
        ),
      ],
    );
  }

  Widget _buildGroupedNotificationToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔔 Group Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text(
          'If enabled, multiple birthday reminders will be combined into a single notification.',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Group birthday notifications'),
          value: _groupedNotifications,
          onChanged: _updateGroupedNotifications,
        ),
      ],
    );
  }
}
