import 'package:sqflite/sqflite.dart';
import '../models/birthday.dart';
import 'birthdays_database.dart';

class BirthdaysSqlHelper {
  static const String tableBirthdays = 'Birthdays';

  static const String colId = 'id';
  static const String colDate = 'date';
  static const String colForename = 'forename';
  static const String colSurname = 'surname';
  static const String colSex = 'sex';

  final Future<Database> _db = BirthdaysDatabase().database;

  Future<int> insertBirthday(Birthday birthday) async {
    final database = await _db;
    final map = birthday.toMapInsert();

    return await database.insert(tableBirthdays, map);
  }

  Future<List<Birthday>> getBirthdays() async {
    final database = await _db;

    final results = await database.query(tableBirthdays);

    return results.map((row) => Birthday.fromMap(row)).toList();
  }

  Future<Birthday?> getBirthday(int birthdayId) async {
    final database = await _db;

    final results = await database.query(
      tableBirthdays,
      where: '$colId = ?',
      whereArgs: [birthdayId],
    );

    if (results.isEmpty) return null;

    return Birthday.fromMap(results.first);
  }

  Future<bool> updateBirthday(Birthday birthday) async {
    final database = await _db;

    final result = await database.update(
      tableBirthdays,
      birthday.toMap(),
      where: '$colId = ?',
      whereArgs: [birthday.id],
    );

    return result == 1;
  }

  Future<bool> deleteBirthday(Birthday birthday) async {
    final database = await _db;

    final result = await database.delete(
      tableBirthdays,
      where: '$colId = ?',
      whereArgs: [birthday.id],
    );

    return result == 1;
  }
}
