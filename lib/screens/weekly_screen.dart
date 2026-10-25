import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final records = provider.records;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Ringkasan mingguan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rata-rata skor 7 hari'),
                const SizedBox(height: 8),
                Text(
                  '${provider.weeklyScore}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  records.isEmpty
                      ? 'Belum ada data untuk dihitung.'
                      : 'Dari ${records.length} sesi tidur',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (records.isNotEmpty)
          ...records.map(
            (record) => Card(
              child: ListTile(
                leading: const Icon(Icons.bedtime),
                title: Text(
                  DateFormat('EEE, d MMM', 'id_ID').format(record.sleepStart),
                ),
                subtitle: Text(
                  '${record.duration.inHours} jam '
                  '${record.duration.inMinutes % 60} menit',
                ),
                trailing: Text('${record.score}/100'),
              ),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Mulai catat tidur untuk melihat ringkasan mingguan.'),
            ),
          ),
      ],
    );
  }
}