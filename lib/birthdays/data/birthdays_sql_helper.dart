import 'package:sqflite/sqflite.dart';

import '../models/birthday.dart';
import 'birthdays_database.dart';

class BirthdaysSqlHelper {
  final Future<Database> db = BirthdaysDatabase().database;

  static const String tableBirthdays = 'Birthdays';

  static const String colId = 'id';
  static const String colDate = 'date';
  static const String colForename = 'forename';
  static const String colSurname = 'surname';
  static const String colSex = 'sex';

  Future<int> insertBirthday(BirthdayModel birthday) async {
    final database = await db;

    var map = birthday.toMap();

    return await database.insert(tableBirthdays, map);
  }

  Future<List<BirthdayModel>> getBirthdays() async {
    var database = await db;

    List<BirthdayModel> birthdays = [];

    List<Map<String, dynamic>> map = await database.query(tableBirthdays);

    for (var birthday in map) {
      birthdays.add(BirthdayModel.fromMap(birthday));
    }

    return birthdays;
  }

  Future<bool> updateBirthday(BirthdayModel birthday) async {
    var database = await db;

    int result = await database.update(tableBirthdays, birthday.toMap(),
        where: '$colId = ?', whereArgs: [birthday.id]);

    return result == 1;
  }

  Future<bool> deleteBirthday(BirthdayModel birthday) async {
    var database = await db;

    int result = await database.rawUpdate(
        'DELETE FROM $tableBirthdays WHERE $colId = ?', [birthday.id]);

    return result == 1;
  }

  Future<BirthdayModel> getBirthday(int birthdayId) async {
    var database = await db;

    var map = await database
        .query(tableBirthdays, where: '$colId = ?', whereArgs: [birthdayId]);

    return BirthdayModel.fromMap(map.first);
  }
}
