import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/sleep_record.dart';
import '../providers/sleep_provider.dart';
import '../services/score_calculator.dart';
import '../services/settings_service.dart';
import '../widgets/noctelle_ui.dart';
import 'session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _settings = SettingsService();
  late Future<int> _sleepGoal;

  @override
  void initState() {
    super.initState();
    _sleepGoal = _settings.getSleepGoalMinutes();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _openSession(BuildContext context) async {
    HapticFeedback.selectionClick();
    final provider = context.read<SleepProvider>();
    if (!provider.isSleeping) await provider.startSleep();
    if (!context.mounted) return;

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, animation, secondaryAnimation) =>
            const SessionScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  String _durationLabel(Duration duration) {
    return '${duration.inHours}j ${duration.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final latest = provider.records.isNotEmpty ? provider.records.first : null;
    final dateLabel = DateFormat(
      'EEEE, d MMMM',
      'id_ID',
    ).format(DateTime.now());
    final averageDuration = provider.records.isEmpty
        ? Duration.zero
        : Duration(
            minutes:
                provider.records.fold<int>(
                  0,
                  (total, record) => total + record.duration.inMinutes,
                ) ~/
                provider.records.length,
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF293456), NoctelleColors.surfaceRaised],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: NoctelleColors.mint.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: NoctelleColors.mint,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOCTELLE',
                    style: TextStyle(
                      color: NoctelleColors.mint,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Ritme istirahatmu',
                    style: TextStyle(color: NoctelleColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NoctelleColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NoctelleColors.outline),
              ),
              child: Icon(
                DateTime.now().hour >= 18 || DateTime.now().hour < 6
                    ? Icons.dark_mode_outlined
                    : Icons.wb_sunny_outlined,
                color: NoctelleColors.lavender,
                size: 19,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          _greeting(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: NoctelleColors.lavender,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ringkasan tidurmu',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: NoctelleColors.muted,
              size: 13,
            ),
            const SizedBox(width: 7),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: NoctelleColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SleepOverviewCard(record: latest),
        const SizedBox(height: 13),
        FutureBuilder<int>(
          future: _sleepGoal,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const NoctellePanel(
                padding: EdgeInsets.all(17),
                child: LinearProgressIndicator(
                  color: NoctelleColors.mint,
                  backgroundColor: NoctelleColors.surfaceRaised,
                ),
              );
            }
            return _SleepGoalCard(
              goalMinutes: snapshot.data!,
              latestDuration: latest?.duration,
            );
          },
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: Icons.insights_rounded,
                label: 'Skor 7 hari',
                value: '${provider.weeklyScore}',
                accent: NoctelleColors.mint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.timelapse_rounded,
                label: 'Rata-rata durasi',
                value: provider.records.isEmpty
                    ? '—'
                    : _durationLabel(averageDuration),
                accent: NoctelleColors.lavender,
              ),
            ),
          ],
        ),
        const SizedBox(height: 21),
        SizedBox(
          height: 58,
          child: FilledButton.icon(
            onPressed: () => _openSession(context),
            icon: Icon(
              provider.isSleeping ? Icons.play_arrow_rounded : Icons.bedtime,
            ),
            label: Text(
              provider.isSleeping ? 'Lanjutkan sesi tidur' : 'Mulai sesi tidur',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: NoctelleColors.mint,
              foregroundColor: const Color(0xFF06241D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
              elevation: 3,
              shadowColor: NoctelleColors.mint.withValues(alpha: 0.25),
            ),
          ),
        ),
        if (latest != null) ...[
          const SizedBox(height: 25),
          NoctelleSectionLabel(
            'Sesi terakhir',
            trailing: ScoreCalculator.label(latest.score),
          ),
          const SizedBox(height: 10),
          NoctellePanel(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                _MetricIcon(
                  icon: Icons.schedule_rounded,
                  color: NoctelleColors.lavender,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('d MMM', 'id_ID').format(latest.sleepStart)} · '
                        '${DateFormat('HH.mm').format(latest.sleepStart)} – '
                        '${DateFormat('HH.mm').format(latest.sleepEnd)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${latest.screenWakeCount} kali layar menyala',
                        style: const TextStyle(
                          fontSize: 11,
                          color: NoctelleColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${latest.score}',
                  style: const TextStyle(
                    color: NoctelleColors.mint,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (kDebugMode) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () => context.read<SleepProvider>().seedDemo(),
              icon: const Icon(Icons.science_outlined, size: 16),
              label: const Text('Isi data contoh'),
            ),
          ),
        ],
      ],
    );
  }
}

class _SleepOverviewCard extends StatelessWidget {
  const _SleepOverviewCard({required this.record});

  final SleepRecord? record;

  @override
  Widget build(BuildContext context) {
    final score = record?.score;
    final duration = record?.duration;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29375D), Color(0xFF1A2340), Color(0xFF172039)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: NoctelleColors.lavender.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -25,
            child: Icon(
              Icons.nightlight_round,
              size: 132,
              color: Colors.white.withValues(alpha: 0.035),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'KUALITAS ISTIRAHAT',
                      style: TextStyle(
                        color: NoctelleColors.lavender,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: NoctelleColors.mint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: NoctelleColors.mint,
                          size: 12,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'RINGKASAN',
                          style: TextStyle(
                            color: NoctelleColors.mint,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          score == null
                              ? 'Mulai dari malam ini'
                              : ScoreCalculator.label(score),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          duration == null
                              ? 'Catat sesi tidur pertamamu untuk melihat kualitas istirahat.'
                              : 'Tidur ${duration.inHours} jam '
                                    '${duration.inMinutes % 60} menit pada sesi terakhir.',
                          style: const TextStyle(
                            color: NoctelleColors.muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ScoreRing(score: score ?? 0, hasRecord: score != null),
                ],
              ),
              const SizedBox(height: 17),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    score == null
                        ? Icons.tips_and_updates_outlined
                        : score >= 75
                        ? Icons.check_circle_outline_rounded
                        : Icons.lightbulb_outline_rounded,
                    color: NoctelleColors.mint,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      score == null
                          ? 'Kebiasaan kecil yang konsisten dimulai dari satu malam.'
                          : score >= 75
                          ? 'Pertahankan rutinitas istirahatmu yang baik.'
                          : 'Coba kurangi layar dan mulai istirahat lebih awal.',
                      style: const TextStyle(
                        color: Color(0xFFD8E1F7),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.hasRecord});

  final int score;
  final bool hasRecord;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: hasRecord ? score / 100 : 0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.09),
                valueColor: const AlwaysStoppedAnimation(NoctelleColors.mint),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasRecord ? '$score' : '--',
                style: const TextStyle(
                  color: NoctelleColors.mint,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'DARI 100',
                style: TextStyle(
                  color: NoctelleColors.muted,
                  fontSize: 7,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepGoalCard extends StatelessWidget {
  const _SleepGoalCard({
    required this.goalMinutes,
    required this.latestDuration,
  });

  final int goalMinutes;
  final Duration? latestDuration;

  @override
  Widget build(BuildContext context) {
    final actualMinutes = latestDuration?.inMinutes ?? 0;
    final progress = (actualMinutes / goalMinutes).clamp(0.0, 1.0);
    final remaining = (goalMinutes - actualMinutes).clamp(0, goalMinutes);
    return NoctellePanel(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MetricIcon(icon: Icons.flag_rounded, color: NoctelleColors.mint),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target tidur',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Progres dari sesi terakhir',
                      style: TextStyle(
                        color: NoctelleColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${actualMinutes ~/ 60}j ${actualMinutes % 60}m',
                style: const TextStyle(
                  color: NoctelleColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' / ${goalMinutes ~/ 60}j',
                style: const TextStyle(
                  color: NoctelleColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: NoctelleColors.surfaceRaised,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1 ? NoctelleColors.mint : NoctelleColors.lavender,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            latestDuration == null
                ? 'Selesaikan satu sesi untuk mulai melacak target.'
                : remaining == 0
                ? 'Target tidur tercapai. Kerja bagus!'
                : 'Kurang ${remaining ~/ 60} jam ${remaining % 60} menit dari target.',
            style: const TextStyle(color: NoctelleColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return NoctellePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 11),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: accent, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: NoctelleColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({required this.icon, required this.color});

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
