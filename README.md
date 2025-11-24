# Real-Time Chat Application

A Flutter-based real-time chat application that enables messaging between Customers and Vendors. The application features role-based authentication, real-time message delivery via Socket.IO, and file sharing capabilities.

## Features

- **Role-Based Authentication**: Login as Customer or Vendor
- **Real-Time Messaging**: Instant message delivery using Socket.IO
- **Chat List**: View all conversations with last message preview
- **Message History**: Load and display complete chat history
- **File Sharing**: Send and receive images and documents
- **Persistent Authentication**: Auto-login on app restart
- **Connection Status**: Visual indicator for socket connection status
- **Error Handling**: Comprehensive error handling with user-friendly messages

## Architecture

The application follows **MVVM (Model-View-ViewModel)** architecture with **BLoC** pattern for state management:

```
lib/
├── blocs/              # BLoC state management
│   ├── auth/          # Authentication bloc
│   ├── chat_list/     # Chat list bloc
│   └── chat_conversation/  # Chat conversation bloc
├── models/            # Data models
│   ├── user.dart
│   ├── chat.dart
│   ├── message.dart
│   └── response models
├── services/          # Business logic layer
│   ├── authentication_service.dart
│   ├── chat_service.dart
│   ├── message_service.dart
│   └── socket_service.dart
├── repositories/      # Data persistence
│   └── local_storage_repository.dart
├── views/            # UI screens
│   ├── login_screen.dart
│   ├── chat_list_screen.dart
│   └── chat_conversation_screen.dart
├── widgets/          # Reusable UI components
└── utils/            # Helper utilities
```

## Dependencies

### Core Dependencies
- **flutter_bloc**: ^8.1.3 - State management
- **equatable**: ^2.0.5 - Value equality for models

### Networking
- **http**: ^1.1.0 - HTTP requests
- **socket_io_client**: ^2.0.3 - Real-time communication

### Storage
- **shared_preferences**: ^2.2.2 - Local data persistence

### UI Components
- **intl**: ^0.18.1 - Date/time formatting
- **cached_network_image**: ^3.3.0 - Image caching
- **file_picker**: ^6.1.1 - File selection
- **url_launcher**: ^6.2.5 - Open URLs
- **shimmer**: ^3.0.0 - Loading animations

### Development Dependencies
- **flutter_test**: SDK - Testing framework
- **mockito**: ^5.4.4 - Mocking for tests
- **build_runner**: ^2.4.7 - Code generation
- **bloc_test**: ^9.1.5 - BLoC testing utilities
- **flutter_lints**: ^5.0.0 - Linting rules

## API Endpoints

**Base URL**: `http://45.129.87.38:6065`

### Authentication
- `POST /user/login` - User login
  - Body: `{ email, password, role }`
  - Response: `{ success, user, token, message }`

### Chats
- `GET /chats/user-chats/:userId` - Get user's chat list
  - Response: Array of chat objects

### Messages
- `GET /messages/get-messagesformobile/:chatId` - Get chat messages
  - Response: Array of message objects
- `POST /messages/sendMessage` - Send a message
  - Body: `{ chatId, senderId, content, messageType, fileUrl? }`
  - Response: `{ success, message, error? }`

### Socket.IO Events
- **Connection**: Establishes real-time connection
- **message/newMessage**: Receives incoming messages
- **emit**: Sends messages for real-time delivery

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development on macOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd newpro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate mock files for testing** (optional)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Running Tests

Run all tests:
```bash
flutter test
```

Run specific test suites:
```bash
# Model tests
flutter test test/models/

# Service tests
flutter test test/services/

# BLoC tests
flutter test test/blocs/
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Build Instructions

### Android APK

**Debug Build**:
```bash
flutter build apk --debug
```

**Release Build**:
```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Build

```bash
flutter build ios --release
```

Note: iOS builds require a macOS machine with Xcode installed.

## Configuration

### App Configuration
- **App Name**: Update in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`
- **Package Name**: Update in `android/app/build.gradle` and `ios/Runner.xcodeproj`
- **Version**: Update in `pubspec.yaml`

### API Configuration
The base URL is configured in service files:
- `lib/services/authentication_service.dart`
- `lib/services/chat_service.dart`
- `lib/services/message_service.dart`

To change the API endpoint, update the `baseUrl` constant in these files.

## Usage

### Login
1. Launch the app
2. Select role (Customer or Vendor)
3. Enter email and password
4. Tap "Login"

### View Chats
- After login, you'll see a list of all your conversations
- Pull down to refresh the chat list
- Tap on a chat to open the conversation

### Send Messages
1. Open a chat conversation
2. Type your message in the input field
3. Tap the send button
4. Or tap the attachment icon to send files

### Logout
- Tap the logout icon in the app bar on the chat list screen

## Testing

The application includes comprehensive unit tests:

### Model Tests
- JSON serialization/deserialization
- Model equality checks
- Field validation

### Service Tests
- HTTP request/response handling
- Error handling
- Mock API responses

### BLoC Tests
- State transitions
- Event handling
- Service integration

## Troubleshooting

### Common Issues

**1. Build Errors**
```bash
flutter clean
flutter pub get
flutter run
```

**2. Plugin Issues**
```bash
flutter pub upgrade
```

**3. Socket Connection Issues**
- Check network connectivity
- Verify API base URL is correct
- Check firewall settings

**4. File Picker Issues on Android**
- Ensure proper permissions in AndroidManifest.xml
- Check Android SDK version compatibility

## Project Structure Details

### State Management
The app uses BLoC pattern with three main blocs:
- **AuthBloc**: Manages authentication state
- **ChatListBloc**: Manages chat list state
- **ChatConversationBloc**: Manages individual chat state

### Data Flow
1. User interacts with View
2. View dispatches Event to BLoC
3. BLoC calls Service
4. Service makes API call or socket operation
5. BLoC emits new State
6. View rebuilds based on new State

### Error Handling
- Network errors are caught and displayed to users
- Socket disconnections trigger automatic reconnection
- All errors are logged for debugging

## Performance Optimizations

- Message caching to reduce API calls
- Image caching with `cached_network_image`
- Efficient list rendering with `ListView.builder`
- Proper disposal of streams and controllers
- Lazy loading of images

## Security Considerations

- User credentials stored securely in SharedPreferences
- No sensitive data logged in production
- Input validation on all user inputs
- Proper error message sanitization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## License

This project is private and proprietary.

## Support

For issues and questions, please contact the development team.

---

**Version**: 1.0.0+1  
**Flutter Version**: 3.9.2  
**Last Updated**: 2024
