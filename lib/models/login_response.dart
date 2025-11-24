import 'package:equatable/equatable.dart';
import 'user.dart';

class LoginResponse extends Equatable {
  final bool success;
  final User? user;
  final String? token;
  final String? message;

  const LoginResponse({
    required this.success,
    this.user,
    this.token,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle different possible field names for success
    bool success = false;
    if (json.containsKey('success')) {
      success = json['success'] as bool? ?? false;
    } else if (json.containsKey('status')) {
      // Some APIs use 'status' instead of 'success'
      final status = json['status'];
      success = status == true || status == 'success' || status == 'ok';
    }
    
    // Handle different possible locations for user data
    Map<String, dynamic>? userData;
    if (json['user'] != null && json['user'] is Map) {
      userData = json['user'] as Map<String, dynamic>;
    } else if (json['data'] != null && json['data'] is Map) {
      userData = json['data'] as Map<String, dynamic>;
    }
    
    return LoginResponse(
      success: success,
      user: userData != null ? User.fromJson(userData) : null,
      token: json['token'] as String? ?? json['accessToken'] as String?,
      message: json['message'] as String? ?? json['msg'] as String?,
    );
  }

  @override
  List<Object?> get props => [success, user, token, message];
}
