import 'package:birthdays/enums/sex.dart';
import 'package:birthdays/models/birthday.dart';
import 'package:birthdays/models/birthday_reminder.dart';

extension BirthdayModelCopier on Birthday {
  Birthday copyWith(
      {int? id,
      DateTime? date,
      String? forename,
      String? surname,
      int? year,
      Sex? sex,
      BirthdayReminder? reminders}) {
    Birthday birthday = Birthday(
        id ?? this.id,
        date ?? this.date,
        forename ?? this.forename,
        surname ?? this.surname,
        year ?? this.year,
        sex ?? this.sex,
        reminders ?? this.reminders);

    return birthday;
  }
}
