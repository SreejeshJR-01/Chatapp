import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:newpro/blocs/chat_list/chat_list_bloc.dart';
import 'package:newpro/blocs/chat_list/chat_list_event.dart';
import 'package:newpro/blocs/chat_list/chat_list_state.dart';
import 'package:newpro/models/chat.dart';
import 'package:newpro/services/chat_service.dart';

import 'chat_list_bloc_test.mocks.dart';

@GenerateMocks([ChatService])
void main() {
  group('ChatListBloc Tests', () {
    late MockChatService mockChatService;

    setUp(() {
      mockChatService = MockChatService();
    });

    test('initial state is ChatListInitial', () {
      final chatListBloc = ChatListBloc(chatService: mockChatService);
      expect(chatListBloc.state, const ChatListInitial());
      chatListBloc.close();
    });

    blocTest<ChatListBloc, ChatListState>(
      'emits [ChatListLoading, ChatListLoaded] when LoadChatList succeeds',
      build: () {
        final chats = [
          Chat(
            id: 'chat1',
            participantId: 'user1',
            participantName: 'John Doe',
            lastMessage: 'Hello',
            lastMessageTime: DateTime.parse('2024-01-15T10:30:00.000Z'),
            unreadCount: 2,
          ),
        ];
        when(mockChatService.getUserChats(any)).thenAnswer((_) async => chats);
        return ChatListBloc(chatService: mockChatService);
      },
      act: (bloc) => bloc.add(const LoadChatList(userId: 'user123')),
      expect: () => [
        const ChatListLoading(),
        isA<ChatListLoaded>().having(
          (state) => state.chats.length,
          'chats length',
          1,
        ),
      ],
    );

    blocTest<ChatListBloc, ChatListState>(
      'emits [ChatListLoading, ChatListError] when LoadChatList fails',
      build: () {
        when(mockChatService.getUserChats(any))
            .thenThrow(Exception('Failed to load chats'));
        return ChatListBloc(chatService: mockChatService);
      },
      act: (bloc) => bloc.add(const LoadChatList(userId: 'user123')),
      expect: () => [
        const ChatListLoading(),
        isA<ChatListError>(),
      ],
    );

    blocTest<ChatListBloc, ChatListState>(
      'emits [ChatListLoaded] when RefreshChatList succeeds',
      build: () {
        final chats = [
          Chat(
            id: 'chat1',
            participantId: 'user1',
            participantName: 'John Doe',
          ),
        ];
        when(mockChatService.getUserChats(any)).thenAnswer((_) async => chats);
        return ChatListBloc(chatService: mockChatService);
      },
      act: (bloc) => bloc.add(const RefreshChatList(userId: 'user123')),
      expect: () => [
        isA<ChatListLoaded>(),
      ],
    );
  });
}
