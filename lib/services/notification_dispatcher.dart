import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationDispatcher {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await notificationsPlugin.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  Future<void> showGroupedBirthdayNotification(String messageBody) async {
    final androidDetails = AndroidNotificationDetails(
      'birthday_grouped_reminders_channel',
      'Grouped Birthday Reminders',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      80085,
      '🎉 Upcoming Birthdays',
      messageBody,
      details,
    );
  }

  Future<void> showIndividualBirthdayNotification(String message) async {
    final androidDetails = AndroidNotificationDetails(
      'birthday_individual_notifications_channel',
      'Individual Birthday Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await notificationsPlugin.show(
      id,
      '🎂 Birthday Reminder',
      message,
      details,
    );
  }
}
