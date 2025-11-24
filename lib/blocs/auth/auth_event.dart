import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user requests to login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;

  const LoginRequested({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

/// Event triggered when user requests to logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event triggered to check if user is already authenticated
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
