# Implementation Plan

- [x] 1. Set up project dependencies and configuration





  - Add required packages to pubspec.yaml: flutter_bloc, equatable, http, socket_io_client, shared_preferences, intl, cached_network_image, file_picker
  - Configure analysis_options.yaml for linting rules
  - Create directory structure: lib/models, lib/services, lib/blocs, lib/views, lib/repositories, lib/utils
  - _Requirements: 9.1, 9.5_

- [x] 2. Implement data models





  - [x] 2.1 Create User model with JSON serialization



    - Define User class with id, email, role, and name properties
    - Implement fromJson and toJson methods
    - _Requirements: 1.2, 1.3, 9.5_
  
  - [x] 2.2 Create Chat model with JSON serialization


    - Define Chat class with id, participantId, participantName, lastMessage, lastMessageTime, unreadCount
    - Implement fromJson and toJson methods
    - _Requirements: 3.2, 3.3, 9.5_
  
  - [x] 2.3 Create Message model with JSON serialization


    - Define Message class with id, chatId, senderId, content, messageType, fileUrl, timestamp, isSentByMe
    - Implement fromJson factory that accepts currentUserId parameter
    - Implement toJson method
    - _Requirements: 4.2, 6.1, 7.1, 8.1, 9.5_
  
  - [x] 2.4 Create API response models


    - Create LoginResponse model with success, user, token, message fields
    - Create MessageResponse model with success, message, error fields
    - Implement fromJson methods for both models
    - _Requirements: 1.2, 6.2, 9.5_

- [x] 3. Implement local storage repository




  - [x] 3.1 Create LocalStorageRepository class


    - Initialize SharedPreferences instance
    - Implement saveString, getString, saveObject, getObject, remove, clear methods
    - Add constants for storage keys (USER_ID, USER_EMAIL, USER_ROLE, USER_NAME)
    - _Requirements: 2.1, 2.2, 2.4, 9.5_

- [x] 4. Implement authentication service






  - [x] 4.1 Create AuthenticationService class

    - Define base URL constant: http://45.129.87.38:6065
    - Implement login method that posts to /user/login with email, password, role
    - Parse LoginResponse and return User object
    - Handle HTTP errors and throw appropriate exceptions
    - _Requirements: 1.1, 1.2, 1.4, 10.1, 10.5_
  
  - [x] 4.2 Add user data persistence methods


    - Implement saveUserData method using LocalStorageRepository
    - Implement getCurrentUser method to retrieve stored user data
    - Implement logout method to clear stored data
    - _Requirements: 1.3, 2.1, 2.2, 2.4_

- [x] 5. Implement chat and message services




  - [x] 5.1 Create ChatService class


    - Implement getUserChats method that gets from /chats/user-chats/:userId
    - Parse response and return List<Chat>
    - Handle HTTP errors appropriately
    - _Requirements: 3.1, 3.2, 10.1, 10.5_


  
  - [x] 5.2 Create MessageService class





    - Implement getChatMessages method that gets from /messages/get-messagesformobile/:chatId
    - Implement sendMessage method that posts to /messages/sendMessage
    - Parse responses and return appropriate models
    - Handle HTTP errors and network issues
    - _Requirements: 4.1, 4.2, 6.1, 6.2, 7.2, 10.1, 10.5_

- [x] 6. Implement Socket.IO service






  - [x] 6.1 Create SocketService class

    - Initialize socket_io_client with base URL
    - Implement connect method to establish socket connection
    - Implement disconnect method to close connection
    - Add connection status stream using StreamController
    - _Requirements: 5.1, 5.2, 5.5, 10.2_
  


  - [x] 6.2 Add message event handling

    - Implement emit method for sending messages
    - Create message received stream using StreamController
    - Listen to socket 'message' or 'newMessage' event
    - Parse incoming messages and emit to stream

    - _Requirements: 5.3, 6.3_
  
  - [x] 6.3 Implement reconnection logic

    - Add automatic reconnection on disconnect
    - Implement exponential backoff for reconnection attempts
    - Update connection status stream on status changes
    - _Requirements: 5.5, 10.2_

- [x] 7. Implement Auth Bloc




  - [x] 7.1 Define Auth states and events


    - Create AuthState classes: AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated, AuthError
    - Create AuthEvent classes: LoginRequested, LogoutRequested, CheckAuthStatus
    - Use equatable for state comparison
    - _Requirements: 9.2_
  
  - [x] 7.2 Implement Auth Bloc logic


    - Create AuthBloc class extending Bloc<AuthEvent, AuthState>
    - Implement event handler for LoginRequested using AuthenticationService
    - Implement event handler for LogoutRequested
    - Implement event handler for CheckAuthStatus to check stored credentials
    - Handle errors and emit appropriate states
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 9.2, 10.1, 10.5_

- [x] 8. Implement Chat List Bloc




  - [x] 8.1 Define Chat List states and events


    - Create ChatListState classes: ChatListInitial, ChatListLoading, ChatListLoaded, ChatListError
    - Create ChatListEvent classes: LoadChatList, RefreshChatList
    - Use equatable for state comparison
    - _Requirements: 9.3_
  
  - [x] 8.2 Implement Chat List Bloc logic


    - Create ChatListBloc class extending Bloc<ChatListEvent, ChatListState>
    - Implement event handler for LoadChatList using ChatService
    - Implement event handler for RefreshChatList
    - Handle errors and emit appropriate states
    - _Requirements: 3.1, 3.2, 9.3, 10.1, 10.5_

- [x] 9. Implement Chat Conversation Bloc




  - [x] 9.1 Define Chat Conversation states and events


    - Create ChatConversationState classes: ChatConversationInitial, ChatConversationLoading, ChatConversationLoaded, ChatConversationMessageSending, ChatConversationMessageSent, ChatConversationMessageReceived, ChatConversationError
    - Create ChatConversationEvent classes: LoadChatHistory, SendTextMessage, SendFileMessage, ReceiveMessage, ConnectSocket, DisconnectSocket
    - Use equatable for state comparison
    - _Requirements: 9.4_
  
  - [x] 9.2 Implement Chat Conversation Bloc logic for loading messages


    - Create ChatConversationBloc class extending Bloc<ChatConversationEvent, ChatConversationState>
    - Implement event handler for LoadChatHistory using MessageService
    - Implement event handler for ConnectSocket using SocketService
    - Implement event handler for DisconnectSocket
    - Subscribe to SocketService message stream and emit ReceiveMessage events
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3, 9.4_
  
  - [x] 9.3 Implement Chat Conversation Bloc logic for sending messages

    - Implement event handler for SendTextMessage using MessageService
    - Implement event handler for SendFileMessage using MessageService
    - Emit message through SocketService for real-time delivery
    - Handle errors and emit appropriate states
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 7.2, 7.3, 9.4, 10.1, 10.5_
  
  - [x] 9.4 Handle incoming messages and socket events

    - Implement event handler for ReceiveMessage to update state with new messages
    - Listen to socket connection status and update state accordingly
    - Maintain message list in chronological order
    - _Requirements: 5.3, 5.4, 8.2, 8.4_

- [x] 10. Create Login Screen UI




  - [x] 10.1 Build login form widgets


    - Create LoginScreen StatefulWidget
    - Add email TextFormField with validation
    - Add password TextFormField with obscureText
    - Add role selector (DropdownButton or RadioButtons for Customer/Vendor)
    - Add login button
    - _Requirements: 1.1, 1.5_
  
  - [x] 10.2 Integrate Auth Bloc with Login Screen


    - Wrap LoginScreen with BlocProvider for AuthBloc
    - Use BlocConsumer to listen to AuthState changes
    - Dispatch LoginRequested event on button press
    - Show loading indicator when AuthLoading state
    - Display error message when AuthError state
    - Navigate to Chat List Screen when AuthAuthenticated state
    - _Requirements: 1.2, 1.3, 1.4, 2.3, 10.5_

- [x] 11. Create Chat List Screen UI





  - [x] 11.1 Build chat list widgets


    - Create ChatListScreen StatefulWidget
    - Add AppBar with title and logout button
    - Create ListView.builder for displaying chats
    - Create ChatListItem widget showing participant name, last message, timestamp
    - Add RefreshIndicator for pull-to-refresh
    - Add empty state widget when no chats
    - _Requirements: 3.2, 3.3, 3.4_
  
  - [x] 11.2 Integrate Chat List Bloc with Chat List Screen


    - Wrap ChatListScreen with BlocProvider for ChatListBloc
    - Dispatch LoadChatList event on screen init
    - Use BlocBuilder to render chat list based on ChatListState
    - Show loading indicator when ChatListLoading state
    - Display error message when ChatListError state
    - Handle chat item tap to navigate to Chat Conversation Screen
    - Implement pull-to-refresh to dispatch RefreshChatList event
    - _Requirements: 3.1, 3.2, 3.5, 10.1, 10.5_
  
  - [x] 11.3 Add logout functionality


    - Add logout IconButton in AppBar
    - Dispatch LogoutRequested event on button press
    - Navigate to Login Screen when AuthUnauthenticated state
    - _Requirements: 2.4_

- [x] 12. Create Chat Conversation Screen UI





  - [x] 12.1 Build message list widgets


    - Create ChatConversationScreen StatefulWidget
    - Add AppBar with participant name and back button
    - Create ListView.builder for displaying messages
    - Create MessageBubble widget with different styles for sender/receiver
    - Display message content and timestamp
    - Add ScrollController for auto-scrolling
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 8.1, 8.2, 8.4_
  
  - [x] 12.2 Build message input widgets


    - Create message input TextField at bottom
    - Add send IconButton
    - Add file attachment IconButton
    - Implement file picker for selecting attachments
    - Clear input field after sending message
    - _Requirements: 6.4, 7.1_
  

  - [x] 12.3 Integrate Chat Conversation Bloc with Chat Screen





    - Wrap ChatConversationScreen with BlocProvider for ChatConversationBloc
    - Dispatch LoadChatHistory event on screen init
    - Dispatch ConnectSocket event after loading history
    - Use BlocConsumer to listen to ChatConversationState changes
    - Show loading indicator when ChatConversationLoading state
    - Display messages when ChatConversationLoaded state
    - Auto-scroll to bottom when new message received
    - Dispatch DisconnectSocket event on screen dispose
    - _Requirements: 4.1, 5.1, 5.3, 5.4, 8.5, 10.2_

  
  - [x] 12.4 Implement message sending functionality





    - Dispatch SendTextMessage event on send button press
    - Dispatch SendFileMessage event when file selected and sent
    - Show sending indicator while message is being sent
    - Display error if message sending fails

    - _Requirements: 6.1, 6.2, 6.3, 7.2, 7.3, 7.4, 7.5, 10.1, 10.5_
  
  - [x] 12.5 Add connection status indicator





    - Display connection status (Connected/Disconnected) in AppBar or as banner
    - Update status based on socket connection state
    - Show reconnecting indicator when connection lost
    - _Requirements: 5.5, 10.2_

- [x] 13. Implement app navigation and routing






  - [x] 13.1 Set up app routing

    - Create routes in main.dart for Login, ChatList, ChatConversation screens
    - Implement named routes or use go_router package
    - Pass necessary parameters (chatId, participantName) to ChatConversation screen
    - _Requirements: 2.3, 3.5_
  
  - [x] 13.2 Add authentication guard


    - Check authentication status on app launch
    - Dispatch CheckAuthStatus event in main.dart
    - Navigate to ChatList if authenticated, Login if not
    - _Requirements: 2.1, 2.2, 2.3_

- [x] 14. Add utility functions and helpers





  - [x] 14.1 Create date/time formatting utilities


    - Create DateTimeHelper class with formatting methods
    - Implement formatMessageTime for displaying message timestamps
    - Implement formatChatListTime for chat list timestamps
    - Add date separator logic for grouping messages by date
    - _Requirements: 8.1, 8.2, 8.3_
  


  - [x] 14.2 Create error handling utilities

















    - Create ErrorHandler class for parsing API errors
    - Implement user-friendly error message mapping
    - Add network connectivity checker
    - _Requirements: 10.1, 10.3, 10.5_

- [x] 15. Implement file upload functionality






  - [x] 15.1 Add file picker integration

    - Use file_picker package to select files
    - Implement file type validation (images, documents)
    - Add file size validation
    - _Requirements: 7.1_
  
  - [x] 15.2 Implement file upload service


    - Create FileUploadService class
    - Implement upload method to upload file to server
    - Return file URL after successful upload
    - Handle upload errors
    - _Requirements: 7.2_
  
  - [x] 15.3 Display file messages in chat


    - Update MessageBubble widget to handle file type messages
    - Show image preview for image files
    - Show file icon and name for other file types
    - Implement tap handler to open/download files
    - Use cached_network_image for image loading
    - _Requirements: 7.3, 7.4, 7.5_

- [x] 16. Add final polish and error handling





  - [x] 16.1 Implement comprehensive error handling


    - Add try-catch blocks in all service methods
    - Display user-friendly error messages in UI
    - Add error logging for debugging
    - Handle network timeout errors
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
  
  - [x] 16.2 Add loading states and indicators


    - Ensure all async operations show loading indicators
    - Add shimmer loading for chat list
    - Add skeleton loading for message history
    - Disable send button while message is sending
    - _Requirements: 10.1_
  
  - [x] 16.3 Optimize performance


    - Implement message list pagination if needed
    - Add message caching to reduce API calls
    - Optimize image loading with caching
    - Ensure proper disposal of streams and controllers
    - _Requirements: 4.2_

- [ ] 17. Testing and documentation





  - [x] 17.1 Write unit tests for models


    - Test JSON serialization/deserialization for User, Chat, Message models
    - Test model equality and copyWith methods
    - _Requirements: 9.5_
  

  - [x] 17.2 Write unit tests for services

    - Mock HTTP client and test AuthenticationService
    - Test ChatService and MessageService with mock responses
    - Test SocketService event handling
    - _Requirements: 9.2, 9.3, 9.4_
  

  - [x] 17.3 Write unit tests for Blocs

    - Test AuthBloc state transitions for all events
    - Test ChatListBloc state transitions
    - Test ChatConversationBloc state transitions
    - Mock services and verify correct service calls
    - _Requirements: 9.2, 9.3, 9.4_
  

  - [x] 17.4 Create README documentation

    - Document setup instructions for Flutter project
    - List all dependencies and versions
    - Provide API endpoint documentation
    - Add screenshots of app screens
    - Include build and run instructions
    - Document architecture and folder structure
    - _Requirements: 9.1_

- [ ] 18. Build release APK



  - Configure app name, package identifier, and version
  - Set up app icon and splash screen
  - Run flutter build apk --release
  - Test APK on physical device
  - _Requirements: All requirements_
