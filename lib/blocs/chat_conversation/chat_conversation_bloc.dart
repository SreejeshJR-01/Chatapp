import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/message_service.dart';
import '../../services/socket_service.dart';
import '../../models/message.dart';
import '../../utils/error_handler.dart';
import '../../utils/message_cache.dart';
import 'chat_conversation_event.dart';
import 'chat_conversation_state.dart';

/// Bloc for managing chat conversation state and operations
class ChatConversationBloc
    extends Bloc<ChatConversationEvent, ChatConversationState> {
  final MessageService _messageService;
  final SocketService _socketService;
  final MessageCache _messageCache = MessageCache();

  // Subscriptions for socket streams
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<ConnectionStatus>? _connectionSubscription;

  // Current state data
  List<Message> _messages = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String? _currentChatId;

  ChatConversationBloc({
    required MessageService messageService,
    required SocketService socketService,
  }) : _messageService = messageService,
       _socketService = socketService,
       super(const ChatConversationInitial()) {
    // Register event handlers
    on<LoadChatHistory>(_onLoadChatHistory);
    on<ConnectSocket>(_onConnectSocket);
    on<DisconnectSocket>(_onDisconnectSocket);
    on<SendTextMessage>(_onSendTextMessage);
    on<SendFileMessage>(_onSendFileMessage);
    on<ReceiveMessage>(_onReceiveMessage);
  }

  /// Handle load chat history event
  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatConversationState> emit,
  ) async {
    emit(const ChatConversationLoading());

    _currentChatId = event.chatId;

    try {
      // Try to get cached messages first
      final cachedMessages = _messageCache.getCachedMessages(event.chatId);

      if (cachedMessages != null && cachedMessages.isNotEmpty) {
        // Use cached messages
        _messages = cachedMessages;

        // Emit loaded state with cached messages
        emit(
          ChatConversationLoaded(
            messages: _messages,
            connectionStatus: _connectionStatus,
          ),
        );

        // Fetch fresh data in background to update cache
        _fetchAndUpdateMessages(event.chatId, event.currentUserId);
      } else {
        // No cache, fetch from service
        final messages = await _messageService.getChatMessages(
          event.chatId,
          event.currentUserId,
        );

        // Sort messages by timestamp in chronological order
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Update internal state and cache
        _messages = messages;
        _messageCache.cacheMessages(event.chatId, messages);

        // Emit loaded state with message list
        emit(
          ChatConversationLoaded(
            messages: _messages,
            connectionStatus: _connectionStatus,
          ),
        );
      }
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError(
        'ChatConversationBloc.loadChatHistory',
        e,
        stackTrace,
      );

      // Emit error state with user-friendly error message
      emit(
        ChatConversationError(
          message: ErrorHandler.getUserFriendlyMessage(e),
          messages: _messages,
        ),
      );
    }
  }

  /// Fetch and update messages in background
  Future<void> _fetchAndUpdateMessages(
    String chatId,
    String currentUserId,
  ) async {
    try {
      final messages = await _messageService.getChatMessages(
        chatId,
        currentUserId,
      );

      // Sort messages by timestamp
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Update cache only (don't emit state in background)
      _messageCache.cacheMessages(chatId, messages);
    } catch (e, stackTrace) {
      // Log error but don't emit error state (background update)
      ErrorHandler.logError(
        'ChatConversationBloc._fetchAndUpdateMessages',
        e,
        stackTrace,
      );
    }
  }

  /// Handle connect socket event
  Future<void> _onConnectSocket(
    ConnectSocket event,
    Emitter<ChatConversationState> emit,
  ) async {
    try {
      // Connect to socket service
      _socketService.connect(event.userId);

      // Subscribe to message received stream
      _messageSubscription = _socketService.messageReceived.listen((message) {
        // Add ReceiveMessage event when new message arrives
        add(ReceiveMessage(message: message));
      });

      // Subscribe to connection status stream
      _connectionSubscription = _socketService.connectionStatus.listen((
        connectionStatus,
      ) {
        _connectionStatus = connectionStatus;
        // Note: We update the internal state but don't emit here
        // The connection status will be reflected in the next state emission
      });
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError(
        'ChatConversationBloc.connectSocket',
        e,
        stackTrace,
      );

      // If socket connection fails, continue with current state
      // The connection status stream will handle reconnection
    }
  }

  /// Handle disconnect socket event
  Future<void> _onDisconnectSocket(
    DisconnectSocket event,
    Emitter<ChatConversationState> emit,
  ) async {
    // Cancel subscriptions
    await _messageSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _messageSubscription = null;
    _connectionSubscription = null;

    // Disconnect from socket service
    _socketService.disconnect();

    // Update connection status
    _connectionStatus = ConnectionStatus.disconnected;

    // Update state if currently loaded
    if (state is ChatConversationLoaded) {
      emit(
        (state as ChatConversationLoaded).copyWith(
          connectionStatus: ConnectionStatus.disconnected,
        ),
      );
    }
  }

  /// Handle send text message event
  Future<void> _onSendTextMessage(
    SendTextMessage event,
    Emitter<ChatConversationState> emit,
  ) async {
    // Emit sending state
    emit(
      ChatConversationMessageSending(
        messages: _messages,
        connectionStatus: _connectionStatus,
      ),
    );

    try {
      // Send message through the service
      final response = await _messageService.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        content: event.content,
        messageType: 'text',
      );

      // If message was sent successfully and we have the message object
      if (response.success && response.message != null) {
        // Add the sent message to the list
        _messages = [..._messages, response.message!];

        // Sort messages by timestamp
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Update cache
        if (_currentChatId != null) {
          _messageCache.cacheMessages(_currentChatId!, _messages);
        }

        // Emit message through socket for real-time delivery
        _socketService.emit('message', response.message!.toJson());

        // Emit message sent state
        emit(
          ChatConversationMessageSent(
            messages: _messages,
            connectionStatus: _connectionStatus,
          ),
        );

        // Return to loaded state
        emit(
          ChatConversationLoaded(
            messages: _messages,
            connectionStatus: _connectionStatus,
          ),
        );
      } else {
        throw Exception(response.error ?? 'Failed to send message');
      }
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError(
        'ChatConversationBloc.sendTextMessage',
        e,
        stackTrace,
      );

      // Emit error state with user-friendly error message
      emit(
        ChatConversationError(
          message: ErrorHandler.getUserFriendlyMessage(e),
          messages: _messages,
        ),
      );

      // Return to loaded state after error
      emit(
        ChatConversationLoaded(
          messages: _messages,
          connectionStatus: _connectionStatus,
        ),
      );
    }
  }

  /// Handle send file message event
  Future<void> _onSendFileMessage(
    SendFileMessage event,
    Emitter<ChatConversationState> emit,
  ) async {
    // Emit sending state
    emit(
      ChatConversationMessageSending(
        messages: _messages,
        connectionStatus: _connectionStatus,
      ),
    );

    try {
      // Send file message through the service
      final response = await _messageService.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        content: event.content,
        messageType: 'file',
        fileUrl: event.fileUrl,
      );

      // If message was sent successfully and we have the message object
      if (response.success && response.message != null) {
        // Add the sent message to the list
        _messages = [..._messages, response.message!];

        // Sort messages by timestamp
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Update cache
        if (_currentChatId != null) {
          _messageCache.cacheMessages(_currentChatId!, _messages);
        }

        // Emit message through socket for real-time delivery
        _socketService.emit('message', response.message!.toJson());

        // Emit message sent state
        emit(
          ChatConversationMessageSent(
            messages: _messages,
            connectionStatus: _connectionStatus,
          ),
        );

        // Return to loaded state
        emit(
          ChatConversationLoaded(
            messages: _messages,
            connectionStatus: _connectionStatus,
          ),
        );
      } else {
        throw Exception(response.error ?? 'Failed to send file message');
      }
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError(
        'ChatConversationBloc.sendFileMessage',
        e,
        stackTrace,
      );

      // Emit error state with user-friendly error message
      emit(
        ChatConversationError(
          message: ErrorHandler.getUserFriendlyMessage(e),
          messages: _messages,
        ),
      );

      // Return to loaded state after error
      emit(
        ChatConversationLoaded(
          messages: _messages,
          connectionStatus: _connectionStatus,
        ),
      );
    }
  }

  /// Handle receive message event
  Future<void> _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ChatConversationState> emit,
  ) async {
    // Check if message already exists (avoid duplicates)
    final messageExists = _messages.any((m) => m.id == event.message.id);

    if (!messageExists) {
      // Add the received message to the list
      _messages = [..._messages, event.message];

      // Sort messages by timestamp to maintain chronological order
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Update cache
      if (_currentChatId != null) {
        _messageCache.cacheMessages(_currentChatId!, _messages);
      }

      // Emit message received state
      emit(
        ChatConversationMessageReceived(
          messages: _messages,
          connectionStatus: _connectionStatus,
        ),
      );

      // Return to loaded state
      emit(
        ChatConversationLoaded(
          messages: _messages,
          connectionStatus: _connectionStatus,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    // Clean up subscriptions
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}
