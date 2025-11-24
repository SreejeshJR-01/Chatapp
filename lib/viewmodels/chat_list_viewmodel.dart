import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../utils/error_handler.dart';

/// ViewModel for managing chat list state and operations
/// Follows MVVM pattern with ChangeNotifier for reactive UI updates
class ChatListViewModel extends ChangeNotifier {
  final ChatService _chatService;

  ChatListViewModel({required ChatService chatService})
    : _chatService = chatService;

  // State properties
  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for state
  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasChats => _chats.isNotEmpty;

  /// Load chat list for a user
  Future<void> loadChatList(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Fetch chat list from the service
      final chats = await _chatService.getUserChats(userId);

      // Update state
      _chats = chats;
      _setLoading(false);
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('ChatListViewModel.loadChatList', e, stackTrace);

      // Set user-friendly error message
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      _setLoading(false);
    }
  }

  /// Refresh chat list for a user
  Future<void> refreshChatList(String userId) async {
    // For refresh, we don't show loading state to avoid UI flicker
    _clearError();

    try {
      // Fetch updated chat list from the service
      final chats = await _chatService.getUserChats(userId);

      // Update state
      _chats = chats;
      notifyListeners();
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('ChatListViewModel.refreshChatList', e, stackTrace);

      // Set user-friendly error message
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
