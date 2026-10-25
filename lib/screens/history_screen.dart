import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record.dart';
import '../providers/sleep_provider.dart';
import '../services/score_calculator.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _durationLabel(SleepRecord record) {
    final hours = record.duration.inHours;
    final minutes = record.duration.inMinutes % 60;
    return '$hours jam $minutes menit';
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<SleepProvider>().records;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Riwayat tidur', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (records.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Riwayat tidur akan muncul setelah sesi pertama.'),
            ),
          )
        else
          ...records.map(
            (record) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${record.score}'),
                ),
                title: Text(
                  DateFormat('EEE, d MMM', 'id_ID').format(record.sleepStart),
                ),
                subtitle: Text(
                  '${_durationLabel(record)} · '
                  '${ScoreCalculator.label(record.score)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(
                      DateFormat('EEEE, d MMMM', 'id_ID')
                          .format(record.sleepStart),
                    ),
                    content: Text(
                      'Durasi: ${_durationLabel(record)}\n'
                      'Gerakan: ${record.movementCount}\n'
                      'Layar menyala: ${record.screenWakeCount} kali\n'
                      'Penggunaan layar sebelum tidur: '
                      '${record.minutesScreenBeforeBed} menit\n'
                      'Skor: ${record.score} '
                      '(${ScoreCalculator.label(record.score)})',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}