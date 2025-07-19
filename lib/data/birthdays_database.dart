import 'package:birthdays/data/birthday_reminders_sql_helper.dart';
import 'package:birthdays/data/birthdays_sql_helper.dart';
import 'package:birthdays/helpers/birthdays_helper.dart';
import 'package:birthdays/models/birthday_reminder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:birthdays/enums/sex.dart';
import 'package:birthdays/models/birthday.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

part 'birthdays_database_schema.dart';
part 'birthdays_database_development_initialisation.dart';

class BirthdaysDatabase {
  static const int version = 1;
  static Database? _db;

  // Private constructor
  BirthdaysDatabase._();

  // Singleton
  static final BirthdaysDatabase _instance = BirthdaysDatabase._();

  // Accessor
  factory BirthdaysDatabase() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = join(await getDatabasesPath(), 'birthdays.db');
    return await openDatabase(
      dbPath,
      version: version,
      onCreate: _createDb,
      onUpgrade: _updateDb,
    );
  }

  Future _createDb(Database db, int version) async {
    await _createBirthdaysTable(db);
    await _createBirthdayRemindersTable(db);
  }

  Future _updateDb(Database db, int oldVersion, int newVersion) async {
    // if (oldVersion < 2)
    //   Run any schema changes since v2
    // ...
  }
}
