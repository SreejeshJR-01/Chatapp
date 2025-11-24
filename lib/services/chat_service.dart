import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/chat.dart';
import '../utils/error_handler.dart';

/// Service for handling chat-related operations
class ChatService {
  // Base URL for the backend API
  static const String baseUrl = 'http://45.129.87.38:6065';
  
  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  final http.Client _httpClient;

  ChatService({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Get all chats for a specific user
  /// 
  /// Fetches chat list from /chats/user-chats/:userId endpoint
  /// Returns [List<Chat>] on success
  /// Throws [Exception] if request fails or network error occurs
  Future<List<Chat>> getUserChats(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/chats/user-chats/$userId');
      print('Fetching chats for user: $userId');
      print('URL: $url');
      
      final response = await _httpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      print('Chat API Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        
        // Handle different response structures
        List<dynamic> chatsJson;
        if (responseBody is Map<String, dynamic>) {
          // If response is wrapped in an object, extract the chats array
          chatsJson = responseBody['chats'] as List<dynamic>? ?? 
                      responseBody['data'] as List<dynamic>? ?? 
                      [];
        } else if (responseBody is List) {
          // If response is directly an array
          chatsJson = responseBody;
        } else {
          throw Exception('Unexpected response format');
        }

        print('Found ${chatsJson.length} chats');
        
        return chatsJson
            .map((chatJson) => Chat.fromJson(chatJson as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        // No chats found, return empty list
        print('No chats found (404)');
        return [];
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          throw Exception(errorBody['message'] ?? 'Failed to load chats');
        } catch (_) {
          throw Exception('Failed to load chats');
        }
      }
    } on TimeoutException catch (e, stackTrace) {
      ErrorHandler.logError('ChatService.getUserChats', e, stackTrace);
      rethrow;
    } on http.ClientException catch (e, stackTrace) {
      ErrorHandler.logError('ChatService.getUserChats', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      ErrorHandler.logError('ChatService.getUserChats', e, stackTrace);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
