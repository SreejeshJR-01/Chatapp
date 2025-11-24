import 'package:equatable/equatable.dart';

/// Base class for all chat list events
abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the user's chat list
class LoadChatList extends ChatListEvent {
  final String userId;

  const LoadChatList({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered to refresh the chat list
class RefreshChatList extends ChatListEvent {
  final String userId;

  const RefreshChatList({required this.userId});

  @override
  List<Object?> get props => [userId];
}
