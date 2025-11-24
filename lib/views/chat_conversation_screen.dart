import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';
import '../models/chat.dart';
import '../blocs/chat_conversation/chat_conversation_bloc.dart';
import '../blocs/chat_conversation/chat_conversation_event.dart';
import '../blocs/chat_conversation/chat_conversation_state.dart';
import '../services/message_service.dart';
import '../services/socket_service.dart' show SocketService, ConnectionStatus;
import '../services/file_upload_service.dart';
import '../utils/file_picker_helper.dart';
import '../widgets/shimmer_loading.dart';

/// Chat conversation screen for displaying and sending messages
class ChatConversationScreen extends StatefulWidget {
  final Chat chat;
  final String currentUserId;

  const ChatConversationScreen({
    super.key,
    required this.chat,
    required this.currentUserId,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Auto-scroll to the bottom of the message list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Build connection status indicator widget
  Widget _buildConnectionStatus(ConnectionStatus status) {
    String statusText;
    Color statusColor;
    Widget statusIcon;

    switch (status) {
      case ConnectionStatus.connected:
        statusText = 'Active now';
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
        );
        break;
      case ConnectionStatus.disconnected:
        statusText = 'Offline';
        statusColor = const Color(0xFFFF6B6B);
        statusIcon = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B6B),
            shape: BoxShape.circle,
          ),
        );
        break;
      case ConnectionStatus.reconnecting:
        statusText = 'Connecting...';
        statusColor = const Color(0xFFFFA726);
        statusIcon = const SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)),
          ),
        );
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        statusIcon,
        const SizedBox(width: 6),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatConversationBloc(
              messageService: context.read<MessageService>(),
              socketService: context.read<SocketService>(),
            )
            ..add(
              LoadChatHistory(
                chatId: widget.chat.id,
                currentUserId: widget.currentUserId,
              ),
            )
            ..add(ConnectSocket(userId: widget.currentUserId)),
      child: BlocConsumer<ChatConversationBloc, ChatConversationState>(
        listener: (context, state) {
          // Auto-scroll when new message is received or sent
          if (state is ChatConversationMessageReceived ||
              state is ChatConversationMessageSent) {
            _scrollToBottom();
          }

          // Show error message
          if (state is ChatConversationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                // Disconnect socket when leaving the screen
                context.read<ChatConversationBloc>().add(
                  const DisconnectSocket(),
                );
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF0A0E27),
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: const Color(0xFF1C1F37),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0084FF), Color(0xFF00A8FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.chat.participantName.isNotEmpty
                              ? widget.chat.participantName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chat.participantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (state is ChatConversationLoaded ||
                              state is ChatConversationMessageSending ||
                              state is ChatConversationMessageSent ||
                              state is ChatConversationMessageReceived)
                            _buildConnectionStatus(
                              (state as dynamic).connectionStatus,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Message list
                    Expanded(
                      child: Builder(
                        builder: (builderContext) =>
                            _buildMessageList(state, builderContext),
                      ),
                    ),
                    // Message input
                    Builder(
                      builder: (builderContext) =>
                          _buildMessageInput(state, builderContext),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build the message list widget
  Widget _buildMessageList(
    ChatConversationState state,
    BuildContext listContext,
  ) {
    if (state is ChatConversationLoading) {
      return const MessageHistoryShimmer();
    }

    if (state is ChatConversationError && state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                listContext.read<ChatConversationBloc>().add(
                  LoadChatHistory(
                    chatId: widget.chat.id,
                    currentUserId: widget.currentUserId,
                  ),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final messages = _getMessages(state);

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F37),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Color(0xFF0084FF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start the conversation!',
              style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Auto-scroll after messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(listContext).padding.bottom,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showDateSeparator = _shouldShowDateSeparator(messages, index);

        return Column(
          children: [
            if (showDateSeparator) _buildDateSeparator(message.timestamp),
            MessageBubble(message: message),
          ],
        );
      },
    );
  }

  /// Build the message input widget
  Widget _buildMessageInput(
    ChatConversationState state,
    BuildContext inputContext,
  ) {
    final isSending = state is ChatConversationMessageSending;
    final bottomPadding = MediaQuery.of(inputContext).viewInsets.bottom;
    final systemBottomPadding = MediaQuery.of(inputContext).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomPadding > 0
            ? 12
            : (systemBottomPadding > 0 ? systemBottomPadding : 12),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1F37),
        border: Border(top: BorderSide(color: Color(0xFF2A2D4A), width: 1)),
      ),
      child: Row(
        children: [
          // File attachment button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D4A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF0084FF)),
              onPressed: isSending
                  ? null
                  : () => _pickAndSendFile(inputContext),
            ),
          ),
          const SizedBox(width: 12),
          // Message input field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D4A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Color(0xFF6B6E82)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                enabled: !isSending,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0084FF), Color(0xFF00A8FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: isSending
                  ? null
                  : () => _sendTextMessage(inputContext),
            ),
          ),
        ],
      ),
    );
  }

  /// Send text message
  void _sendTextMessage(BuildContext btnContext) {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      btnContext.read<ChatConversationBloc>().add(
        SendTextMessage(
          chatId: widget.chat.id,
          senderId: widget.currentUserId,
          content: content,
        ),
      );
      _messageController.clear();
    }
  }

  /// Pick and send file
  Future<void> _pickAndSendFile(BuildContext btnContext) async {
    try {
      // Pick file using file picker helper with validation
      final result = await FilePickerHelper.pickFile();

      if (result.isCancelled) {
        return;
      }

      if (result.isError) {
        if (!mounted) return;
        ScaffoldMessenger.of(btnContext).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final file = result.file!;

      // Show uploading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(btnContext).showSnackBar(
        SnackBar(
          content: Text('Uploading ${file.name}...'),
          duration: const Duration(seconds: 30),
        ),
      );

      // Upload file to server
      final fileUploadService = btnContext.read<FileUploadService>();
      String fileUrl;

      if (file.path != null) {
        // For mobile/desktop platforms
        fileUrl = await fileUploadService.uploadFile(
          file: File(file.path!),
          fileName: file.name,
        );
      } else if (file.bytes != null) {
        // For web platform
        fileUrl = await fileUploadService.uploadFileFromBytes(
          bytes: file.bytes!,
          fileName: file.name,
        );
      } else {
        throw Exception('Unable to access file data');
      }

      // Hide uploading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(btnContext).hideCurrentSnackBar();

      // Send file message
      if (!mounted) return;
      btnContext.read<ChatConversationBloc>().add(
        SendFileMessage(
          chatId: widget.chat.id,
          senderId: widget.currentUserId,
          fileUrl: fileUrl,
          content: file.name,
        ),
      );

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(btnContext).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(btnContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(btnContext).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Get messages from the current state
  List<Message> _getMessages(ChatConversationState state) {
    if (state is ChatConversationLoaded) return state.messages;
    if (state is ChatConversationMessageSending) return state.messages;
    if (state is ChatConversationMessageSent) return state.messages;
    if (state is ChatConversationMessageReceived) return state.messages;
    if (state is ChatConversationError) return state.messages;
    return [];
  }

  /// Check if date separator should be shown
  bool _shouldShowDateSeparator(List<Message> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );

    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );

    return currentDate != previousDate;
  }

  /// Build date separator widget
  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMM dd, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D4A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB0B3C7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Message bubble widget for displaying individual messages
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  /// Get file extension from URL or filename
  String? _getFileExtension() {
    final url = message.fileUrl ?? message.content;
    final parts = url.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase().split('?').first;
    }
    return null;
  }

  /// Check if file is an image
  bool _isImageFile() {
    final extension = _getFileExtension();
    return FilePickerHelper.isImageFile(extension);
  }

  /// Open or download file
  Future<void> _openFile(BuildContext context) async {
    final fileUrl = message.fileUrl;
    if (fileUrl == null || fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File URL not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Get icon for file type
  IconData _getFileIcon() {
    final extension = _getFileExtension();
    if (extension == null) return Icons.insert_drive_file;

    if (FilePickerHelper.isImageFile(extension)) {
      return Icons.image;
    } else if (extension == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (extension == 'doc' || extension == 'docx') {
      return Icons.description;
    } else if (extension == 'xls' || extension == 'xlsx') {
      return Icons.table_chart;
    } else if (extension == 'txt') {
      return Icons.text_snippet;
    }
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    final isSentByMe = message.isSentByMe;
    final isFileMessage = message.messageType == 'file';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: isSentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: isFileMessage ? () => _openFile(context) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSentByMe
                      ? const LinearGradient(
                          colors: [Color(0xFF0084FF), Color(0xFF00A8FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSentByMe ? null : const Color(0xFF2A2D4A),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
                    bottomRight: Radius.circular(isSentByMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File content or message content
                    if (isFileMessage)
                      _buildFileContent(isSentByMe)
                    else
                      Text(
                        message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Timestamp
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        color: isSentByMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF6B6E82),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build file content widget
  Widget _buildFileContent(bool isSentByMe) {
    if (_isImageFile() && message.fileUrl != null) {
      // Show image preview
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: message.fileUrl!,
              width: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 150,
                color: Colors.grey[400],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 150,
                color: Colors.grey[400],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 48,
                      color: isSentByMe ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: isSentByMe ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message.content,
              style: TextStyle(
                color: isSentByMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ],
      );
    } else {
      // Show file icon and name for documents
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(),
            size: 32,
            color: isSentByMe ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isSentByMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to open',
                  style: TextStyle(
                    color: isSentByMe ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
