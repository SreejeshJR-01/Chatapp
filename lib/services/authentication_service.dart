import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/login_response.dart';
import '../repositories/local_storage_repository.dart';
import '../utils/error_handler.dart';

/// Service for handling user authentication operations
class AuthenticationService {
  // Base URL for the backend API
  static const String baseUrl = 'http://45.129.87.38:6065';
  
  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  final http.Client _httpClient;
  final LocalStorageRepository _localStorageRepository;

  AuthenticationService({
    http.Client? httpClient,
    LocalStorageRepository? localStorageRepository,
  })  : _httpClient = httpClient ?? http.Client(),
        _localStorageRepository = localStorageRepository ?? LocalStorageRepository();

  /// Login user with email, password, and role
  /// 
  /// Throws [Exception] if login fails or network error occurs
  /// Returns [User] object on successful authentication
  Future<User> login(String email, String password, String role) async {
    try {
      final url = Uri.parse('$baseUrl/user/login');
      
      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'role': role,
        }),
      ).timeout(
        requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Login response data: $responseData');
        
        // Handle different response formats
        Map<String, dynamic> responseMap;
        if (responseData is Map<String, dynamic>) {
          responseMap = responseData;
          
          // Check if data is nested inside a 'data' field
          if (responseMap.containsKey('data') && responseMap['data'] is Map) {
            responseMap = responseMap['data'] as Map<String, dynamic>;
            print('Extracted data from nested structure');
          }
        } else {
          throw Exception('Unexpected response format');
        }
        
        print('Response map: $responseMap');
        
        // Extract user data directly if it exists
        if (responseMap.containsKey('user') && responseMap['user'] is Map) {
          final userData = responseMap['user'] as Map<String, dynamic>;
          print('User data before parsing: $userData');
          
          final user = User.fromJson(userData);
          print('User after parsing: id=${user.id}, email=${user.email}, role=${user.role}');
          
          // Validate that we got valid user data
          if (user.id.isNotEmpty && user.email.isNotEmpty) {
            return user;
          } else {
            throw Exception('Invalid user data received from server: id=${user.id}, email=${user.email}');
          }
        } else {
          throw Exception('No user data in response');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          throw Exception(errorBody['message'] ?? 'Login failed');
        } catch (_) {
          throw Exception('Login failed');
        }
      }
    } on TimeoutException catch (e, stackTrace) {
      ErrorHandler.logError('AuthenticationService.login', e, stackTrace);
      rethrow;
    } on http.ClientException catch (e, stackTrace) {
      ErrorHandler.logError('AuthenticationService.login', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthenticationService.login', e, stackTrace);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Save user data to local storage
  /// 
  /// Stores user ID, email, role, and name in SharedPreferences
  Future<void> saveUserData(User user) async {
    try {
      await _localStorageRepository.saveString(
        LocalStorageRepository.USER_ID,
        user.id,
      );
      await _localStorageRepository.saveString(
        LocalStorageRepository.USER_EMAIL,
        user.email,
      );
      await _localStorageRepository.saveString(
        LocalStorageRepository.USER_ROLE,
        user.role,
      );
      if (user.name != null) {
        await _localStorageRepository.saveString(
          LocalStorageRepository.USER_NAME,
          user.name!,
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthenticationService.saveUserData', e, stackTrace);
      throw Exception('Failed to save user data');
    }
  }

  /// Retrieve current user data from local storage
  /// 
  /// Returns [User] object if data exists, null otherwise
  Future<User?> getCurrentUser() async {
    try {
      final userId = await _localStorageRepository.getString(
        LocalStorageRepository.USER_ID,
      );
      final userEmail = await _localStorageRepository.getString(
        LocalStorageRepository.USER_EMAIL,
      );
      final userRole = await _localStorageRepository.getString(
        LocalStorageRepository.USER_ROLE,
      );

      if (userId == null || userEmail == null || userRole == null) {
        return null;
      }

      final userName = await _localStorageRepository.getString(
        LocalStorageRepository.USER_NAME,
      );

      return User(
        id: userId,
        email: userEmail,
        role: userRole,
        name: userName,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthenticationService.getCurrentUser', e, stackTrace);
      return null;
    }
  }

  /// Logout user and clear all stored data
  /// 
  /// Removes all user-related data from local storage
  Future<void> logout() async {
    try {
      await _localStorageRepository.remove(LocalStorageRepository.USER_ID);
      await _localStorageRepository.remove(LocalStorageRepository.USER_EMAIL);
      await _localStorageRepository.remove(LocalStorageRepository.USER_ROLE);
      await _localStorageRepository.remove(LocalStorageRepository.USER_NAME);
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthenticationService.logout', e, stackTrace);
      // Don't throw error on logout failure - best effort
    }
  }
}
