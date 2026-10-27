import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/sleep_provider.dart';
import '../services/score_calculator.dart';
import '../services/settings_service.dart';
import '../widgets/noctelle_ui.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _breathingController;
  late final Future<int> _sleepGoal;
  Duration _elapsed = Duration.zero;
  bool _isWakingUp = false;

  @override
  void initState() {
    super.initState();
    _sleepGoal = SettingsService().getSleepGoalMinutes();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
      lowerBound: 0.94,
      upperBound: 1,
    )..repeat(reverse: true);
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateElapsed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
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
    HapticFeedback.selectionClick();
    setState(() => _isWakingUp = true);

    try {
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
    } catch (error) {
      if (!mounted) return;
      setState(() => _isWakingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sesi belum dapat disimpan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final start = provider.sleepStart;

    return Scaffold(
      backgroundColor: NoctelleColors.background,
      appBar: AppBar(
        backgroundColor: NoctelleColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Sesi tidur',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: NoctellePage(
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              child: Column(
                children: [
                  _MonitoringPill(isActive: provider.isSleeping),
                  const SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, child) => Transform.scale(
                      scale: _breathingController.value,
                      child: child,
                    ),
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NoctelleColors.surface,
                        border: Border.all(
                          color: NoctelleColors.lavender.withValues(
                            alpha: 0.12,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NoctelleColors.lavender.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 50,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.nightlight_round,
                          size: 72,
                          color: NoctelleColors.lavender,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 27),
                  Text(
                    provider.isSleeping
                        ? 'Waktunya beristirahat'
                        : 'Sesi selesai',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.isSleeping
                        ? 'Kami mencatat durasi istirahatmu.'
                        : 'Tidak ada sesi tidur yang sedang berjalan.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: NoctelleColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _formatDuration(_elapsed),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  if (start != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dimulai pukul ${TimeOfDay.fromDateTime(start).format(context)}',
                      style: const TextStyle(
                        color: NoctelleColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  FutureBuilder<int>(
                    future: _sleepGoal,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return _SessionGoalProgress(
                        elapsed: _elapsed,
                        targetMinutes: snapshot.data!,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: provider.isSleeping && !_isWakingUp
                          ? _wakeUp
                          : () => Navigator.pop(context),
                      icon: Icon(
                        provider.isSleeping
                            ? Icons.wb_sunny_outlined
                            : Icons.arrow_back_rounded,
                      ),
                      label: Text(
                        _isWakingUp
                            ? 'Menyimpan sesi...'
                            : provider.isSleeping
                            ? 'Saya sudah bangun'
                            : 'Kembali ke beranda',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: NoctelleColors.mint,
                        foregroundColor: const Color(0xFF06241D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Semoga istirahatmu nyaman.',
                    style: TextStyle(color: NoctelleColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonitoringPill extends StatelessWidget {
  const _MonitoringPill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: NoctelleColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: NoctelleColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isActive ? NoctelleColors.mint : NoctelleColors.muted,
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'PEMANTAUAN AKTIF' : 'PEMANTAUAN BERHENTI',
            style: TextStyle(
              color: isActive ? NoctelleColors.mint : NoctelleColors.muted,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionGoalProgress extends StatelessWidget {
  const _SessionGoalProgress({
    required this.elapsed,
    required this.targetMinutes,
  });

  final Duration elapsed;
  final int targetMinutes;

  @override
  Widget build(BuildContext context) {
    final elapsedMinutes = elapsed.inMinutes;
    final progress = (elapsedMinutes / targetMinutes).clamp(0.0, 1.0);
    final remainingMinutes = (targetMinutes - elapsedMinutes).clamp(
      0,
      targetMinutes,
    );

    return NoctellePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: NoctelleColors.mint,
                size: 18,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Menuju target tidur',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              Text(
                '${elapsedMinutes ~/ 60}j ${elapsedMinutes % 60}m'
                ' / ${targetMinutes ~/ 60}j',
                style: const TextStyle(
                  color: NoctelleColors.lavender,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: NoctelleColors.surfaceRaised,
              valueColor: const AlwaysStoppedAnimation(NoctelleColors.mint),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remainingMinutes == 0
                ? 'Target tercapai. Kamu bisa mengakhiri sesi kapan saja.'
                : 'Sekitar ${remainingMinutes ~/ 60} jam '
                      '${remainingMinutes % 60} menit menuju target.',
            style: const TextStyle(color: NoctelleColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
