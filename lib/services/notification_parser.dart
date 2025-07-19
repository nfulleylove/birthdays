import 'package:birthdays/data/birthdays_sql_helper.dart';
import 'package:birthdays/extensions/forename_possessive.dart';
import 'package:birthdays/models/birthday_reminder.dart';
import 'package:birthdays/models/birthday_reminder_notification.dart';

class NotificationParser {
  static List<BirthdayReminderNotification> parseReminders(
      List<Map<String, dynamic>> rows) {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);

    final reminders = <BirthdayReminderNotification>[];
    for (final row in rows) {
      final birthdayDate = DateTime.parse(row[BirthdaysSqlHelper.colDate]!);
      final thisYear =
          DateTime(base.year, birthdayDate.month, birthdayDate.day);
      final daysUntil = thisYear.difference(base).inDays;
      final model = BirthdayReminder.fromMap(row);

      final shouldNotify = daysUntil == 0 ||
          (daysUntil == 7 && model.remindOneWeek) ||
          (daysUntil == 14 && model.remindTwoWeeks) ||
          (daysUntil == 28 && model.remindFourWeeks);

      if (!shouldNotify) continue;

      final name = row[BirthdaysSqlHelper.colForename].toString();
      final message = daysUntil == 0
          ? '🎈 It\'s ${name.toPossessive()} birthday today!'
          : '🎁 ${name.toPossessive()} birthday is in ${daysUntil ~/ 7} '
              'week${(daysUntil ~/ 7) > 1 ? 's' : ''}';

      reminders.add(BirthdayReminderNotification(
        birthdayId: model.birthdayId,
        name: name,
        date: birthdayDate,
        daysUntil: daysUntil,
        message: message,
      ));
    }
    return reminders;
  }
}
