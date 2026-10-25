import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription? _sub;
  Timer? _fakeTimer;
  double _last = 9.8;
  DateTime _lastCount = DateTime.fromMillisecondsSinceEpoch(0);
  int movementCount = 0;

  void start() {
    movementCount = 0;

    // Di Chrome tidak ada sensor, jadi gerakan disimulasikan
    // (1 gerakan tiap 10 detik) hanya untuk keperluan uji tampilan.
    if (kIsWeb) {
      _fakeTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => movementCount++,
      );
      return;
    }

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

  void stop() {
    _sub?.cancel();
    _sub = null;
    _fakeTimer?.cancel();
    _fakeTimer = null;
  }
}