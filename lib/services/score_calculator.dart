class ScoreCalculator {
  static int calculate({
    required Duration duration,
    required int movementCount,
    required int screenWakeCount,
    required int minutesScreenBeforeBed,
  }) {
    final hours = duration.inMinutes / 60;

    // 1) Durasi (maks 40)
    double durScore;
    if (hours >= 7 && hours <= 9) {
      durScore = 40;
    } else if (hours < 7) {
      durScore = (hours / 7) * 40;
    } else {
      durScore = (40 - (hours - 9) * 8).clamp(0, 40).toDouble();
    }

    // 2) Layar menyala saat tidur (maks 20)
    final wakeScore = (20 - screenWakeCount * 5).clamp(0, 20).toDouble();

    // 3) Gerakan per jam (maks 20)
    final perHour = hours > 0 ? movementCount / hours : 0;
    final moveScore = (20 - perHour * 1.5).clamp(0, 20).toDouble();

    // 4) Layar sebelum tidur (maks 20)
    final preScore = (20 - minutesScreenBeforeBed * 1.0).clamp(0, 20).toDouble();

    return (durScore + wakeScore + moveScore + preScore).round().clamp(0, 100);
  }

  static String label(int score) {
    if (score >= 85) return 'Sangat baik';
    if (score >= 70) return 'Baik';
    if (score >= 50) return 'Cukup';
    return 'Perlu diperbaiki';
  }

  /// Skor mingguan = rata-rata skor 7 hari terakhir
  static int weekly(List<int> scores) =>
      scores.isEmpty ? 0 : (scores.reduce((a, b) => a + b) / scores.length).round();
}