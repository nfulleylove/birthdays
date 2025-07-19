import 'package:birthdays/data/birthday_reminders_sql_helper.dart';

class BirthdayReminder {
  int? id;
  int birthdayId;
  bool remindOneWeek;
  bool remindTwoWeeks;
  bool remindFourWeeks;

  BirthdayReminder({
    this.id,
    required this.birthdayId,
    required this.remindOneWeek,
    required this.remindTwoWeeks,
    required this.remindFourWeeks,
  });

  factory BirthdayReminder.fromMap(Map<String, dynamic> map) {
    return BirthdayReminder(
      id: map[BirthdayRemindersSqlHelper.colId],
      birthdayId: map[BirthdayRemindersSqlHelper.colBirthdayId],
      remindOneWeek: map[BirthdayRemindersSqlHelper.colOneWeek] == 1,
      remindTwoWeeks: map[BirthdayRemindersSqlHelper.colTwoWeeks] == 1,
      remindFourWeeks: map[BirthdayRemindersSqlHelper.colFourWeeks] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      BirthdayRemindersSqlHelper.colId: id,
      BirthdayRemindersSqlHelper.colBirthdayId: birthdayId,
      BirthdayRemindersSqlHelper.colOneWeek: remindOneWeek ? 1 : 0,
      BirthdayRemindersSqlHelper.colTwoWeeks: remindTwoWeeks ? 1 : 0,
      BirthdayRemindersSqlHelper.colFourWeeks: remindFourWeeks ? 1 : 0,
    };
  }

  Map<String, dynamic> toMapInsert() {
    return {
      BirthdayRemindersSqlHelper.colBirthdayId: birthdayId,
      BirthdayRemindersSqlHelper.colOneWeek: remindOneWeek ? 1 : 0,
      BirthdayRemindersSqlHelper.colTwoWeeks: remindTwoWeeks ? 1 : 0,
      BirthdayRemindersSqlHelper.colFourWeeks: remindFourWeeks ? 1 : 0,
    };
  }
}
