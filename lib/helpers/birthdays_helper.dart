import 'package:birthdays/data/birthday_reminders_sql_helper.dart';
import 'package:birthdays/data/birthdays_sql_helper.dart';
import 'package:birthdays/models/birthday.dart';
import 'package:birthdays/models/birthday_reminder.dart';
import 'package:birthdays/models/birthday_month.dart';
import '../models/month.dart';

class BirthdaysHelper {
  final BirthdaysSqlHelper _sqlHelper = BirthdaysSqlHelper();
  final BirthdayRemindersSqlHelper _reminderHelper =
      BirthdayRemindersSqlHelper();

  Future<int> addBirthday(Birthday birthday) async {
    // Add birthday
    final newId = await _sqlHelper.insertBirthday(birthday);

    if (newId <= 0) return -1;

    birthday.id = newId;

    // Add reminders for birthday
    birthday.reminders.birthdayId = newId;

    final remId = await _reminderHelper.insertReminder(
      birthday.reminders.toMapInsert(),
    );

    birthday.reminders.id = remId;

    return birthday.id;
  }

  Future<List<BirthdayMonth>> getBirthdaysForCurrentAndNextYear() async {
    final currentYear = DateTime.now().year;
    final months = Month.getAll();
    final result = <BirthdayMonth>[];

    final birthdays = await _sqlHelper.getBirthdays();

    // Get reminders for birthdays
    await Future.wait(birthdays.map((b) async {
      final remMap = await _reminderHelper.getReminderForBirthday(b.id);

      if (remMap != null) b.reminders = BirthdayReminder.fromMap(remMap);
    }));

    // Add birthdays for current and next year
    for (var year = currentYear; year <= currentYear + 1; year++) {
      for (var month in months) {
        final monthWithBirthdays = birthdays
            .where((birthday) => birthday.date.month == month.number)
            .map((birthday) {
          final birthdayForGivenMonth = Birthday(
            birthday.id,
            birthday.date,
            birthday.forename,
            birthday.surname,
            year,
            birthday.sex,
          );

          birthdayForGivenMonth.reminders = birthday.reminders;

          return birthdayForGivenMonth;
        }).toList();

        // Sort birthdays for the month by date and name
        monthWithBirthdays.sort((a, b) {
          final comparison = a.date.day.compareTo(b.date.day);

          if (comparison != 0) return comparison;

          return (a.name).compareTo(b.name);
        });

        result.add(BirthdayMonth(year, month, monthWithBirthdays));
      }
    }
    return result;
  }

  Future<bool> updateBirthday(Birthday birthday) async {
    final updated = await _sqlHelper.updateBirthday(birthday);

    if (!updated) return false;

    final rem = birthday.reminders;

    // Upsert reminders
    if ((rem.id ?? -1) > -1) {
      await _reminderHelper.updateReminder(rem.id!, rem.toMap());
    } else {
      rem.birthdayId = birthday.id;
      rem.id = await _reminderHelper.insertReminder(rem.toMap());
    }

    return true;
  }

  Future<bool> deleteBirthday(Birthday birthday) async {
    if (birthday.reminders.id != null) {
      await _reminderHelper.deleteReminder(birthday.reminders.id!);
    }

    return await _sqlHelper.deleteBirthday(birthday);
  }
}
