class ExamModel {
  final String subject;
  final String date;
  final String day;
  final String time;
  final String room;

  ExamModel({
    required this.subject,
    required this.date,
    required this.day,
    required this.time,
    required this.room,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'date': date,
      'day': day,
      'time': time,
      'room': room,
    };
  }

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      subject: map['subject'] ?? '',
      date: map['date'] ?? '',
      day: map['day'] ?? '',
      time: map['time'] ?? '',
      room: map['room'] ?? '',
    );
  }
}