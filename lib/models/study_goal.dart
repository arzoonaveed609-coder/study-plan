class StudyGoal {
  final String id;
  final String subject;
  final String topic;
  final DateTime date;
  final String time;
  final int durationMinutes;
  final String priority;

  bool isCompleted;

  // Focus Timer ki full duration complete hui ya nahi
  bool isFocusTimerCompleted;

  StudyGoal({
    required this.id,
    required this.subject,
    required this.topic,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.priority,
    this.isCompleted = false,
    this.isFocusTimerCompleted = false,
  });
}