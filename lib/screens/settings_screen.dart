import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../services/screen_usage_service.dart';
import '../services/settings_service.dart';
import '../widgets/noctelle_ui.dart';

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
  int _sleepGoalMinutes = 480;
  bool _reminder = false;
  bool _hasUsagePermission = false;
  bool _isSavingReminder = false;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _load() async {
    final time = await _settings.getBedtime();
    final reminder = await _settings.getReminderEnabled();
    final sleepGoal = await _settings.getSleepGoalMinutes();
    if (!mounted) return;
    setState(() {
      _bedtime = time;
      _reminder = reminder;
      _sleepGoalMinutes = sleepGoal;
    });
    await _checkPermission();
  }

  Future<void> _checkPermission() async {
    final allowed = await _screen.hasPermission();
    if (!mounted) return;
    setState(() => _hasUsagePermission = allowed);
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

  Future<void> _pickSleepGoal() async {
    var selectedMinutes = _sleepGoalMinutes;
    final result = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: NoctelleColors.surfaceRaised,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target durasi tidur',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Pilih sasaran yang realistis untuk rutinitasmu.',
                  style: TextStyle(color: NoctelleColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 22),
                Center(
                  child: Text(
                    '${selectedMinutes ~/ 60} jam'
                    '${selectedMinutes % 60 == 0 ? '' : ' 30 menit'}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: NoctelleColors.mint,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Slider(
                  value: selectedMinutes.toDouble(),
                  min: 360,
                  max: 600,
                  divisions: 8,
                  label: '${selectedMinutes ~/ 60} jam',
                  onChanged: (value) =>
                      setSheetState(() => selectedMinutes = value.round()),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '6 jam',
                      style: TextStyle(
                        color: NoctelleColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '10 jam',
                      style: TextStyle(
                        color: NoctelleColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(sheetContext, selectedMinutes),
                    child: const Text('Simpan target'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result == null) return;

    try {
      await _settings.setSleepGoalMinutes(result);
      if (!mounted) return;
      setState(() => _sleepGoalMinutes = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target durasi tidur diperbarui.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Target tidur gagal disimpan: $error')),
      );
    }
  }

  Future<void> _setReminder(bool enabled) async {
    setState(() => _isSavingReminder = true);
    try {
      await _settings.setReminderEnabled(enabled);
      if (!mounted) return;
      setState(() => _reminder = enabled);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengaturan pengingat gagal disimpan: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSavingReminder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      children: [
        const NoctellePageTitle(
          title: 'Pengaturan',
          subtitle: 'Atur target, jadwal, dan akses sesuai kebiasaanmu.',
          icon: Icons.tune_rounded,
        ),
        const SizedBox(height: 24),
        const _SettingsSectionTitle('JADWAL ISTIRAHAT'),
        const SizedBox(height: 10),
        NoctellePanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 5,
                ),
                leading: const _SettingsIcon(
                  icon: Icons.flag_rounded,
                  color: NoctelleColors.mint,
                ),
                title: const Text(
                  'Target durasi tidur',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Sasaran untuk progres dan ringkasan tidur',
                  style: TextStyle(color: NoctelleColors.muted, fontSize: 11),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_sleepGoalMinutes ~/ 60}j'
                      '${_sleepGoalMinutes % 60 == 0 ? '' : ' 30m'}',
                      style: const TextStyle(
                        color: NoctelleColors.mint,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: NoctelleColors.muted,
                    ),
                  ],
                ),
                onTap: _pickSleepGoal,
              ),
              const Divider(height: 1, indent: 18, endIndent: 18),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 5,
                ),
                leading: const _SettingsIcon(
                  icon: Icons.bedtime_outlined,
                  color: NoctelleColors.lavender,
                ),
                title: const Text(
                  'Jam tidur target',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Waktu yang ingin kamu mulai beristirahat',
                  style: TextStyle(color: NoctelleColors.muted, fontSize: 11),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _bedtime.format(context),
                      style: const TextStyle(
                        color: NoctelleColors.mint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: NoctelleColors.muted,
                    ),
                  ],
                ),
                onTap: _pickTime,
              ),
              const Divider(height: 1, indent: 18, endIndent: 18),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 5,
                ),
                secondary: const _SettingsIcon(
                  icon: Icons.notifications_none_rounded,
                  color: NoctelleColors.mint,
                ),
                title: const Text(
                  'Pengingat tidur',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Pengingat 30 menit sebelum target',
                  style: TextStyle(color: NoctelleColors.muted, fontSize: 11),
                ),
                value: _reminder,
                onChanged: _isSavingReminder ? null : _setReminder,
              ),
            ],
          ),
        ),
        const SizedBox(height: 23),
        const _SettingsSectionTitle('PRIVASI & AKSES'),
        const SizedBox(height: 10),
        NoctellePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SettingsIcon(
                    icon: _hasUsagePermission
                        ? Icons.verified_outlined
                        : Icons.shield_outlined,
                    color: _hasUsagePermission
                        ? NoctelleColors.mint
                        : NoctelleColors.lavender,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Akses penggunaan perangkat',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kIsWeb
                              ? 'Tidak tersedia di browser'
                              : _hasUsagePermission
                              ? 'Izin telah diberikan'
                              : 'Izin belum diberikan',
                          style: TextStyle(
                            color: _hasUsagePermission
                                ? NoctelleColors.mint
                                : NoctelleColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Akses ini membantu menghitung waktu layar menyala sebelum dan selama sesi. Noctelle tidak membaca isi aplikasi.',
                style: TextStyle(
                  color: NoctelleColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              if (!kIsWeb && !_hasUsagePermission) ...[
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: _screen.openSettings,
                  icon: const Icon(Icons.open_in_new_rounded, size: 17),
                  label: const Text('Buka pengaturan izin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NoctelleColors.mint,
                    side: BorderSide(
                      color: NoctelleColors.mint.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        NoctellePanel(
          padding: const EdgeInsets.all(16),
          color: NoctelleColors.surface.withValues(alpha: 0.72),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: NoctelleColors.muted,
                size: 18,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Skor tidur adalah estimasi untuk membantu mengenali pola istirahat, bukan alat diagnosis medis.',
                  style: TextStyle(
                    color: NoctelleColors.muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: NoctelleColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}
