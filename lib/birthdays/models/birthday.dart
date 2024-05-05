import 'package:intl/intl.dart';

import '../data/birthdays_sql_helper.dart';
import '../enums/sex.dart';

class BirthdayModel {
  int id = -1;
  DateTime date = DateTime.now();
  String forename = "";
  String surname = "";
  Sex sex = Sex.male;
  bool remindOneWeekBefore = true;
  bool remindTwoWeeksBefore = true;
  bool remindFourWeeksBefore = true;

  String get name => surname != "" ? "$forename $surname" : forename;
  int get age => DateTime.now().year - date.year;

  String get shortDate {
    final int year = DateTime.now().year;
    DateTime currentYearBirthday = DateTime(year, date.month, date.day);

    if (date.month == 2 && date.day == 29) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);

      if (isLeapYear) currentYearBirthday = DateTime(year, 2, 28);
    }

    final DateFormat format = DateFormat("EEEE, d MMMM");

    return format.format(currentYearBirthday);
  }

  String get title {
    String possessiveName = name;

    if (name.endsWith('s')) {
      possessiveName += "'";
    } else {
      possessiveName += "'s";
    }

    return "$possessiveName Birthday ($age)";
  }

  BirthdayModel(this.id, this.date, this.forename, this.surname,
      [this.sex = Sex.male]);

  factory BirthdayModel.fromMap(Map<String, dynamic> map) {
    Sex sex = Sex.male;

    if (map[BirthdaysSqlHelper.colSex] == 1) {
      sex = Sex.female;
    }

    return BirthdayModel(
      map[BirthdaysSqlHelper.colId],
      DateTime.parse(map[BirthdaysSqlHelper.colDate]),
      map[BirthdaysSqlHelper.colForename],
      map[BirthdaysSqlHelper.colSurname],
      sex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      BirthdaysSqlHelper.colDate: date.toIso8601String(),
      BirthdaysSqlHelper.colForename: forename,
      BirthdaysSqlHelper.colSurname: surname,
      BirthdaysSqlHelper.colSex: sex.index.toString(),
    };
  }
}
