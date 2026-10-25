import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../widgets/score_card.dart';
import 'session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SleepProvider>();
    final last = p.records.isNotEmpty ? p.records.first : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Lelap',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const Text('Tidur teratur, hari lebih bertenaga',
            style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 24),
        ScoreCard(title: 'Skor mingguan', score: p.weeklyScore),
        const SizedBox(height: 12),
        if (last != null)
          ScoreCard(title: 'Tidur terakhir', score: last.score)
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada data tidur. Mulai tidur malam ini ya!'),
            ),
          ),
        const SizedBox(height: 28),
        SizedBox(
          height: 64,
          child: FilledButton.icon(
            icon: Icon(p.isSleeping ? Icons.play_arrow : Icons.bedtime),
            label: Text(
              p.isSleeping ? 'Lanjutkan Sesi Tidur' : 'Mulai Tidur',
              style: const TextStyle(fontSize: 18),
            ),
            onPressed: () async {
              final provider = context.read<SleepProvider>();
              if (!provider.isSleeping) {
                await provider.startSleep();
              }
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SessionScreen()),
              );
            },
          ),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.read<SleepProvider>().seedDemo(),
            child: const Text('Isi data contoh (debug)'),
          ),
        ],
      ],
    );
  }
}