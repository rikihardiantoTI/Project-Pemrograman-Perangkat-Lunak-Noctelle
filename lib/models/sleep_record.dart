class SleepRecord {
  final int? id;
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final int movementCount;   // jumlah gerakan terdeteksi
  final int screenWakeCount; // berapa kali layar menyala saat tidur
  final int minutesScreenBeforeBed; // pemakaian layar 30 menit sebelum tidur
  final int score;

  SleepRecord({
    this.id,
    required this.sleepStart,
    required this.sleepEnd,
    required this.movementCount,
    required this.screenWakeCount,
    required this.minutesScreenBeforeBed,
    required this.score,
  });

  Duration get duration => sleepEnd.difference(sleepStart);

  Map<String, dynamic> toMap() => {
        'id': id,
        'sleep_start': sleepStart.millisecondsSinceEpoch,
        'sleep_end': sleepEnd.millisecondsSinceEpoch,
        'movement_count': movementCount,
        'screen_wake_count': screenWakeCount,
        'minutes_screen_before_bed': minutesScreenBeforeBed,
        'score': score,
      };

  factory SleepRecord.fromMap(Map<String, dynamic> m) => SleepRecord(
        id: m['id'],
        sleepStart: DateTime.fromMillisecondsSinceEpoch(m['sleep_start']),
        sleepEnd: DateTime.fromMillisecondsSinceEpoch(m['sleep_end']),
        movementCount: m['movement_count'],
        screenWakeCount: m['screen_wake_count'],
        minutesScreenBeforeBed: m['minutes_screen_before_bed'],
        score: m['score'],
      );
}