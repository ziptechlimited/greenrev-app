class UserModel {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? companyName;
  final String? garageName;
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.companyName,
    this.garageName,
    required this.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      name: json['name'],
      companyName: json['companyName'],
      garageName: json['garageName'],
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'companyName': companyName,
      'garageName': garageName,
      'isEmailVerified': isEmailVerified,
    };
  }
}
