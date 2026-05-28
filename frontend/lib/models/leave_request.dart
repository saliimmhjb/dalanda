class LeaveRequest {
  final int? id;
  final String employeeName, type, duration, status, iconName;

  LeaveRequest({
    this.id,
    required this.employeeName,
    required this.type,
    required this.duration,
    required this.status,
    required this.iconName
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      employeeName: (json['employee_name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      iconName: (json['icon_data'] ?? 'pause').toString(),
    );
  }
}