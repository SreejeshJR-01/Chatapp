import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';
import '../utils/error_handler.dart';

/// Connection status enum
enum ConnectionStatus {
  connected,
  disconnected,
  reconnecting,
}

/// Service for handling Socket.IO real-time communication
class SocketService {
  // Base URL for the backend API
  static const String baseUrl = 'http://45.129.87.38:6065';
  
  IO.Socket? _socket;
  String? _currentUserId;
  
  // Stream controllers for reactive updates
  final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<Message> _messageReceivedController = 
      StreamController<Message>.broadcast();
  
  // Reconnection configuration
  static const int _maxReconnectAttempts = 5;
  static const int _initialReconnectDelay = 1000; // 1 second
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _isManualDisconnect = false;

  /// Get connection status stream
  Stream<ConnectionStatus> get connectionStatus => _connectionStatusController.stream;
  
  /// Get message received stream
  Stream<Message> get messageReceived => _messageReceivedController.stream;
  
  /// Check if socket is currently connected
  bool get isConnected => _socket?.connected ?? false;

  /// Connect to Socket.IO server
  /// 
  /// Establishes socket connection with the backend
  /// [userId] is required to parse incoming messages correctly
  void connect(String userId) {
    _currentUserId = userId;
    _isManualDisconnect = false;
    
    // Disconnect existing socket if any
    if (_socket != null) {
      _socket!.dispose();
    }

    // Initialize socket with configuration
    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use websocket transport
          .enableAutoConnect() // Auto connect on initialization
          .enableReconnection() // Enable reconnection
          .setReconnectionAttempts(_maxReconnectAttempts)
          .setReconnectionDelay(_initialReconnectDelay)
          .build(),
    );

    // Set up event listeners
    _setupEventListeners();
    
    // Connect the socket
    _socket!.connect();
  }

  /// Set up socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection established
    _socket!.on('connect', (_) {
      ErrorHandler.logError('SocketService', 'Socket connected');
      _reconnectAttempts = 0;
      _connectionStatusController.add(ConnectionStatus.connected);
    });

    // Connection error
    _socket!.on('connect_error', (error) {
      ErrorHandler.logError('SocketService', 'Socket connection error: $error');
      _connectionStatusController.add(ConnectionStatus.disconnected);
    });

    // Disconnected
    _socket!.on('disconnect', (_) {
      ErrorHandler.logError('SocketService', 'Socket disconnected');
      _connectionStatusController.add(ConnectionStatus.disconnected);
      
      // Attempt manual reconnection if not intentionally disconnected
      if (!_isManualDisconnect) {
        _connectionStatusController.add(ConnectionStatus.reconnecting);
        _attemptReconnection();
      }
    });

    // Reconnection attempt
    _socket!.on('reconnect_attempt', (attempt) {
      ErrorHandler.logError('SocketService', 'Socket reconnection attempt: $attempt');
      _connectionStatusController.add(ConnectionStatus.reconnecting);
    });

    // Reconnection failed
    _socket!.on('reconnect_failed', (_) {
      ErrorHandler.logError('SocketService', 'Socket reconnection failed');
      _connectionStatusController.add(ConnectionStatus.disconnected);
    });

    // Reconnected successfully
    _socket!.on('reconnect', (attempt) {
      ErrorHandler.logError('SocketService', 'Socket reconnected after $attempt attempts');
      _reconnectAttempts = 0;
      _connectionStatusController.add(ConnectionStatus.connected);
    });

    // Listen for incoming messages
    // Try both 'message' and 'newMessage' events as backend may use either
    _socket!.on('message', (data) {
      _handleIncomingMessage(data);
    });

    _socket!.on('newMessage', (data) {
      _handleIncomingMessage(data);
    });
  }

  /// Handle incoming message from socket
  void _handleIncomingMessage(dynamic data) {
    try {
      if (data == null) return;
      
      // Parse the incoming message data
      Map<String, dynamic> messageJson;
      if (data is Map<String, dynamic>) {
        messageJson = data;
      } else if (data is String) {
        // If data is a string, it might be JSON encoded
        messageJson = {'content': data};
      } else {
        ErrorHandler.logError('SocketService', 'Unexpected message format: $data');
        return;
      }

      // Create Message object and emit to stream
      if (_currentUserId != null) {
        final message = Message.fromJson(messageJson, _currentUserId!);
        _messageReceivedController.add(message);
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('SocketService._handleIncomingMessage', e, stackTrace);
    }
  }

  /// Emit a message through the socket
  /// 
  /// Sends message data to the server via socket event
  /// [event] is the event name (default: 'message')
  /// [data] is the message data to send
  void emit(String event, dynamic data) {
    try {
      if (_socket != null && _socket!.connected) {
        _socket!.emit(event, data);
      } else {
        ErrorHandler.logError('SocketService', 'Cannot emit: Socket not connected');
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('SocketService.emit', e, stackTrace);
    }
  }

  /// Disconnect from Socket.IO server
  /// 
  /// Closes the socket connection and cleans up resources
  void disconnect() {
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    _connectionStatusController.add(ConnectionStatus.disconnected);
  }

  /// Dispose resources
  /// 
  /// Closes all streams and disconnects socket
  void dispose() {
    disconnect();
    _connectionStatusController.close();
    _messageReceivedController.close();
  }

  /// Attempt reconnection with exponential backoff
  void _attemptReconnection() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      ErrorHandler.logError('SocketService', 'Max reconnection attempts reached');
      _connectionStatusController.add(ConnectionStatus.disconnected);
      return;
    }

    // Calculate delay with exponential backoff
    final delay = _initialReconnectDelay * (1 << _reconnectAttempts);
    _reconnectAttempts++;

    ErrorHandler.logError('SocketService', 'Attempting reconnection in ${delay}ms (attempt $_reconnectAttempts)');
    _connectionStatusController.add(ConnectionStatus.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (_socket != null && !_socket!.connected && !_isManualDisconnect) {
        _socket!.connect();
      }
    });
  }
}
