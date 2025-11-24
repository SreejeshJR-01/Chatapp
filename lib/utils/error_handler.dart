import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Centralized error handling utility for the application
class ErrorHandler {
  /// Parse and format error messages for user display
  static String getUserFriendlyMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (error is http.ClientException) {
      return 'Network error. Please check your connection and try again.';
    }
    
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    
    if (error is FormatException) {
      return 'Invalid data format received from server.';
    }
    
    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      
      // Check for specific error patterns
      if (message.toLowerCase().contains('network')) {
        return 'Network error. Please check your connection.';
      }
      
      if (message.toLowerCase().contains('timeout')) {
        return 'Request timed out. Please try again.';
      }
      
      if (message.toLowerCase().contains('server error')) {
        return 'Server is experiencing issues. Please try again later.';
      }
      
      if (message.toLowerCase().contains('invalid credentials')) {
        return 'Invalid email or password. Please try again.';
      }
      
      if (message.toLowerCase().contains('unauthorized') || 
          message.toLowerCase().contains('401')) {
        return 'Session expired. Please login again.';
      }
      
      if (message.toLowerCase().contains('forbidden') || 
          message.toLowerCase().contains('403')) {
        return 'You don\'t have permission to perform this action.';
      }
      
      if (message.toLowerCase().contains('not found') || 
          message.toLowerCase().contains('404')) {
        return 'Requested resource not found.';
      }
      
      // Return the original message if no pattern matches
      return message.isNotEmpty ? message : 'An unexpected error occurred.';
    }
    
    // For unknown error types
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Log error for debugging purposes
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    // In production, this would send to a logging service
    // For now, we'll use print for debugging
    print('ERROR [$context]: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
  
  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    return error is SocketException || 
           error is http.ClientException ||
           (error is Exception && 
            error.toString().toLowerCase().contains('network'));
  }
  
  /// Check if error is timeout-related
  static bool isTimeoutError(dynamic error) {
    return error is TimeoutException ||
           (error is Exception && 
            error.toString().toLowerCase().contains('timeout'));
  }
  
  /// Check if error requires re-authentication
  static bool requiresReauth(dynamic error) {
    if (error is! Exception) return false;
    
    final message = error.toString().toLowerCase();
    return message.contains('unauthorized') ||
           message.contains('401') ||
           message.contains('session expired') ||
           message.contains('invalid token');
  }
}
