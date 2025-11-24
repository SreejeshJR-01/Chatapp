import 'package:equatable/equatable.dart';
import 'message.dart';

class MessageResponse extends Equatable {
  final bool success;
  final Message? message;
  final String? error;

  const MessageResponse({
    required this.success,
    this.message,
    this.error,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Check if response has a 'success' field (wrapped response)
    if (json.containsKey('success')) {
      return MessageResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] != null 
            ? Message.fromJson(json['message'] as Map<String, dynamic>, currentUserId)
            : null,
        error: json['error'] as String?,
      );
    }
    
    // Otherwise, the response is the message object itself
    return MessageResponse(
      success: true,
      message: Message.fromJson(json, currentUserId),
      error: null,
    );
  }

  @override
  List<Object?> get props => [success, message, error];
}
