class NoticeModel {
  final String title;
  final String date;
  final String description;
  final bool isNew;

  NoticeModel({
    required this.title,
    required this.date,
    required this.description,
    required this.isNew,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
      'isNew': isNew,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map) {
    return NoticeModel(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      isNew: map['isNew'] ?? false,
    );
  }
}