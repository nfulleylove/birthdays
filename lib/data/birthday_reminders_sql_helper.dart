import 'package:birthdays/data/birthdays_database.dart';
import 'package:sqflite/sqflite.dart';

class BirthdayRemindersSqlHelper {
  static const String tableReminders = 'birthday_reminders';

  static const String colId = 'id';
  static const String colBirthdayId = 'birthday_id';
  static const String colOneWeek = 'remind_one_week';
  static const String colTwoWeeks = 'remind_two_weeks';
  static const String colFourWeeks = 'remind_four_weeks';

  Future<int> insertReminder(Map<String, dynamic> reminder) async {
    final db = await _getDb();

    return await db.insert(tableReminders, reminder);
  }

  Future<int> updateReminder(int id, Map<String, dynamic> values) async {
    final db = await _getDb();

    return await db.update(
      tableReminders,
      values,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getReminderForBirthday(int birthdayId) async {
    final db = await _getDb();

    final result = await db.query(
      tableReminders,
      where: '$colBirthdayId = ?',
      whereArgs: [birthdayId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> deleteReminder(int id) async {
    final db = await _getDb();

    return await db.delete(
      tableReminders,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBirthdaysToNotify() async {
    final db = await _getDb();
    final today = DateTime.now();
    final targetDates = {
      'today': today,
      'oneWeek': today.add(const Duration(days: 7)),
      'twoWeeks': today.add(const Duration(days: 14)),
      'fourWeeks': today.add(const Duration(days: 28)),
    };

    final formattedDates = targetDates.map((key, date) => MapEntry(key,
        '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'));

    return await db.rawQuery(
      '''
    SELECT
      birthday.id           AS $colBirthdayId,
      birthday.forename,
      birthday.surname,
      birthday.date,
      birthday.sex,
      reminder.$colId           AS $colId,
      reminder.$colOneWeek  AS $colOneWeek,
      reminder.$colTwoWeeks AS $colTwoWeeks,
      reminder.$colFourWeeks AS $colFourWeeks
    FROM birthdays       AS birthday
    JOIN $tableReminders AS reminder
      ON birthday.id = reminder.$colBirthdayId
    WHERE (
      strftime('%m-%d', birthday.date) = ?
      OR (strftime('%m-%d', birthday.date) = ? AND reminder.$colOneWeek = 1)
      OR (strftime('%m-%d', birthday.date) = ? AND reminder.$colTwoWeeks = 1)
      OR (strftime('%m-%d', birthday.date) = ? AND reminder.$colFourWeeks = 1)
    )
    ''',
      [
        formattedDates['today'],
        formattedDates['oneWeek'],
        formattedDates['twoWeeks'],
        formattedDates['fourWeeks'],
      ],
    );
  }

  Future<Database> _getDb() async => await BirthdaysDatabase().database;
}
