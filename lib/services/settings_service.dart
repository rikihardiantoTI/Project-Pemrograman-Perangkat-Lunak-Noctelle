import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _kHour = 'bedtime_hour';
  static const _kMinute = 'bedtime_minute';
  static const _kReminder = 'reminder_enabled';

  Future<TimeOfDay> getBedtime() async {
    final p = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: p.getInt(_kHour) ?? 22,
      minute: p.getInt(_kMinute) ?? 30,
    );
  }

  Future<void> setBedtime(TimeOfDay t) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kHour, t.hour);
    await p.setInt(_kMinute, t.minute);
  }

  Future<bool> getReminderEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kReminder) ?? false;
  }

  Future<void> setReminderEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kReminder, value);
  }
}