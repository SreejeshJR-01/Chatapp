import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:newpro/services/message_service.dart';

import 'message_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('MessageService Tests', () {
    late MockClient mockHttpClient;
    late MessageService messageService;

    setUp(() {
      mockHttpClient = MockClient();
      messageService = MessageService(httpClient: mockHttpClient);
    });

    group('getChatMessages', () {
      test('returns list of messages on success', () async {
        final responseBody = json.encode({
          'messages': [
            {
              'id': 'msg1',
              'chatId': 'chat1',
              'senderId': 'user1',
              'content': 'Hello',
              'messageType': 'text',
              'timestamp': '2024-01-15T10:30:00.000Z',
            },
            {
              'id': 'msg2',
              'chatId': 'chat1',
              'senderId': 'user2',
              'content': 'Hi there',
              'messageType': 'text',
              'timestamp': '2024-01-15T10:31:00.000Z',
            },
          ],
        });

        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        final messages = await messageService.getChatMessages('chat1', 'user1');

        expect(messages.length, 2);
        expect(messages[0].id, 'msg1');
        expect(messages[0].content, 'Hello');
        expect(messages[0].isSentByMe, true);
        expect(messages[1].id, 'msg2');
        expect(messages[1].isSentByMe, false);
      });

      test('returns empty list when no messages found', () async {
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        final messages = await messageService.getChatMessages('chat1', 'user1');

        expect(messages, isEmpty);
      });

      test('throws exception on server error', () async {
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        expect(
          () => messageService.getChatMessages('chat1', 'user1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('sendMessage', () {
      test('sends text message successfully', () async {
        final responseBody = json.encode({
          'success': true,
          'message': {
            'id': 'msg1',
            'chatId': 'chat1',
            'senderId': 'user1',
            'content': 'Hello',
            'messageType': 'text',
            'timestamp': '2024-01-15T10:30:00.000Z',
          },
        });

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        final response = await messageService.sendMessage(
          chatId: 'chat1',
          senderId: 'user1',
          content: 'Hello',
          messageType: 'text',
        );

        expect(response.success, true);
        expect(response.message, isNotNull);
        expect(response.message!.content, 'Hello');
      });

      test('sends file message with fileUrl', () async {
        final responseBody = json.encode({
          'success': true,
          'message': {
            'id': 'msg2',
            'chatId': 'chat1',
            'senderId': 'user1',
            'content': 'image.jpg',
            'messageType': 'file',
            'fileUrl': 'https://example.com/image.jpg',
            'timestamp': '2024-01-15T10:30:00.000Z',
          },
        });

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(responseBody, 201));

        final response = await messageService.sendMessage(
          chatId: 'chat1',
          senderId: 'user1',
          content: 'image.jpg',
          messageType: 'file',
          fileUrl: 'https://example.com/image.jpg',
        );

        expect(response.success, true);
        expect(response.message!.messageType, 'file');
        expect(response.message!.fileUrl, 'https://example.com/image.jpg');
      });

      test('throws exception on server error', () async {
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        expect(
          () => messageService.sendMessage(
            chatId: 'chat1',
            senderId: 'user1',
            content: 'Hello',
            messageType: 'text',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
