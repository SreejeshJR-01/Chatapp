import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../models/chat.dart';
import '../widgets/shimmer_loading.dart';

/// Chat list screen displaying all user conversations
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Load chat list after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatList();
    });
  }

  void _loadChatList() {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.user != null) {
      context.read<ChatListViewModel>().loadChatList(authViewModel.user!.id);
    }
  }

  void _handleRefresh() {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.user != null) {
      context.read<ChatListViewModel>().refreshChatList(authViewModel.user!.id);
    }
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1F37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Color(0xFFB0B3C7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFFB0B3C7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (mounted) {
        context.read<AuthViewModel>().logout();
      }
    }
  }

  void _handleChatTap(Chat chat) {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.user != null) {
      // Navigate to chat conversation screen using named route
      Navigator.of(context).pushNamed(
        '/chat-conversation',
        arguments: {
          'chat': chat,
          'currentUserId': authViewModel.user!.id,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1F37),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, size: 20),
            ),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<AuthViewModel, ChatListViewModel>(
        builder: (context, authViewModel, chatListViewModel, child) {
          // Navigate to login if not authenticated
          if (!authViewModel.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
          }

          // Show loading state
          if (chatListViewModel.isLoading) {
            return const ChatListShimmer();
          }

          // Show error state
          if (chatListViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1F37),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Error loading chats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      chatListViewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB0B3C7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _loadChatList,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0084FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (chatListViewModel.chats.isEmpty) {
            return _buildEmptyState();
          }

          // Show chat list
          return RefreshIndicator(
            onRefresh: () async {
              _handleRefresh();
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: chatListViewModel.chats.length,
              itemBuilder: (context, index) {
                final chat = chatListViewModel.chats[index];
                return ChatListItem(
                  chat: chat,
                  onTap: () => _handleChatTap(chat),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F37),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Color(0xFF0084FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start a conversation to see it here',
            style: TextStyle(
              color: Color(0xFFB0B3C7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying individual chat item in the list
class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
  });

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(timestamp);
    } else {
      // Older - show date
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F37),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0084FF), Color(0xFF00A8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              chat.participantName.isNotEmpty
                  ? chat.participantName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        title: Text(
          chat.participantName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: chat.lastMessage != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  chat.lastMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB0B3C7),
                    fontSize: 14,
                  ),
                ),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimestamp(chat.lastMessageTime),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B6E82),
              ),
            ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0084FF), Color(0xFF00A8FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
