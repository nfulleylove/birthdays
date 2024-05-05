import 'package:birthdays/birthdays/models/birthday.dart';
import 'package:birthdays/birthdays/models/month.dart';

class MonthWithBirthdays {
  Month month = Month(DateTime.january, "January");
  List<BirthdayModel> birthdays = [];

  MonthWithBirthdays(this.month, this.birthdays);
}
