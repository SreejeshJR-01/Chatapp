import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';
import '../utils/error_handler.dart';

/// ViewModel for managing authentication state and operations
/// Follows MVVM pattern with ChangeNotifier for reactive UI updates
class AuthViewModel extends ChangeNotifier {
  final AuthenticationService _authenticationService;

  AuthViewModel({
    required AuthenticationService authenticationService,
  }) : _authenticationService = authenticationService;

  // State properties
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters for state
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  /// Login with email, password and role
  Future<void> login(String email, String password, String role) async {
    _setLoading(true);
    _clearError();

    try {
      // Attempt to login with provided credentials
      final user = await _authenticationService.login(email, password, role);

      // Save user data to local storage
      await _authenticationService.saveUserData(user);

      // Update state
      _user = user;
      _isAuthenticated = true;
      _setLoading(false);
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('AuthViewModel.login', e, stackTrace);

      // Set user-friendly error message
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      _isAuthenticated = false;
      _setLoading(false);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      // Clear stored user data
      await _authenticationService.logout();

      // Update state
      _user = null;
      _isAuthenticated = false;
      _clearError();
      notifyListeners();
    } catch (e, stackTrace) {
      // Log error but still logout
      ErrorHandler.logError('AuthViewModel.logout', e, stackTrace);

      // Even if logout fails, clear local state
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// Check if user is already authenticated (on app start)
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      // Retrieve stored user data
      final user = await _authenticationService.getCurrentUser();

      if (user != null) {
        // User data exists, set authenticated state
        _user = user;
        _isAuthenticated = true;
      } else {
        // No user data found
        _user = null;
        _isAuthenticated = false;
      }
      _setLoading(false);
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('AuthViewModel.checkAuthStatus', e, stackTrace);

      // If error occurs, assume user is not authenticated
      _user = null;
      _isAuthenticated = false;
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
