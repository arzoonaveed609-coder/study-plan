class LeaveRequestModel {
  final String leaveType;
  final String date;
  final String reason;
  final String status;

  LeaveRequestModel({
    required this.leaveType,
    required this.date,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'leaveType': leaveType,
      'date': date,
      'reason': reason,
      'status': status,
    };
  }

  factory LeaveRequestModel.fromMap(Map<String, dynamic> map) {
    return LeaveRequestModel(
      leaveType: map['leaveType'] ?? '',
      date: map['date'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }
}