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

  void startSleep() {
    sleepStart = DateTime.now();
    _sensor.start();
    WakelockPlus.enable();
    notifyListeners();
  }

  Future<SleepRecord?> wakeUp() async {
    if (sleepStart == null) return null;
    final end = DateTime.now();
    _sensor.stop();
    WakelockPlus.disable();

    int pre = 0, wakes = 0;
    if (await _screen.hasPermission()) {
      pre = await _screen.minutesScreenBeforeBed(sleepStart!);
      wakes = await _screen.wakeCount(sleepStart!, end);
    }

    final score = ScoreCalculator.calculate(
      duration: end.difference(sleepStart!),
      movementCount: _sensor.movementCount,
      screenWakeCount: wakes,
      minutesScreenBeforeBed: pre,
    );

    final rec = SleepRecord(
      sleepStart: sleepStart!, sleepEnd: end,
      movementCount: _sensor.movementCount,
      screenWakeCount: wakes,
      minutesScreenBeforeBed: pre, score: score,
    );
    await DbHelper.instance.insert(rec);
    sleepStart = null;
    await load();
    return rec;
  }
}