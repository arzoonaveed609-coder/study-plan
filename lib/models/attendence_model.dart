class AttendanceModel {
  final String date;
  final String day;
  final String status;

  AttendanceModel({
    required this.date,
    required this.day,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'day': day,
      'status': status,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      date: map['date'] ?? '',
      day: map['day'] ?? '',
      status: map['status'] ?? '',
    );
  }
}