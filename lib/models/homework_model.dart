class HomeworkModel {
  final String subject;
  final String title;
  final String description;
  final String dueDate;
  final bool isCompleted;

  HomeworkModel({
    required this.subject,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
    };
  }

  factory HomeworkModel.fromMap(Map<String, dynamic> map) {
    return HomeworkModel(
      subject: map['subject'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}