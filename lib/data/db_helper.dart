import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/sleep_record.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._();
  DbHelper._();

  Database? _db;
  final List<SleepRecord> _mem = []; // penyimpanan sementara khusus web

  Future<Database> get db async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'lelap.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) {
        return db.execute('''
          CREATE TABLE sleep_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sleep_start INTEGER,
            sleep_end INTEGER,
            movement_count INTEGER,
            screen_wake_count INTEGER,
            minutes_screen_before_bed INTEGER,
            score INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insert(SleepRecord r) async {
    if (kIsWeb) {
      _mem.add(r);
      return _mem.length;
    }
    return (await db).insert('sleep_records', r.toMap());
  }

  Future<List<SleepRecord>> lastDays(int days) async {
    final since =
        DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;

    if (kIsWeb) {
      final list = _mem
          .where((r) => r.sleepStart.millisecondsSinceEpoch >= since)
          .toList();
      list.sort((a, b) => b.sleepStart.compareTo(a.sleepStart));
      return list;
    }

    final rows = await (await db).query(
      'sleep_records',
      where: 'sleep_start >= ?',
      whereArgs: [since],
      orderBy: 'sleep_start DESC',
    );
    return rows.map(SleepRecord.fromMap).toList();
  }
}