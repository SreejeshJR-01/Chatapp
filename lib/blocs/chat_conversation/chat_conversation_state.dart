import 'package:equatable/equatable.dart';
import '../../models/message.dart';
import '../../services/socket_service.dart';

/// Base class for all chat conversation states
abstract class ChatConversationState extends Equatable {
  const ChatConversationState();

  @override
  List<Object?> get props => [];
}

/// Initial state when chat conversation has not been loaded yet
class ChatConversationInitial extends ChatConversationState {
  const ChatConversationInitial();
}

/// State when chat conversation is being loaded
class ChatConversationLoading extends ChatConversationState {
  const ChatConversationLoading();
}

/// State when chat conversation has been successfully loaded
class ChatConversationLoaded extends ChatConversationState {
  final List<Message> messages;
  final ConnectionStatus connectionStatus;

  const ChatConversationLoaded({
    required this.messages,
    this.connectionStatus = ConnectionStatus.disconnected,
  });

  @override
  List<Object?> get props => [messages, connectionStatus];

  /// Create a copy of this state with updated fields
  ChatConversationLoaded copyWith({
    List<Message>? messages,
    ConnectionStatus? connectionStatus,
  }) {
    return ChatConversationLoaded(
      messages: messages ?? this.messages,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}

/// State when a message is being sent
class ChatConversationMessageSending extends ChatConversationState {
  final List<Message> messages;
  final ConnectionStatus connectionStatus;

  const ChatConversationMessageSending({
    required this.messages,
    this.connectionStatus = ConnectionStatus.disconnected,
  });

  @override
  List<Object?> get props => [messages, connectionStatus];
}

/// State when a message has been sent successfully
class ChatConversationMessageSent extends ChatConversationState {
  final List<Message> messages;
  final ConnectionStatus connectionStatus;

  const ChatConversationMessageSent({
    required this.messages,
    this.connectionStatus = ConnectionStatus.disconnected,
  });

  @override
  List<Object?> get props => [messages, connectionStatus];
}

/// State when a new message is received
class ChatConversationMessageReceived extends ChatConversationState {
  final List<Message> messages;
  final ConnectionStatus connectionStatus;

  const ChatConversationMessageReceived({
    required this.messages,
    this.connectionStatus = ConnectionStatus.disconnected,
  });

  @override
  List<Object?> get props => [messages, connectionStatus];
}

/// State when chat conversation operation fails
class ChatConversationError extends ChatConversationState {
  final String message;
  final List<Message> messages;

  const ChatConversationError({
    required this.message,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [message, messages];
}
