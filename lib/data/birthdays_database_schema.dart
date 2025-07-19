part of 'birthdays_database.dart';

Future<void> _createBirthdaysTable(Database db) async {
  final query = '''
      CREATE TABLE ${BirthdaysSqlHelper.tableBirthdays} (
        ${BirthdaysSqlHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BirthdaysSqlHelper.colDate} TEXT,
        ${BirthdaysSqlHelper.colForename} TEXT,
        ${BirthdaysSqlHelper.colSurname} TEXT,
        ${BirthdaysSqlHelper.colSex} INTEGER
      );
    ''';

  await db.execute(query);
}

Future<void> _createBirthdayRemindersTable(Database db) async {
  final query = '''
      CREATE TABLE ${BirthdayRemindersSqlHelper.tableReminders} (
        ${BirthdayRemindersSqlHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BirthdayRemindersSqlHelper.colBirthdayId} INTEGER NOT NULL,
        ${BirthdayRemindersSqlHelper.colOneWeek} INTEGER NOT NULL DEFAULT 0,
        ${BirthdayRemindersSqlHelper.colTwoWeeks} INTEGER NOT NULL DEFAULT 0,
        ${BirthdayRemindersSqlHelper.colFourWeeks} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${BirthdayRemindersSqlHelper.colBirthdayId}) 
          REFERENCES ${BirthdaysSqlHelper.tableBirthdays}(${BirthdaysSqlHelper.colId}) 
          ON DELETE CASCADE
      );
    ''';

  await db.execute(query);
}
