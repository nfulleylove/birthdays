import 'package:birthdays/models/birthday.dart';
import 'package:birthdays/models/month.dart';

class BirthdayMonth {
  int year = DateTime.now().year;
  Month month = Month(DateTime.january, "January");
  List<Birthday> birthdays = [];

  BirthdayMonth(this.year, this.month, this.birthdays);
}
