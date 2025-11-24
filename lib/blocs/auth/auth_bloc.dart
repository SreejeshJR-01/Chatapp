import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/authentication_service.dart';
import '../../utils/error_handler.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc for managing authentication state and operations
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticationService _authenticationService;

  AuthBloc({
    required AuthenticationService authenticationService,
  })  : _authenticationService = authenticationService,
        super(const AuthInitial()) {
    // Register event handlers
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  /// Handle login request event
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Attempt to login with provided credentials
      final user = await _authenticationService.login(
        event.email,
        event.password,
        event.role,
      );

      // Save user data to local storage
      await _authenticationService.saveUserData(user);

      // Emit authenticated state with user data
      emit(AuthAuthenticated(user: user));
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('AuthBloc.login', e, stackTrace);
      
      // Emit error state with user-friendly error message
      emit(AuthError(message: ErrorHandler.getUserFriendlyMessage(e)));
    }
  }

  /// Handle logout request event
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Clear stored user data
      await _authenticationService.logout();

      // Emit unauthenticated state
      emit(const AuthUnauthenticated());
    } catch (e, stackTrace) {
      // Log error but still logout
      ErrorHandler.logError('AuthBloc.logout', e, stackTrace);
      
      // Even if logout fails, emit unauthenticated state
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle check authentication status event
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Retrieve stored user data
      final user = await _authenticationService.getCurrentUser();

      if (user != null) {
        // User data exists, emit authenticated state
        emit(AuthAuthenticated(user: user));
      } else {
        // No user data found, emit unauthenticated state
        emit(const AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('AuthBloc.checkAuthStatus', e, stackTrace);
      
      // If error occurs, assume user is not authenticated
      emit(const AuthUnauthenticated());
    }
  }
}
