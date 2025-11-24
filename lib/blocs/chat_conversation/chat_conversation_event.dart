import 'package:equatable/equatable.dart';
import '../../models/message.dart';

/// Base class for all chat conversation events
abstract class ChatConversationEvent extends Equatable {
  const ChatConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load chat history
class LoadChatHistory extends ChatConversationEvent {
  final String chatId;
  final String currentUserId;

  const LoadChatHistory({
    required this.chatId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [chatId, currentUserId];
}

/// Event triggered to send a text message
class SendTextMessage extends ChatConversationEvent {
  final String chatId;
  final String senderId;
  final String content;

  const SendTextMessage({
    required this.chatId,
    required this.senderId,
    required this.content,
  });

  @override
  List<Object?> get props => [chatId, senderId, content];
}

/// Event triggered to send a file message
class SendFileMessage extends ChatConversationEvent {
  final String chatId;
  final String senderId;
  final String fileUrl;
  final String content;

  const SendFileMessage({
    required this.chatId,
    required this.senderId,
    required this.fileUrl,
    required this.content,
  });

  @override
  List<Object?> get props => [chatId, senderId, fileUrl, content];
}

/// Event triggered when a message is received via socket
class ReceiveMessage extends ChatConversationEvent {
  final Message message;

  const ReceiveMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Event triggered to connect to socket
class ConnectSocket extends ChatConversationEvent {
  final String userId;

  const ConnectSocket({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered to disconnect from socket
class DisconnectSocket extends ChatConversationEvent {
  const DisconnectSocket();
}
