import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../data/db_helper.dart';
import '../models/sleep_record.dart';
import '../services/screen_usage_service.dart';
import '../services/score_calculator.dart';
import '../services/sensor_service.dart';

class SleepProvider extends ChangeNotifier {
  final _sensor = SensorService();
  final _screen = ScreenUsageService();

  DateTime? sleepStart;
  bool get isSleeping => sleepStart != null;

  List<SleepRecord> records = [];
  int weeklyScore = 0;

  Future<void> load() async {
    records = await DbHelper.instance.lastDays(7);
    weeklyScore = ScoreCalculator.weekly(records.map((e) => e.score).toList());
    notifyListeners();
  }

  Future<void> _keepAwake(bool enable) async {
    try {
      enable ? await WakelockPlus.enable() : await WakelockPlus.disable();
    } catch (_) {
      // wakelock tidak didukung di semua platform, abaikan saja
    }
  }

  void startSleep() {
    sleepStart = DateTime.now();
    _sensor.start();
    _keepAwake(true);
    notifyListeners();
  }

  Future<SleepRecord?> wakeUp() async {
    if (sleepStart == null) return null;

    final start = sleepStart!;
    final end = DateTime.now();
    _sensor.stop();
    await _keepAwake(false);

    int pre = 0;
    int wakes = 0;
    if (await _screen.hasPermission()) {
      pre = await _screen.minutesScreenBeforeBed(start);
      wakes = await _screen.wakeCount(start, end);
    }

    final movement = _sensor.movementCount;
    final score = ScoreCalculator.calculate(
      duration: end.difference(start),
      movementCount: movement,
      screenWakeCount: wakes,
      minutesScreenBeforeBed: pre,
    );

    final rec = SleepRecord(
      sleepStart: start,
      sleepEnd: end,
      movementCount: movement,
      screenWakeCount: wakes,
      minutesScreenBeforeBed: pre,
      score: score,
    );

    await DbHelper.instance.insert(rec);
    sleepStart = null;
    await load();
    return rec;
  }

  /// Data contoh untuk menguji tampilan (dipanggil dari tombol debug di Home)
  Future<void> seedDemo() async {
    final rnd = Random();
    for (int i = 0; i < 7; i++) {
      final start = DateTime.now()
          .subtract(Duration(days: i, hours: 10, minutes: rnd.nextInt(30)));
      final minutes = 300 + rnd.nextInt(240); // 5 sampai 9 jam
      final end = start.add(Duration(minutes: minutes));
      final move = rnd.nextInt(40);
      final wakes = rnd.nextInt(4);
      final pre = rnd.nextInt(40);

      final score = ScoreCalculator.calculate(
        duration: end.difference(start),
        movementCount: move,
        screenWakeCount: wakes,
        minutesScreenBeforeBed: pre,
      );

      await DbHelper.instance.insert(SleepRecord(
        sleepStart: start,
        sleepEnd: end,
        movementCount: move,
        screenWakeCount: wakes,
        minutesScreenBeforeBed: pre,
        score: score,
      ));
    }
    await load();
  }
}