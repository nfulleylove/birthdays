class BirthdayReminderNotification {
  final int birthdayId;
  final String name;
  final DateTime date;
  final int daysUntil;
  final String message;

  BirthdayReminderNotification({
    required this.birthdayId,
    required this.name,
    required this.date,
    required this.daysUntil,
    required this.message,
  });
}
