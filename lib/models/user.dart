import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String role;
  final String? name;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print('User.fromJson - Raw JSON: $json');
    
    final id = json['id'] as String? ?? json['_id'] as String? ?? '';
    final email = json['email'] as String? ?? '';
    final role = json['role'] as String? ?? '';
    final name = json['name'] as String?;
    
    print('User.fromJson - Extracted: id=$id, email=$email, role=$role, name=$name');
    
    return User(
      id: id,
      email: email,
      role: role,
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, email, role, name];
}
