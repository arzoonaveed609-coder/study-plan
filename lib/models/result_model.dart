class ResultModel {
  final String subject;
  final int marks;
  final int totalMarks;
  final double percentage;
  final String grade;

  ResultModel({
    required this.subject,
    required this.marks,
    required this.totalMarks,
    required this.percentage,
    required this.grade,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'marks': marks,
      'totalMarks': totalMarks,
      'percentage': percentage,
      'grade': grade,
    };
  }

  factory ResultModel.fromMap(Map<String, dynamic> map) {
    return ResultModel(
      subject: map['subject'] ?? '',
      marks: map['marks'] ?? 0,
      totalMarks: map['totalMarks'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
      grade: map['grade'] ?? '',
    );
  }
}