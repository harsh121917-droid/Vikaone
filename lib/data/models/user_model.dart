class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  UserModel({required this.id, required this.name, required this.email, this.phone, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['_id'] ?? '', name: j['name'] ?? '', email: j['email'] ?? '',
    phone: j['phone'], role: j['role'] ?? 'user',
  );

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'email': email, 'phone': phone, 'role': role};
}
