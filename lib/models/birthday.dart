import 'package:birthdays/extensions/forename_possessive.dart';
import 'package:birthdays/models/birthday_reminder.dart';
import 'package:intl/intl.dart';
import '../data/birthdays_sql_helper.dart';
import '../enums/sex.dart';

class Birthday {
  int id;
  DateTime date = DateTime.now();
  String forename = "";
  String surname = "";
  Sex sex = Sex.male;
  int year = DateTime.now().year;

  BirthdayReminder reminders = BirthdayReminder(
    id: -1,
    birthdayId: -1,
    remindOneWeek: false,
    remindTwoWeeks: false,
    remindFourWeeks: false,
  );

  String get name => surname.isEmpty ? forename : "$forename $surname";
  int get age => year - date.year;

  String dateTextForGivenYear(int year) {
    DateTime birthdayDate = DateTime(year, date.month, date.day);

    if (date.month == 2 && date.day == 29) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);

      if (!isLeapYear) birthdayDate = DateTime(year, 2, 28);
    }

    final DateFormat format = DateFormat("EEEE, d MMMM");

    return format.format(birthdayDate);
  }

  String get shortDate => DateFormat('dd/MM/yyyy').format(date);

  String title(int year) => "${name.toPossessive()} Birthday ($age)";

  Birthday(this.id, this.date, this.forename, this.surname, this.year,
      [this.sex = Sex.male, BirthdayReminder? reminders]) {
    this.reminders = reminders ??
        BirthdayReminder(
          id: -1,
          birthdayId: id,
          remindOneWeek: false,
          remindTwoWeeks: false,
          remindFourWeeks: false,
        );
  }

  factory Birthday.fromMap(Map<String, dynamic> map) {
    final parsedDate = DateTime.parse(map[BirthdaysSqlHelper.colDate]);

    return Birthday(
      map[BirthdaysSqlHelper.colId],
      parsedDate,
      map[BirthdaysSqlHelper.colForename],
      map[BirthdaysSqlHelper.colSurname],
      parsedDate.year,
      Sex.values.elementAt(map[BirthdaysSqlHelper.colSex]),
    )..reminders = BirthdayReminder(
        id: -1,
        birthdayId: map[BirthdaysSqlHelper.colId],
        remindOneWeek: false,
        remindTwoWeeks: false,
        remindFourWeeks: false,
      );
  }

  Map<String, dynamic> toMap() {
    return {
      BirthdaysSqlHelper.colId: id,
      BirthdaysSqlHelper.colDate: date.toIso8601String(),
      BirthdaysSqlHelper.colForename: forename,
      BirthdaysSqlHelper.colSurname: surname,
      BirthdaysSqlHelper.colSex: sex.index,
    };
  }

  Map<String, dynamic> toMapInsert() {
    return {
      BirthdaysSqlHelper.colDate: date.toIso8601String(),
      BirthdaysSqlHelper.colForename: forename,
      BirthdaysSqlHelper.colSurname: surname,
      BirthdaysSqlHelper.colSex: sex.index,
    };
  }
}
