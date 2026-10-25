import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/sleep_provider.dart';
import '../widgets/noctelle_ui.dart';
import '../widgets/score_card.dart';
import 'session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final latest = provider.records.isNotEmpty ? provider.records.first : null;
    final dateLabel = DateFormat(
      'EEEE, d MMMM',
      'id_ID',
    ).format(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: NoctelleColors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
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
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Ritme istirahatmu',
                    style: TextStyle(color: NoctelleColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              DateTime.now().hour >= 18 || DateTime.now().hour < 6
                  ? Icons.dark_mode_outlined
                  : Icons.wb_sunny_outlined,
              color: NoctelleColors.lavender,
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          _greeting(),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: NoctelleColors.lavender),
        ),
        const SizedBox(height: 5),
        Text(
          'Ringkasan tidurmu',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.7),
        ),
        const SizedBox(height: 5),
        Text(
          dateLabel,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: NoctelleColors.muted),
        ),
        const SizedBox(height: 22),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          child: latest == null
              ? const NoctellePanel(
                  key: ValueKey('empty-sleep'),
                  child: _EmptySleepSummary(),
                )
              : ScoreCard(
                  key: ValueKey('score-${latest.id}-${latest.score}'),
                  title: 'Skor tidur terakhir',
                  score: latest.score,
                  detail:
                      '${latest.duration.inHours} jam ${latest.duration.inMinutes % 60} menit',
                  icon: Icons.bedtime_outlined,
                ),
        ),
        const SizedBox(height: 14),
        NoctellePanel(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.insights_outlined,
                color: NoctelleColors.lavender,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rata-rata 7 hari',
                      style: TextStyle(
                        color: NoctelleColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Skor mingguan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: provider.weeklyScore.toDouble()),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, score, child) => Text(
                  score.round().toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: NoctelleColors.mint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 58,
          child: FilledButton.icon(
            onPressed: () => _openSession(context),
            icon: Icon(
              provider.isSleeping ? Icons.play_arrow_rounded : Icons.bedtime,
            ),
            label: Text(
              provider.isSleeping ? 'Lanjutkan sesi tidur' : 'Mulai sesi tidur',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
        if (latest != null) ...[
          const SizedBox(height: 26),
          const _SectionLabel('SESI TERAKHIR'),
          const SizedBox(height: 10),
          NoctellePanel(
            padding: const EdgeInsets.all(16),
            color: NoctelleColors.surface.withValues(alpha: 0.75),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: NoctelleColors.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${DateFormat('d MMM', 'id_ID').format(latest.sleepStart)} · '
                    '${DateFormat('HH.mm').format(latest.sleepStart)} – '
                    '${DateFormat('HH.mm').format(latest.sleepEnd)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  '${latest.screenWakeCount}×',
                  style: const TextStyle(
                    color: NoctelleColors.lavender,
                    fontWeight: FontWeight.w600,
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
            child: TextButton(
              onPressed: () => context.read<SleepProvider>().seedDemo(),
              child: const Text('Isi data contoh (debug)'),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptySleepSummary extends StatelessWidget {
  const _EmptySleepSummary();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.bedtime_outlined, color: NoctelleColors.lavender, size: 28),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Belum ada catatan tidur',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(
                'Mulai sesi untuk melihat ringkasan tidurmu.',
                style: TextStyle(color: NoctelleColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: NoctelleColors.muted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}
