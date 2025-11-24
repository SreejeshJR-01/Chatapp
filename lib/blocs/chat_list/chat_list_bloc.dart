import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/chat_service.dart';
import '../../utils/error_handler.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

/// Bloc for managing chat list state and operations
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatService _chatService;

  ChatListBloc({
    required ChatService chatService,
  })  : _chatService = chatService,
        super(const ChatListInitial()) {
    // Register event handlers
    on<LoadChatList>(_onLoadChatList);
    on<RefreshChatList>(_onRefreshChatList);
  }

  /// Handle load chat list event
  Future<void> _onLoadChatList(
    LoadChatList event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());

    try {
      // Fetch chat list from the service
      final chats = await _chatService.getUserChats(event.userId);

      // Emit loaded state with chat list
      emit(ChatListLoaded(chats: chats));
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('ChatListBloc.loadChatList', e, stackTrace);
      
      // Emit error state with user-friendly error message
      emit(ChatListError(
        message: ErrorHandler.getUserFriendlyMessage(e),
      ));
    }
  }

  /// Handle refresh chat list event
  Future<void> _onRefreshChatList(
    RefreshChatList event,
    Emitter<ChatListState> emit,
  ) async {
    // For refresh, we don't show loading state to avoid UI flicker
    // Instead, we keep the current state and update when data arrives
    try {
      // Fetch updated chat list from the service
      final chats = await _chatService.getUserChats(event.userId);

      // Emit loaded state with refreshed chat list
      emit(ChatListLoaded(chats: chats));
    } catch (e, stackTrace) {
      // Log error for debugging
      ErrorHandler.logError('ChatListBloc.refreshChatList', e, stackTrace);
      
      // Emit error state with user-friendly error message
      emit(ChatListError(
        message: ErrorHandler.getUserFriendlyMessage(e),
      ));
    }
  }
}
