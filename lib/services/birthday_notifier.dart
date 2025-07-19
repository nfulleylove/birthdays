import 'package:birthdays/extensions/birthday_model_copier.dart';
import 'package:flutter/foundation.dart';
import 'package:birthdays/helpers/birthdays_helper.dart';
import 'package:birthdays/models/birthday.dart';
import 'package:birthdays/models/birthday_month.dart';

class BirthdayNotifier extends ChangeNotifier {
  final BirthdaysHelper _helper = BirthdaysHelper();

  List<BirthdayMonth> months = [];

  Future<void> loadAll() async {
    months = await _helper.getBirthdaysForCurrentAndNextYear();

    notifyListeners();
  }

  Future<void> addBirthday(Birthday birthday) async {
    for (final month in months) {
      if (month.month.number == birthday.date.month) {
        final copy =
            birthday.copyWith(year: month.year); // assuming you have copyWith
        month.birthdays.add(copy);

        month.birthdays.sort((a, b) {
          final comparison = a.date.day.compareTo(b.date.day);
          return comparison != 0 ? comparison : a.name.compareTo(b.name);
        });
      }
    }

    notifyListeners();
  }

  Future<void> updateBirthday(Birthday birthday) async {
    for (final month in months) {
      for (final birthdayToUpdate in month.birthdays) {
        if (birthdayToUpdate.id == birthday.id) {
          final originalYear = birthdayToUpdate.year;
          birthdayToUpdate
            ..forename = birthday.forename
            ..surname = birthday.surname
            ..date = birthday.date
            ..sex = birthday.sex
            ..year = originalYear
            ..reminders = birthday.reminders;
        }
      }
    }

    notifyListeners();
  }

  Future<void> deleteBirthday(Birthday birthday) async {
    for (final month in months) {
      month.birthdays.removeWhere((b) => b.id == birthday.id);
    }

    notifyListeners();
  }
}
