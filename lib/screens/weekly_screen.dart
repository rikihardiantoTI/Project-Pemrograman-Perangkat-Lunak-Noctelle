import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/sleep_record.dart';
import '../providers/sleep_provider.dart';
import '../widgets/noctelle_ui.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  List<_DailySleep> _buildWeek(List<SleepRecord> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final dayRecords = records.where(
        (record) =>
            record.sleepStart.year == date.year &&
            record.sleepStart.month == date.month &&
            record.sleepStart.day == date.day,
      );
      final scores = dayRecords.map((record) => record.score).toList();
      final durations = dayRecords
          .map((record) => record.duration.inMinutes)
          .toList();

      return _DailySleep(
        date: date,
        score: scores.isEmpty
            ? 0
            : (scores.reduce((a, b) => a + b) / scores.length).round(),
        durationMinutes: durations.isEmpty
            ? 0
            : (durations.reduce((a, b) => a + b) / durations.length).round(),
      );
    });
  }

  String _durationLabel(int minutes) {
    if (minutes <= 0) return '—';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return hours == 0
        ? '$remainingMinutes mnt'
        : '${hours}j ${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final records = provider.records;
    final week = _buildWeek(records);
    final averageDuration = records.isEmpty
        ? 0
        : records.fold<int>(
                0,
                (total, record) => total + record.duration.inMinutes,
              ) ~/
              records.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      children: [
        const NoctellePageTitle(
          title: 'Minggu ini',
          subtitle: 'Gambaran singkat pola tidurmu.',
        ),
        const SizedBox(height: 20),
        NoctellePanel(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RATA-RATA SKOR',
                style: TextStyle(
                  color: NoctelleColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${provider.weeklyScore}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: NoctelleColors.mint,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 7, bottom: 5),
                    child: Text(
                      '/ 100',
                      style: TextStyle(color: NoctelleColors.muted),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${records.length} sesi',
                    style: const TextStyle(color: NoctelleColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              const Divider(color: NoctelleColors.outline, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.timelapse_outlined,
                    color: NoctelleColors.lavender,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'Rata-rata durasi tidur',
                      style: TextStyle(color: NoctelleColors.muted),
                    ),
                  ),
                  Text(
                    _durationLabel(averageDuration),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Skor per hari',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        NoctellePanel(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: week
                      .map(
                        (day) => Expanded(
                          child: _ScoreBar(
                            day: day,
                            durationLabel: _durationLabel,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 17),
              const Row(
                children: [
                  Icon(Icons.circle, size: 7, color: NoctelleColors.mint),
                  SizedBox(width: 7),
                  Text(
                    'Skor tidur',
                    style: TextStyle(color: NoctelleColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (records.isEmpty)
          const NoctellePanel(
            child: Text(
              'Belum ada data minggu ini. Selesaikan sesi tidur untuk mulai melihat polanya.',
              style: TextStyle(color: NoctelleColors.muted, height: 1.5),
            ),
          )
        else
          Text(
            'Durasi rata-rata dihitung dari ${records.length} sesi yang tercatat.',
            style: const TextStyle(color: NoctelleColors.muted, fontSize: 12),
          ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.day, required this.durationLabel});

  final _DailySleep day;
  final String Function(int) durationLabel;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE', 'id_ID').format(day.date);
    final barHeight = day.score == 0
        ? 4.0
        : (day.score / 100 * 96).clamp(8.0, 96.0);

    return Tooltip(
      message: day.score == 0
          ? '${DateFormat('d MMM', 'id_ID').format(day.date)} · Belum ada data'
          : '${DateFormat('d MMM', 'id_ID').format(day.date)} · '
                '${day.score}/100 · ${durationLabel(day.durationMinutes)}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 20,
              child: Text(
                day.score == 0 ? '' : '${day.score}',
                style: const TextStyle(
                  color: NoctelleColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              height: barHeight,
              decoration: BoxDecoration(
                color: day.score == 0
                    ? NoctelleColors.surfaceRaised
                    : NoctelleColors.mint.withValues(
                        alpha: 0.35 + day.score / 180,
                      ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              dateLabel,
              maxLines: 1,
              style: const TextStyle(color: NoctelleColors.muted, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySleep {
  const _DailySleep({
    required this.date,
    required this.score,
    required this.durationMinutes,
  });

  final DateTime date;
  final int score;
  final int durationMinutes;
}
