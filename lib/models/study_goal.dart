// TODO Implement this library.
// Ye simple data model hai jo ek "Study Goal" ko represent karta hai.
// Jaise: Subject, Topic/Chapter, Date, Time, Duration, Priority.

class StudyGoal {
  final String id;
  final String subject;
  final String topic;
  final DateTime date;
  final String time; // e.g. "11:38 PM"
  final int durationMinutes; // e.g. 25
  final String priority; // Low / Medium / High
  bool isCompleted;

  StudyGoal({
    required this.id,
    required this.subject,
    required this.topic,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.priority,
    this.isCompleted = false,
  });
}
