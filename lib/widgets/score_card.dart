import 'package:flutter/material.dart';
import '../services/score_calculator.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    required this.title,
    required this.score,
    super.key,
  });

  final String title;
  final int score;

  @override
  Widget build(BuildContext context) {
    final normalizedScore = score.clamp(0, 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    ScoreCalculator.label(normalizedScore),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: normalizedScore / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.white12,
                  ),
                  Center(
                    child: Text(
                      '$normalizedScore',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}