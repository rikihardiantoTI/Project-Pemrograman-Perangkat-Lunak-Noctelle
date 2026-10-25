import 'package:flutter/services.dart';

class ScreenEvent {
  final DateTime time;
  final bool on;
  ScreenEvent(this.time, this.on);
}

class ScreenUsageService {
  static const _ch = MethodChannel('lelap/screen');

  Future<bool> hasPermission() async =>
      await _ch.invokeMethod<bool>('hasPermission') ?? false;

  Future<void> openSettings() => _ch.invokeMethod('openSettings');

  Future<List<ScreenEvent>> events(DateTime start, DateTime end) async {
    final raw = await _ch.invokeMethod<List<dynamic>>('getScreenEvents', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    return (raw ?? []).map((e) {
      final l = (e as List).cast<int>();
      return ScreenEvent(DateTime.fromMillisecondsSinceEpoch(l[0]), l[1] == 1);
    }).toList();
  }

  /// Hitung menit layar menyala dalam 30 menit sebelum waktu tidur
  Future<int> minutesScreenBeforeBed(DateTime bedtime) async {
    final start = bedtime.subtract(const Duration(minutes: 30));
    final ev = await events(start.subtract(const Duration(hours: 1)), bedtime);
    int ms = 0;
    DateTime? onAt;
    for (final e in ev) {
      if (e.on) {
        onAt = e.time.isBefore(start) ? start : e.time;
      } else if (onAt != null) {
        ms += e.time.difference(onAt).inMilliseconds;
        onAt = null;
      }
    }
    if (onAt != null) ms += bedtime.difference(onAt).inMilliseconds;
    return (ms / 60000).round();
  }

  /// Berapa kali layar menyala di antara tidur dan bangun
  Future<int> wakeCount(DateTime sleep, DateTime wake) async {
    final ev = await events(sleep, wake);
    return ev.where((e) => e.on).length;
  }
}