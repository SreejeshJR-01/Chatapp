import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/message_response.dart';
import '../utils/error_handler.dart';

/// Service for handling message-related operations
class MessageService {
  // Base URL for the backend API
  static const String baseUrl = 'http://45.129.87.38:6065';
  
  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  final http.Client _httpClient;

  MessageService({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Get all messages for a specific chat
  /// 
  /// Fetches message history from /messages/get-messagesformobile/:chatId endpoint
  /// Returns [List<Message>] on success
  /// Throws [Exception] if request fails or network error occurs
  Future<List<Message>> getChatMessages(String chatId, String currentUserId) async {
    try {
      final url = Uri.parse('$baseUrl/messages/get-messagesformobile/$chatId');
      
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

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        
        // Handle different response structures
        List<dynamic> messagesJson;
        if (responseBody is Map<String, dynamic>) {
          // If response is wrapped in an object, extract the messages array
          messagesJson = responseBody['messages'] as List<dynamic>? ?? 
                        responseBody['data'] as List<dynamic>? ?? 
                        [];
        } else if (responseBody is List) {
          // If response is directly an array
          messagesJson = responseBody;
        } else {
          throw Exception('Unexpected response format');
        }

        return messagesJson
            .map((messageJson) => Message.fromJson(
                  messageJson as Map<String, dynamic>,
                  currentUserId,
                ))
            .toList();
      } else if (response.statusCode == 404) {
        // No messages found, return empty list
        return [];
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          throw Exception(errorBody['message'] ?? 'Failed to load messages');
        } catch (_) {
          throw Exception('Failed to load messages');
        }
      }
    } on TimeoutException catch (e, stackTrace) {
      ErrorHandler.logError('MessageService.getChatMessages', e, stackTrace);
      rethrow;
    } on http.ClientException catch (e, stackTrace) {
      ErrorHandler.logError('MessageService.getChatMessages', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      ErrorHandler.logError('MessageService.getChatMessages', e, stackTrace);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Send a message to a chat
  /// 
  /// Posts message to /messages/sendMessage endpoint
  /// Returns [MessageResponse] on success
  /// Throws [Exception] if request fails or network error occurs
  Future<MessageResponse> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    required String messageType,
    String? fileUrl,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/messages/sendMessage');
      
      final body = {
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'messageType': messageType,
        'fileUrl': fileUrl ?? '', // Always include fileUrl, use empty string if null
      };

      print('Sending message with body: ${json.encode(body)}');
      
      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).timeout(
        requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      print('Send message response status: ${response.statusCode}');
      print('Send message response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        return MessageResponse.fromJson(responseBody, senderId);
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          throw Exception(errorBody['message'] ?? 'Failed to send message');
        } catch (_) {
          throw Exception('Failed to send message');
        }
      }
    } on TimeoutException catch (e, stackTrace) {
      ErrorHandler.logError('MessageService.sendMessage', e, stackTrace);
      rethrow;
    } on http.ClientException catch (e, stackTrace) {
      ErrorHandler.logError('MessageService.sendMessage', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      ErrorHandler.logError('MessageService.sendMessage', e, stackTrace);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
