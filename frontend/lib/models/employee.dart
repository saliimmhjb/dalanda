class Employee {
  final int? id;
  final String name, role, email, phone, department, performance, projects, tenure, imageUrl, grade;
  final int annual_leave_balance;
  final int sick_leave_balance;
  final bool isChief;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.department,
    required this.performance,
    required this.tenure,
    required this.imageUrl,
    required this.projects,
    required this.grade,
    required this.annual_leave_balance,
    required this.sick_leave_balance,
    required this.isChief,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Correction de l'IP pour l'émulateur
    String? rawImage = json['image'];
    String fixedImage = rawImage != null
        ? rawImage.replaceAll('127.0.0.1', '10.0.2.2')
        : 'assets/profile.jpg';

    return Employee(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] is Map
          ? json['department']['name'] ?? ''
          : (json['department']?.toString() ?? 'General'),
      role: json['position'] ?? '',
      phone: json['phone'] ?? '',
      performance: json['performance'] ?? '0%',
      projects: json['projects']?.toString() ?? '0',
      tenure: json['tenure'] ?? 'New',
      imageUrl: fixedImage,
      grade: json['grade'] ?? 'Junior',
      annual_leave_balance: json['annual_leave_balance'] ?? 0,
      sick_leave_balance: json['sick_leave_balance'] ?? 0,
      isChief: json['is_chief'] ?? false,
    );
  }
}