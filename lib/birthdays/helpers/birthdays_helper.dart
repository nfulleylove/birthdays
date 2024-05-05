import 'package:birthdays/birthdays/data/birthdays_sql_helper.dart';
import 'package:birthdays/birthdays/models/birthday.dart';
import 'package:birthdays/birthdays/models/birthdays_in_month.dart';

import '../models/month.dart';

class BirthdaysHelper {
  Future<List<MonthWithBirthdays>> getBirthdaysForCurrentYear() async {
    List<MonthWithBirthdays> birthdaysForCurrentYear = [];

    List<Month> months = [
      Month(DateTime.january, "January"),
      Month(DateTime.february, "February"),
      Month(DateTime.march, "March"),
      Month(DateTime.april, "April"),
      Month(DateTime.may, "May"),
      Month(DateTime.june, "June"),
      Month(DateTime.july, "July"),
      Month(DateTime.august, "August"),
      Month(DateTime.september, "September"),
      Month(DateTime.october, "October"),
      Month(DateTime.november, "November"),
      Month(DateTime.december, "December"),
    ];

    List<BirthdayModel> birthdays = await BirthdaysSqlHelper().getBirthdays();

    for (int i = 0; i < months.length; i++) {
      var birthdaysInMonth =
          birthdays.where((x) => x.date.month == months[i].number).toList();

      birthdaysInMonth.sort((a, b) {
        int sortValue = a.date.day.compareTo(b.date.day);

        if (sortValue == 0) {
          sortValue =
              (a.forename + a.surname).compareTo(b.forename + b.surname);
        }

        return sortValue;
      });

      birthdaysForCurrentYear
          .add(MonthWithBirthdays(months[i], birthdaysInMonth));
    }

    return birthdaysForCurrentYear;
  }
}
