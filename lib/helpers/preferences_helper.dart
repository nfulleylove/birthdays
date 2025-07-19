import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  final String _defaultTabKey = '0';
  final String _notificationTimeKey = 'notification_time';
  final String _groupedNotificationsKey = 'grouped_notifications';
  final String _lastScheduledTimeKey = 'last_scheduled_time';

  Future<int> getDefaultTabIndex() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_defaultTabKey) ?? 0; // Default to List tab
  }

  Future<void> setDefaultTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_defaultTabKey, index);
  }

  Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();

    String? timeString = prefs.getString(_notificationTimeKey);

    if (timeString == null) {
      final defaultTime = const TimeOfDay(hour: 8, minute: 0);

      await setNotificationTime(defaultTime);

      return defaultTime;
    }

    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _notificationTimeKey,
      '${time.hour}:${time.minute}',
    );
  }

  Future<bool> getGroupedNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_groupedNotificationsKey) ??
        true; // default to grouped
  }

  Future<void> setGroupedNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_groupedNotificationsKey, value);
  }

  Future<TimeOfDay?> getLastScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_lastScheduledTimeKey);

    if (value == null) return null;

    final parts = value.split(':');

    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> setLastScheduledTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_lastScheduledTimeKey, '${time.hour}:${time.minute}');
  }
}
