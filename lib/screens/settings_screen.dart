import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/screen_usage_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final _settings = SettingsService();
  final _screen = ScreenUsageService();

  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  bool _reminder = false;
  bool _hasUsagePermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Saat pengguna kembali dari layar pengaturan sistem, cek ulang izin
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _load() async {
    final t = await _settings.getBedtime();
    final r = await _settings.getReminderEnabled();
    if (!mounted) return;
    setState(() {
      _bedtime = t;
      _reminder = r;
    });
    await _checkPermission();
  }

  Future<void> _checkPermission() async {
    final ok = await _screen.hasPermission();
    if (!mounted) return;
    setState(() => _hasUsagePermission = ok);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
      helpText: 'Pilih jam tidur target',
    );
    if (picked == null) return;
    await _settings.setBedtime(picked);
    if (!mounted) return;
    setState(() => _bedtime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Pengaturan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('Jam tidur target'),
                subtitle: const Text('Dipakai untuk pengingat'),
                trailing: Text(
                  _bedtime.format(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                onTap: _pickTime,
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: const Text('Pengingat tidur'),
                subtitle: const Text('Diingatkan 30 menit sebelum jam target'),
                value: _reminder,
                onChanged: (v) async {
                  await _settings.setReminderEnabled(v);
                  if (!mounted) return;
                  setState(() => _reminder = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _hasUsagePermission
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: _hasUsagePermission
                          ? const Color(0xFF4CD6A0)
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Akses penggunaan perangkat',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  kIsWeb
                      ? 'Fitur membaca pola layar hanya tersedia di aplikasi Android.'
                      : _hasUsagePermission
                          ? 'Izin sudah diberikan. Lelap dapat membaca kapan layar menyala dan mati untuk menghitung skor.'
                          : 'Izin ini dibutuhkan agar Lelap tahu kapan layar menyala sebelum dan selama tidur. Lelap hanya membaca waktu layar menyala/mati, bukan isi aplikasimu.',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (!kIsWeb && !_hasUsagePermission) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _screen.openSettings,
                    child: const Text('Buka pengaturan izin'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tentang skor: skor tidur adalah estimasi dari durasi, gerakan, dan pemakaian layar. Skor ini bukan alat diagnosis medis.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}