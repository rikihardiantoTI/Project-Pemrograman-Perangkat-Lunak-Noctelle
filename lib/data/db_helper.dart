import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sleep_record.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._();
  DbHelper._();
  Database? _db;

  Future<Database> get db async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'lelap.db');
    return openDatabase(path, version: 1, onCreate: (db, _) {
      return db.execute('''
        CREATE TABLE sleep_records(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sleep_start INTEGER, sleep_end INTEGER,
          movement_count INTEGER, screen_wake_count INTEGER,
          minutes_screen_before_bed INTEGER, score INTEGER
        )''');
    });
  }

  Future<int> insert(SleepRecord r) async =>
      (await db).insert('sleep_records', r.toMap());

  Future<List<SleepRecord>> lastDays(int days) async {
    final since = DateTime.now().subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    final rows = await (await db).query('sleep_records',
        where: 'sleep_start >= ?', whereArgs: [since],
        orderBy: 'sleep_start DESC');
    return rows.map(SleepRecord.fromMap).toList();
  }
}