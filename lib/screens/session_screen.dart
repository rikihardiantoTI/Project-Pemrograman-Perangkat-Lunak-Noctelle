import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../services/score_calculator.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isWakingUp = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateElapsed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateElapsed() {
    final start = context.read<SleepProvider>().sleepStart;
    if (start == null) return;
    setState(() => _elapsed = DateTime.now().difference(start));
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _wakeUp() async {
    if (_isWakingUp) return;
    setState(() => _isWakingUp = true);
    final record = await context.read<SleepProvider>().wakeUp();
    if (!mounted) return;
    setState(() => _isWakingUp = false);

    if (record == null) {
      Navigator.pop(context);
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sesi tidur selesai'),
        content: Text(
          'Durasi: ${record.duration.inHours} jam '
          '${record.duration.inMinutes % 60} menit\n'
          'Skor tidur: ${record.score} '
          '(${ScoreCalculator.label(record.score)})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSleeping = context.watch<SleepProvider>().isSleeping;

    return Scaffold(
      appBar: AppBar(title: const Text('Sesi tidur')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSleeping ? Icons.nights_stay : Icons.bedtime,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                isSleeping ? 'Waktu istirahat' : 'Tidak ada sesi tidur aktif',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (isSleeping) ...[
                const SizedBox(height: 12),
                Text(
                  _formatDuration(_elapsed),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _isWakingUp ? null : _wakeUp,
                  icon: const Icon(Icons.wb_sunny_outlined),
                  label: Text(_isWakingUp ? 'Menyimpan...' : 'Saya sudah bangun'),
                ),
              ] else ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}