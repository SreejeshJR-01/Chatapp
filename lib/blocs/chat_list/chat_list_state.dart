import 'package:equatable/equatable.dart';
import '../../models/chat.dart';

/// Base class for all chat list states
abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

/// Initial state when chat list has not been loaded yet
class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

/// State when chat list is being loaded
class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

/// State when chat list has been successfully loaded
class ChatListLoaded extends ChatListState {
  final List<Chat> chats;

  const ChatListLoaded({required this.chats});

  @override
  List<Object?> get props => [chats];
}

/// State when chat list loading fails
class ChatListError extends ChatListState {
  final String message;

  const ChatListError({required this.message});

  @override
  List<Object?> get props => [message];
}
