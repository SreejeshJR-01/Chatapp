# Requirements Document

## Introduction

This document specifies the requirements for a Real-Time Chat Application that enables messaging between Customers and Vendors. The system consists of a Flutter mobile application frontend that integrates with an existing Node.js backend API, utilizing Socket.IO for real-time communication. The application supports role-based authentication for two user types: Customer and Vendor.

## Glossary

- **Chat Application**: The Flutter mobile application frontend
- **Customer**: A user with customer role who can chat with vendors
- **Vendor**: A user with vendor role who can chat with customers
- **Backend API**: The existing Node.js server at http://45.129.87.38:6065
- **Chat**: A conversation thread between a customer and a vendor
- **Chat List**: The home screen displaying all chat conversations for a user
- **Chat Message**: A text or file message sent between users with timestamp
- **Socket Connection**: Real-time bidirectional communication channel for instant messaging
- **Chat ID**: Unique identifier for a conversation thread
- **User ID**: Unique identifier for a customer or vendor
- **Sender ID**: User ID of the message sender
- **Message Type**: Classification of message content (text or file)
- **File URL**: Remote location of uploaded file attachments

## Requirements

### Requirement 1

**User Story:** As a user, I want to login as either a Customer or Vendor, so that I can access my role-specific chat conversations

#### Acceptance Criteria

1. WHEN the User submits login credentials with email, password, and role, THE Chat Application SHALL send a POST request to http://45.129.87.38:6065/user/login
2. WHEN the Backend API validates the credentials, THE Chat Application SHALL receive authentication response with user details and User ID
3. WHEN the Chat Application receives successful authentication, THE Chat Application SHALL store the User ID and role securely in local storage
4. IF the credentials are invalid, THEN THE Chat Application SHALL display an error message to the User
5. THE Chat Application SHALL provide role selection options for Customer and Vendor on the login screen

### Requirement 2

**User Story:** As a logged-in user, I want the app to remember my authentication, so that I don't have to login every time I open the app

#### Acceptance Criteria

1. WHEN the Chat Application launches, THE Chat Application SHALL check for stored User ID and role in local storage
2. IF valid authentication data exists, THEN THE Chat Application SHALL navigate the User directly to the Chat List screen
3. IF no authentication data exists, THEN THE Chat Application SHALL display the login screen
4. WHEN the User logs out, THE Chat Application SHALL remove all stored authentication data from local storage
5. THE Chat Application SHALL prevent access to chat features when no valid authentication data is present

### Requirement 3

**User Story:** As a logged-in user, I want to see a list of all my chat conversations on the home screen, so that I can access my ongoing conversations

#### Acceptance Criteria

1. WHEN the User navigates to the Chat List screen, THE Chat Application SHALL send a GET request to http://45.129.87.38:6065/chats/user-chats/:userId with the stored User ID
2. WHEN the Backend API returns chat data, THE Chat Application SHALL display each chat as a list item with conversation details
3. WHEN the Chat Application displays the Chat List, THE Chat Application SHALL show the most recent message preview for each chat
4. THE Chat Application SHALL display the other participant's name for each chat conversation
5. WHEN the User taps on a chat item, THE Chat Application SHALL navigate to the specific chat conversation screen

### Requirement 4

**User Story:** As a user, I want to view the complete chat history when I open a conversation, so that I can see all previous messages

#### Acceptance Criteria

1. WHEN the User opens a specific chat, THE Chat Application SHALL send a GET request to http://45.129.87.38:6065/messages/get-messagesformobile/:chatId with the Chat ID
2. WHEN the Backend API returns message history, THE Chat Application SHALL display all messages in chronological order
3. WHEN the Chat Application displays messages, THE Chat Application SHALL show sender messages on the right side with distinct styling
4. WHEN the Chat Application displays messages, THE Chat Application SHALL show receiver messages on the left side with distinct styling
5. WHEN messages are loaded, THE Chat Application SHALL auto-scroll to show the most recent message

### Requirement 5

**User Story:** As a user, I want to establish a real-time connection when viewing a chat, so that I can receive new messages instantly

#### Acceptance Criteria

1. WHEN the User opens a chat conversation, THE Chat Application SHALL establish a Socket Connection to the Backend API
2. WHEN the Socket Connection is established, THE Chat Application SHALL listen for incoming message events
3. WHEN a new Chat Message is received through the Socket Connection, THE Chat Application SHALL display the message immediately in the chat view
4. WHEN a new message is displayed, THE Chat Application SHALL auto-scroll to show the latest message
5. WHEN the Socket Connection is lost, THE Chat Application SHALL attempt automatic reconnection

### Requirement 6

**User Story:** As a user, I want to send text messages to the other participant, so that I can communicate in real-time

#### Acceptance Criteria

1. WHEN the User submits a text message, THE Chat Application SHALL send a POST request to http://45.129.87.38:6065/messages/sendMessage with Chat ID, Sender ID, content, and Message Type as "text"
2. WHEN the Backend API confirms message delivery, THE Chat Application SHALL display the sent message in the chat view
3. WHEN the message is sent, THE Chat Application SHALL emit the message through the Socket Connection for real-time delivery
4. WHEN the Chat Application sends a message, THE Chat Application SHALL clear the message input field
5. THE Chat Application SHALL display the sent message with timestamp on the right side of the chat view

### Requirement 7

**User Story:** As a user, I want to send file attachments in my messages, so that I can share images and documents

#### Acceptance Criteria

1. WHEN the User selects a file to send, THE Chat Application SHALL upload the file and obtain a File URL
2. WHEN the file upload completes, THE Chat Application SHALL send a POST request to http://45.129.87.38:6065/messages/sendMessage with Chat ID, Sender ID, File URL, and Message Type as "file"
3. WHEN the Backend API confirms file message delivery, THE Chat Application SHALL display the file message in the chat view
4. WHEN displaying file messages, THE Chat Application SHALL show a preview or icon representing the file type
5. WHEN the User taps on a file message, THE Chat Application SHALL open or download the file from the File URL

### Requirement 8

**User Story:** As a user, I want to see timestamps on all messages, so that I can track when conversations occurred

#### Acceptance Criteria

1. WHEN the Chat Application displays a Chat Message, THE Chat Application SHALL show the timestamp with the message
2. THE Chat Application SHALL format timestamps in a readable format showing time
3. WHEN messages are from different days, THE Chat Application SHALL display date separators between message groups
4. THE Chat Application SHALL display messages in chronological order based on timestamps
5. WHEN new messages arrive, THE Chat Application SHALL maintain chronological ordering in the chat view

### Requirement 9

**User Story:** As a developer, I want the application to follow MVVM architecture with Bloc state management, so that the code is maintainable and testable

#### Acceptance Criteria

1. THE Chat Application SHALL organize code into models, services, views, and blocs directories
2. THE Chat Application SHALL implement Bloc pattern for authentication state management
3. THE Chat Application SHALL implement Bloc pattern for chat list state management
4. THE Chat Application SHALL implement Bloc pattern for chat conversation state management
5. THE Chat Application SHALL define data models for User, Chat, Message, and API responses

### Requirement 10

**User Story:** As a developer, I want proper error handling throughout the application, so that users receive clear feedback when issues occur

#### Acceptance Criteria

1. WHEN API requests fail, THE Chat Application SHALL display user-friendly error messages
2. WHEN the Socket Connection fails, THE Chat Application SHALL notify the User and attempt reconnection
3. WHEN network connectivity is lost, THE Chat Application SHALL inform the User of offline status
4. THE Chat Application SHALL log errors for debugging purposes without exposing sensitive information
5. WHEN the Backend API returns error responses, THE Chat Application SHALL parse and display appropriate error messages to the User
