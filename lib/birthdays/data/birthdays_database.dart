import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'birthdays_sql_helper.dart';

class BirthdaysDatabase {
  static const int version = 1;

  static final BirthdaysDatabase _birthdaysDatabase =
      BirthdaysDatabase._internal();

  factory BirthdaysDatabase() => _birthdaysDatabase;

  BirthdaysDatabase._internal();

  Future<Database> _init() async {
    String dbPath = join(await getDatabasesPath(), 'birthdays.db');
    return await openDatabase(dbPath,
        version: version, onCreate: _createDb, onUpgrade: _updateDb);
  }

  Future _createDb(Database db, int version) async {
    await _addBirthdaysTable(db);
  }

  Future _updateDb(Database db, int oldVersion, int newVersion) async {}

  // Singleton pattern
  static Database? db;

  Future<Database> get database async {
    if (db != null) return db!;
    // Initialize the DB first time it is accessed
    db = await _init();
    return db!;
  }

  Future<void> _addBirthdaysTable(Database db) async {
    String query = 'CREATE TABLE ${BirthdaysSqlHelper.tableBirthdays} '
        '(${BirthdaysSqlHelper.colId} INTEGER PRIMARY KEY AUTOINCREMENT, '
        '${BirthdaysSqlHelper.colDate} TEXT, '
        '${BirthdaysSqlHelper.colForename} TEXT, '
        '${BirthdaysSqlHelper.colSurname} TEXT, '
        '${BirthdaysSqlHelper.colSex} INTEGER);';

    await db.execute(query);
  }
}
