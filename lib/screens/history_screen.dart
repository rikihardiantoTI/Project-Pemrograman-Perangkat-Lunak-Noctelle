import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/sleep_record.dart';
import '../providers/sleep_provider.dart';
import '../services/score_calculator.dart';
import '../widgets/noctelle_ui.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _durationLabel(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return hours == 0 ? '$minutes menit' : '$hours jam $minutes menit';
  }

  String _dateLabel(DateTime date) {
    final today = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final difference = todayOnly.difference(day).inDays;
    if (difference == 0) return 'Hari ini';
    if (difference == 1) return 'Kemarin';
    return DateFormat('EEEE, d MMMM', 'id_ID').format(date);
  }

  void _showDetails(BuildContext context, SleepRecord record) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: NoctelleColors.surfaceRaised,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dateLabel(record.sleepStart),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('HH.mm').format(record.sleepStart)} – '
                '${DateFormat('HH.mm').format(record.sleepEnd)}',
                style: const TextStyle(color: NoctelleColors.muted),
              ),
              const SizedBox(height: 20),
              _DetailLine(
                icon: Icons.timelapse_outlined,
                label: 'Durasi tidur',
                value: _durationLabel(record.duration),
              ),
              _DetailLine(
                icon: Icons.nightlight_outlined,
                label: 'Skor tidur',
                value:
                    '${record.score} · ${ScoreCalculator.label(record.score)}',
              ),
              _DetailLine(
                icon: Icons.screen_lock_portrait_outlined,
                label: 'Layar menyala',
                value: '${record.screenWakeCount} kali',
              ),
              _DetailLine(
                icon: Icons.directions_walk_outlined,
                label: 'Gerakan terdeteksi',
                value: '${record.movementCount}',
              ),
              _DetailLine(
                icon: Icons.phone_android_outlined,
                label: 'Layar sebelum tidur',
                value: '${record.minutesScreenBeforeBed} menit',
              ),
              const SizedBox(height: 12),
              Text(
                'Skor merupakan estimasi, bukan diagnosis medis.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: NoctelleColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<SleepProvider>().records;
    final averageDuration = records.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds:
                records.fold<int>(
                  0,
                  (total, record) => total + record.duration.inMilliseconds,
                ) ~/
                records.length,
          );
    final averageScore = records.isEmpty
        ? 0
        : (records.fold<int>(0, (total, record) => total + record.score) /
                  records.length)
              .round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      children: [
        const NoctellePageTitle(
          title: 'Riwayat tidur',
          subtitle: 'Lihat pola istirahatmu dalam 7 hari terakhir.',
        ),
        const SizedBox(height: 20),
        NoctellePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RINGKASAN 7 HARI',
                style: TextStyle(
                  color: NoctelleColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SummaryMetric(
                      icon: Icons.timelapse_outlined,
                      label: 'Rata-rata durasi',
                      value: records.isEmpty
                          ? '—'
                          : _durationLabel(averageDuration),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryMetric(
                      icon: Icons.auto_awesome_outlined,
                      label: 'Rata-rata skor',
                      value: records.isEmpty ? '—' : '$averageScore / 100',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${records.length} sesi tercatat',
                style: const TextStyle(
                  color: NoctelleColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Semua sesi',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (records.isEmpty)
          const NoctellePanel(
            child: Row(
              children: [
                Icon(Icons.bedtime_outlined, color: NoctelleColors.lavender),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Riwayat tidurmu akan muncul setelah sesi pertama selesai.',
                    style: TextStyle(color: NoctelleColors.muted),
                  ),
                ),
              ],
            ),
          )
        else
          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 320 + index * 55),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Material(
                  color: NoctelleColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showDetails(context, record),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: NoctelleColors.lavender.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.bedtime_outlined,
                              color: NoctelleColors.lavender,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dateLabel(record.sleepStart),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _durationLabel(record.duration),
                                  style: const TextStyle(
                                    color: NoctelleColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${record.score}',
                                style: const TextStyle(
                                  color: NoctelleColors.mint,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                ScoreCalculator.label(record.score),
                                style: const TextStyle(
                                  color: NoctelleColors.muted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: NoctelleColors.muted,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: NoctelleColors.mint, size: 19),
        const SizedBox(height: 9),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: NoctelleColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: NoctelleColors.lavender, size: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: NoctelleColors.muted, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
