import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final String? fileUrl;
  final DateTime timestamp;
  final bool isSentByMe;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl,
    required this.timestamp,
    required this.isSentByMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['senderId'] as String? ?? '';
    return Message(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      senderId: senderId,
      content: json['content'] as String? ?? '',
      messageType: json['messageType'] as String? ?? 'text',
      fileUrl: json['fileUrl'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isSentByMe: senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'messageType': messageType,
      'fileUrl': fileUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        content,
        messageType,
        fileUrl,
        timestamp,
        isSentByMe,
      ];
}
