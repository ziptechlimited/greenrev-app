class InquiryModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String message;
  final String status; // 'NEW', 'READ', 'REPLIED'
  final String createdAt;

  InquiryModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.message,
    this.status = 'NEW',
    required this.createdAt,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      message: json['message'] ?? '',
      status: json['status'] ?? 'NEW',
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'message': message,
        'status': status,
        'createdAt': createdAt,
      };
}
