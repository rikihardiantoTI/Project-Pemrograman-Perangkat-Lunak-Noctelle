import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class ScreenEvent {
  final DateTime time;
  final bool on;
  ScreenEvent(this.time, this.on);
}

class ScreenUsageService {
  static const _ch = MethodChannel('lelap/screen');

  Future<bool> hasPermission() async {
    if (kIsWeb) return false; // kode Kotlin tidak ada di web
    return await _ch.invokeMethod<bool>('hasPermission') ?? false;
  }

  Future<void> openSettings() async {
    if (kIsWeb) return;
    await _ch.invokeMethod('openSettings');
  }

  Future<List<ScreenEvent>> events(DateTime start, DateTime end) async {
    if (kIsWeb) return [];
    final raw = await _ch.invokeMethod<List<dynamic>>('getScreenEvents', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    return (raw ?? []).map((e) {
      final l = (e as List).cast<int>();
      return ScreenEvent(DateTime.fromMillisecondsSinceEpoch(l[0]), l[1] == 1);
    }).toList();
  }

  /// Menit layar menyala dalam 30 menit sebelum waktu tidur
  Future<int> minutesScreenBeforeBed(DateTime bedtime) async {
    final start = bedtime.subtract(const Duration(minutes: 30));
    final ev = await events(start.subtract(const Duration(hours: 1)), bedtime);

    int ms = 0;
    DateTime? onAt;
    for (final e in ev) {
      if (e.on) {
        onAt = e.time.isBefore(start) ? start : e.time;
      } else if (onAt != null) {
        final off = e.time.isBefore(start) ? start : e.time;
        if (off.isAfter(onAt)) ms += off.difference(onAt).inMilliseconds;
        onAt = null;
      }
    }
    if (onAt != null) ms += bedtime.difference(onAt).inMilliseconds;
    return (ms / 60000).round();
  }

  /// Berapa kali layar menyala di antara waktu tidur dan bangun
  Future<int> wakeCount(DateTime sleep, DateTime wake) async {
    final ev = await events(sleep, wake);
    return ev.where((e) => e.on).length;
  }
}