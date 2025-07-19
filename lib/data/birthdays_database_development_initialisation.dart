part of 'birthdays_database.dart';

extension DevSeedExtension on BirthdaysDatabase {
  Future<void> resetAndSeedDevDatabase() async {
    if (!kDebugMode) {
      throw Exception("Database should only be reset in debug mode.");
    }

    await _deleteDb();
    await _reinitialize();

    final now = DateTime.now();

    final birthdays = [
      Birthday(
          1,
          DateTime(2000, now.month, now.day),
          "Josephine",
          "Smith",
          -1,
          Sex.female,
          BirthdayReminder(
              birthdayId: 1,
              id: 1,
              remindOneWeek: false,
              remindTwoWeeks: false,
              remindFourWeeks: false)),
      Birthday(
          2,
          DateTime(1990, now.month, now.day + 1),
          "Jane",
          "Doe",
          -1,
          Sex.female,
          BirthdayReminder(
              birthdayId: 2,
              id: 2,
              remindOneWeek: true,
              remindTwoWeeks: true,
              remindFourWeeks: true)),
      Birthday(
          3,
          DateTime(1987, 11, 2),
          "John",
          "Schmidt",
          -1,
          Sex.male,
          BirthdayReminder(
              birthdayId: 3,
              id: 3,
              remindOneWeek: true,
              remindTwoWeeks: false,
              remindFourWeeks: false)),
      Birthday(
          4,
          DateTime(2009, 3, 15),
          "John",
          "Schmidt Jr.",
          -1,
          Sex.male,
          BirthdayReminder(
              birthdayId: 4,
              id: 4,
              remindOneWeek: false,
              remindTwoWeeks: true,
              remindFourWeeks: true)),
      Birthday(
          4,
          DateTime(1948, now.month, now.day + 7),
          "Johnny",
          "Crash",
          -1,
          Sex.male,
          BirthdayReminder(
              birthdayId: 5,
              id: 5,
              remindOneWeek: true,
              remindTwoWeeks: false,
              remindFourWeeks: true)),
      Birthday(
          5,
          DateTime(2024, 2, 29),
          "Peter",
          "Viper",
          -1,
          Sex.male,
          BirthdayReminder(
              birthdayId: 6,
              id: 6,
              remindOneWeek: true,
              remindTwoWeeks: true,
              remindFourWeeks: true)),
    ];

    // Adds birthdays and reminders
    for (final birthday in birthdays) {
      BirthdaysHelper().addBirthday(birthday);
    }
  }

  Future<void> _deleteDb() async {
    final dbPath = join(await getDatabasesPath(), 'birthdays.db');
    await deleteDatabase(dbPath);
    BirthdaysDatabase._db = null;
  }

  Future<void> _reinitialize() async {
    BirthdaysDatabase._db = await _init();
  }
}
