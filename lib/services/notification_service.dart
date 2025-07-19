import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:birthdays/data/birthday_reminders_sql_helper.dart';
import 'package:birthdays/helpers/preferences_helper.dart';
import 'package:birthdays/services/notification_dispatcher.dart';
import 'package:birthdays/services/notification_parser.dart';

const _alarmId = 0;

@pragma('vm:entry-point')
Future<void> _alarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  final rows = await BirthdayRemindersSqlHelper().getBirthdaysToNotify();
  final reminders = NotificationParser.parseReminders(rows);
  if (reminders.isEmpty) {
    final prefs = PreferencesHelper();
    final t = await prefs.getNotificationTime();
    await NotificationService()._scheduleNextAlarm(t);
    return;
  }

  final prefs = PreferencesHelper();
  final grouped = await prefs.getGroupedNotifications();
  final dispatcher = NotificationDispatcher();

  if (grouped) {
    final body = reminders.map((r) => r.message).join('\n');
    await dispatcher.showGroupedBirthdayNotification(body);
  } else {
    for (final r in reminders) {
      await dispatcher.showIndividualBirthdayNotification(r.message);
    }
  }

  final t = await prefs.getNotificationTime();
  await NotificationService()._scheduleNextAlarm(t);
}

class NotificationService {
  final NotificationDispatcher _dispatcher = NotificationDispatcher();

  Future<void> initialise() async {
    await _dispatcher.initialize();

    await AndroidAlarmManager.initialize();

    final prefs = PreferencesHelper();
    final t = await prefs.getNotificationTime();
    await _scheduleNextAlarm(t);
  }

  Future<void> onTimeChanged(TimeOfDay newTime) async {
    final prefs = PreferencesHelper();
    await prefs.setNotificationTime(newTime);
    await _scheduleNextAlarm(newTime);
  }

  Future<void> _scheduleNextAlarm(TimeOfDay t) async {
    await AndroidAlarmManager.cancel(_alarmId);

    final now = DateTime.now();
    var fire = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    if (!fire.isAfter(now)) {
      fire = fire.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.oneShotAt(
      fire,
      _alarmId,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  Future<void> sendBirthdayNotifications() async {
    List<Map<String, dynamic>> birthdays = [];

    birthdays = await BirthdayRemindersSqlHelper().getBirthdaysToNotify();

    final reminders = NotificationParser.parseReminders(birthdays);

    if (reminders.isEmpty) return;

    final bool shouldBeGrouped =
        await PreferencesHelper().getGroupedNotifications();

    if (shouldBeGrouped) {
      final body = reminders.map((r) => r.message).join('\n');

      await _dispatcher.showGroupedBirthdayNotification(body);
    } else {
      for (final reminder in reminders) {
        await _dispatcher.showIndividualBirthdayNotification(reminder.message);
      }
    }
  }
}
