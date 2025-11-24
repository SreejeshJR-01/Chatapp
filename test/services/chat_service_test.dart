import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:newpro/services/chat_service.dart';

import 'chat_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ChatService Tests', () {
    late MockClient mockHttpClient;
    late ChatService chatService;

    setUp(() {
      mockHttpClient = MockClient();
      chatService = ChatService(httpClient: mockHttpClient);
    });

    group('getUserChats', () {
      test('returns list of chats on success', () async {
        final responseBody = json.encode({
          'chats': [
            {
              'id': 'chat1',
              'participantId': 'user1',
              'participantName': 'John Doe',
              'lastMessage': 'Hello',
              'lastMessageTime': '2024-01-15T10:30:00.000Z',
              'unreadCount': 2,
            },
            {
              'id': 'chat2',
              'participantId': 'user2',
              'participantName': 'Jane Smith',
              'lastMessage': 'Hi there',
              'lastMessageTime': '2024-01-15T11:00:00.000Z',
              'unreadCount': 0,
            },
          ],
        });

        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        final chats = await chatService.getUserChats('user123');

        expect(chats.length, 2);
        expect(chats[0].id, 'chat1');
        expect(chats[0].participantName, 'John Doe');
        expect(chats[1].id, 'chat2');
        expect(chats[1].participantName, 'Jane Smith');
      });

      test('returns empty list when no chats found', () async {
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        final chats = await chatService.getUserChats('user123');

        expect(chats, isEmpty);
      });

      test('handles array response format', () async {
        final responseBody = json.encode([
          {
            'id': 'chat1',
            'participantId': 'user1',
            'participantName': 'John Doe',
          },
        ]);

        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        final chats = await chatService.getUserChats('user123');

        expect(chats.length, 1);
        expect(chats[0].id, 'chat1');
      });

      test('throws exception on server error', () async {
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        expect(
          () => chatService.getUserChats('user123'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
