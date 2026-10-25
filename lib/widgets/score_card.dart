import 'package:flutter/material.dart';

import '../services/score_calculator.dart';
import 'noctelle_ui.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    required this.title,
    required this.score,
    this.detail,
    this.icon = Icons.auto_awesome_outlined,
    super.key,
  });

  final String title;
  final int score;
  final String? detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final normalizedScore = score.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202947), NoctelleColors.surface],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: NoctelleColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 17, color: NoctelleColors.lavender),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: NoctelleColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Text(
                  ScoreCalculator.label(normalizedScore),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: NoctelleColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: normalizedScore.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedScore, child) => SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: animatedScore / 100,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation(
                        NoctelleColors.mint,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        animatedScore.round().toString(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: NoctelleColors.mint,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'DARI 100',
                        style: TextStyle(
                          color: NoctelleColors.muted,
                          fontSize: 8,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
