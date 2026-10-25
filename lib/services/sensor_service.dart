import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription? _sub;
  double _last = 9.8;
  DateTime _lastCount = DateTime.fromMillisecondsSinceEpoch(0);
  int movementCount = 0;

  void start() {
    movementCount = 0;
    _sub = accelerometerEventStream().listen((e) {
      final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      final delta = (mag - _last).abs();
      _last = mag;
      final now = DateTime.now();
      // ambang 0.5 dan jeda 5 detik agar satu gerakan tidak dihitung berkali-kali
      if (delta > 0.5 && now.difference(_lastCount).inSeconds >= 5) {
        movementCount++;
        _lastCount = now;
      }
    });
  }

  void stop() => _sub?.cancel();
}