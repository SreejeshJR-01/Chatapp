# Design Document

## Overview

This document outlines the technical design for a Flutter-based Real-Time Chat Application that connects to an existing Node.js backend API. The application enables Customer and Vendor users to engage in real-time messaging conversations. The design follows MVVM (Model-View-ViewModel) architecture with Bloc for state management, ensuring separation of concerns and testability.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Application                   │
├─────────────────────────────────────────────────────────┤
│  Presentation Layer (Views/Widgets)                     │
│    ├── Login Screen                                     │
│    ├── Chat List Screen                                 │
│    └── Chat Conversation Screen                         │
├─────────────────────────────────────────────────────────┤
│  State Management Layer (Blocs)                         │
│    ├── Auth Bloc                                        │
│    ├── Chat List Bloc                                   │
│    └── Chat Conversation Bloc                           │
├─────────────────────────────────────────────────────────┤
│  Business Logic Layer (Services)                        │
│    ├── Authentication Service                           │
│    ├── Chat Service                                     │
│    ├── Message Service                                  │
│    └── Socket Service                                   │
├─────────────────────────────────────────────────────────┤
│  Data Layer (Models & Repositories)                     │
│    ├── User Model                                       │
│    ├── Chat Model                                       │
│    ├── Message Model                                    │
│    └── Local Storage Repository                         │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              Backend API (Node.js)                       │
│         http://45.129.87.38:6065                        │
│                                                          │
│  REST Endpoints:                                        │
│    - POST /user/login                                   │
│    - GET /chats/user-chats/:userId                      │
│    - GET /messages/get-messagesformobile/:chatId        │
│    - POST /messages/sendMessage                         │
│                                                          │
│  Socket.IO:                                             │
│    - Real-time message delivery                         │
│    - Connection management                              │
└─────────────────────────────────────────────────────────┘
```

### MVVM Pattern Implementation

**Model**: Data structures representing business entities (User, Chat, Message)
**View**: Flutter widgets that display UI and capture user interactions
**ViewModel**: Bloc classes that manage state and coordinate between Views and Services

## Components and Interfaces

### 1. Presentation Layer (Views)

#### Login Screen
- **Purpose**: Authenticate users with role selection
- **Components**:
  - Email input field
  - Password input field
  - Role selector (Customer/Vendor dropdown or radio buttons)
  - Login button
  - Loading indicator
  - Error message display
- **Navigation**: On successful login → Chat List Screen

#### Chat List Screen
- **Purpose**: Display all user conversations
- **Components**:
  - App bar with user info and logout button
  - ListView of chat items
  - Each chat item shows:
    - Other participant's name
    - Last message preview
    - Timestamp
    - Unread indicator (optional)
  - Pull-to-refresh functionality
  - Loading indicator
  - Empty state message
- **Navigation**: On chat tap → Chat Conversation Screen

#### Chat Conversation Screen
- **Purpose**: Display and send messages in a specific conversation
- **Components**:
  - App bar with participant name and back button
  - Message list (scrollable)
  - Message bubbles (sender on right, receiver on left)
  - Timestamp display
  - Message input field
  - Send button
  - File attachment button
  - Connection status indicator
  - Loading indicator for history
  - Auto-scroll to latest message

### 2. State Management Layer (Blocs)

#### Auth Bloc
**States**:
- `AuthInitial`: Initial state
- `AuthLoading`: Login in progress
- `AuthAuthenticated`: User logged in successfully
- `AuthUnauthenticated`: User not logged in
- `AuthError`: Login failed with error message

**Events**:
- `LoginRequested`: Triggered when user submits login
- `LogoutRequested`: Triggered when user logs out
- `CheckAuthStatus`: Check if user is already authenticated

**Responsibilities**:
- Coordinate with Authentication Service
- Manage authentication state
- Store/retrieve user credentials from local storage

#### Chat List Bloc
**States**:
- `ChatListInitial`: Initial state
- `ChatListLoading`: Fetching chat list
- `ChatListLoaded`: Chat list retrieved successfully
- `ChatListError`: Failed to load chats

**Events**:
- `LoadChatList`: Fetch user's chat list
- `RefreshChatList`: Refresh chat list

**Responsibilities**:
- Fetch chat list from Chat Service
- Manage chat list state
- Handle refresh operations

#### Chat Conversation Bloc
**States**:
- `ChatConversationInitial`: Initial state
- `ChatConversationLoading`: Loading message history
- `ChatConversationLoaded`: Messages loaded and ready
- `ChatConversationMessageSending`: Sending a message
- `ChatConversationMessageSent`: Message sent successfully
- `ChatConversationMessageReceived`: New message received via socket
- `ChatConversationError`: Error occurred

**Events**:
- `LoadChatHistory`: Load message history for a chat
- `SendTextMessage`: Send a text message
- `SendFileMessage`: Send a file message
- `ReceiveMessage`: Handle incoming socket message
- `ConnectSocket`: Establish socket connection
- `DisconnectSocket`: Close socket connection

**Responsibilities**:
- Load and display message history
- Send messages via Message Service
- Listen for real-time messages via Socket Service
- Manage socket connection lifecycle
- Update UI with new messages

### 3. Business Logic Layer (Services)

#### Authentication Service
**Interface**:
```dart
class AuthenticationService {
  Future<LoginResponse> login(String email, String password, String role);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> saveUserData(User user);
}
```

**Responsibilities**:
- Make HTTP POST request to /user/login
- Parse login response
- Store user data in local storage
- Retrieve stored user data
- Clear user data on logout

#### Chat Service
**Interface**:
```dart
class ChatService {
  Future<List<Chat>> getUserChats(String userId);
}
```

**Responsibilities**:
- Make HTTP GET request to /chats/user-chats/:userId
- Parse chat list response
- Transform API response to Chat models

#### Message Service
**Interface**:
```dart
class MessageService {
  Future<List<Message>> getChatMessages(String chatId);
  Future<MessageResponse> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    required String messageType,
    String? fileUrl,
  });
}
```

**Responsibilities**:
- Make HTTP GET request to /messages/get-messagesformobile/:chatId
- Make HTTP POST request to /messages/sendMessage
- Parse message responses
- Transform API responses to Message models

#### Socket Service
**Interface**:
```dart
class SocketService {
  void connect();
  void disconnect();
  void emit(String event, dynamic data);
  Stream<Message> onMessageReceived();
  Stream<bool> onConnectionStatusChanged();
}
```

**Responsibilities**:
- Establish Socket.IO connection to backend
- Listen for incoming message events
- Emit message events for real-time delivery
- Manage connection status
- Provide streams for reactive updates
- Handle reconnection logic

### 4. Data Layer

#### Models

**User Model**:
```dart
class User {
  final String id;
  final String email;
  final String role; // 'customer' or 'vendor'
  final String? name;
  
  User({required this.id, required this.email, required this.role, this.name});
  
  factory User.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**Chat Model**:
```dart
class Chat {
  final String id;
  final String participantId;
  final String participantName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  
  Chat({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
  
  factory Chat.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**Message Model**:
```dart
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType; // 'text' or 'file'
  final String? fileUrl;
  final DateTime timestamp;
  final bool isSentByMe;
  
  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl,
    required this.timestamp,
    required this.isSentByMe,
  });
  
  factory Message.fromJson(Map<String, dynamic> json, String currentUserId);
  Map<String, dynamic> toJson();
}
```

**API Response Models**:
```dart
class LoginResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? message;
  
  factory LoginResponse.fromJson(Map<String, dynamic> json);
}

class MessageResponse {
  final bool success;
  final Message? message;
  final String? error;
  
  factory MessageResponse.fromJson(Map<String, dynamic> json);
}
```

#### Local Storage Repository
**Interface**:
```dart
class LocalStorageRepository {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveObject(String key, Map<String, dynamic> object);
  Future<Map<String, dynamic>?> getObject(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
```

**Implementation**: Use `shared_preferences` package

**Responsibilities**:
- Store user authentication data
- Retrieve stored user data
- Clear data on logout

## Data Flow

### Login Flow
```
User enters credentials → LoginRequested event → Auth Bloc
  → Authentication Service.login()
  → HTTP POST to /user/login
  → Parse response
  → Save user data to local storage
  → Emit AuthAuthenticated state
  → Navigate to Chat List Screen
```

### Chat List Flow
```
Chat List Screen loads → LoadChatList event → Chat List Bloc
  → Chat Service.getUserChats()
  → HTTP GET to /chats/user-chats/:userId
  → Parse response to List<Chat>
  → Emit ChatListLoaded state
  → Display chat list in UI
```

### Chat Conversation Flow
```
User opens chat → LoadChatHistory event → Chat Conversation Bloc
  → Message Service.getChatMessages()
  → HTTP GET to /messages/get-messagesformobile/:chatId
  → Parse response to List<Message>
  → ConnectSocket event
  → Socket Service.connect()
  → Listen to onMessageReceived stream
  → Emit ChatConversationLoaded state
  → Display messages in UI
```

### Send Message Flow
```
User sends message → SendTextMessage event → Chat Conversation Bloc
  → Message Service.sendMessage()
  → HTTP POST to /messages/sendMessage
  → Socket Service.emit('message', data)
  → Emit ChatConversationMessageSent state
  → Add message to UI
  → Clear input field
```

### Receive Message Flow
```
Socket receives message → Socket Service emits to stream
  → Chat Conversation Bloc receives from stream
  → ReceiveMessage event
  → Emit ChatConversationMessageReceived state
  → Add message to UI
  → Auto-scroll to bottom
```

## Error Handling

### Network Errors
- **Strategy**: Catch HTTP exceptions and socket connection errors
- **User Feedback**: Display snackbar or dialog with error message
- **Retry Logic**: Provide retry button for failed operations
- **Offline Detection**: Check connectivity before making requests

### Authentication Errors
- **Invalid Credentials**: Display error message on login screen
- **Session Expiry**: Redirect to login screen and clear stored data
- **Authorization Errors**: Handle 401/403 responses appropriately

### Socket Connection Errors
- **Connection Failed**: Display connection status indicator
- **Disconnection**: Attempt automatic reconnection with exponential backoff
- **Message Delivery Failure**: Queue messages and retry when reconnected

### API Response Errors
- **Parse Errors**: Log error and display generic error message
- **Validation Errors**: Display specific field errors from API response
- **Server Errors**: Display user-friendly message and log details

## Testing Strategy

### Unit Tests
- **Models**: Test JSON serialization/deserialization
- **Services**: Mock HTTP client and test API calls
- **Blocs**: Test state transitions for all events
- **Repositories**: Test local storage operations

### Widget Tests
- **Login Screen**: Test input validation and button interactions
- **Chat List Screen**: Test list rendering and navigation
- **Chat Conversation Screen**: Test message display and sending

### Integration Tests
- **Authentication Flow**: Test complete login to chat list navigation
- **Message Flow**: Test sending and receiving messages end-to-end
- **Socket Connection**: Test real-time message delivery

### Test Doubles
- **Mock HTTP Client**: Use `mockito` or `http_mock_adapter`
- **Mock Socket**: Create fake socket service for testing
- **Mock Local Storage**: Use in-memory storage for tests

## Dependencies

### Core Flutter Packages
- `flutter_bloc`: ^8.1.3 - State management
- `equatable`: ^2.0.5 - Value equality for Bloc states

### Networking
- `http`: ^1.1.0 - HTTP requests
- `socket_io_client`: ^2.0.3 - Socket.IO client

### Local Storage
- `shared_preferences`: ^2.2.2 - Persistent key-value storage

### UI Components
- `intl`: ^0.18.1 - Date/time formatting
- `cached_network_image`: ^3.3.0 - Image caching
- `file_picker`: ^6.1.1 - File selection for attachments

### Development
- `flutter_test`: SDK - Testing framework
- `mockito`: ^5.4.4 - Mocking for tests
- `build_runner`: ^2.4.7 - Code generation

## Security Considerations

### Data Storage
- Store user credentials securely using `flutter_secure_storage` if handling sensitive tokens
- Never log sensitive information (passwords, tokens)

### Network Communication
- Use HTTPS for API calls (update base URL if SSL available)
- Validate SSL certificates
- Implement request timeout limits

### Input Validation
- Sanitize user input before sending to API
- Validate email format on client side
- Prevent injection attacks in message content

### Authentication
- Clear all stored data on logout
- Handle token expiry gracefully
- Implement session timeout if required

## Performance Optimization

### Message List
- Use `ListView.builder` for efficient rendering
- Implement pagination for large message histories
- Cache loaded messages in memory

### Image Loading
- Use `cached_network_image` for file attachments
- Implement lazy loading for images
- Compress images before upload

### Socket Connection
- Maintain single socket connection per chat
- Disconnect socket when leaving chat screen
- Implement connection pooling if needed

### State Management
- Use `equatable` to prevent unnecessary rebuilds
- Implement proper state comparison in Blocs
- Dispose Blocs and streams properly

## Deployment Considerations

### Build Configuration
- Configure app name and package identifier
- Set up app icons and splash screen
- Configure minimum SDK versions (Android 21+, iOS 12+)

### Release Build
- Enable code obfuscation
- Remove debug logs
- Optimize asset sizes

### APK Generation
```bash
flutter build apk --release
```

### Testing Checklist
- Test on multiple device sizes
- Test on different Android/iOS versions
- Verify network error handling
- Test offline behavior
- Verify socket reconnection
