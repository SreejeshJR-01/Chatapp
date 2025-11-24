import 'package:flutter_test/flutter_test.dart';
import 'package:newpro/models/message.dart';

void main() {
  group('Message Model Tests', () {
    const currentUserId = 'user123';

    test('fromJson creates Message correctly', () {
      final json = {
        'id': 'msg001',
        'chatId': 'chat123',
        'senderId': 'user456',
        'content': 'Hello world',
        'messageType': 'text',
        'timestamp': '2024-01-15T10:30:00.000Z',
      };

      final message = Message.fromJson(json, currentUserId);

      expect(message.id, 'msg001');
      expect(message.chatId, 'chat123');
      expect(message.senderId, 'user456');
      expect(message.content, 'Hello world');
      expect(message.messageType, 'text');
      expect(message.fileUrl, null);
      expect(message.timestamp, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(message.isSentByMe, false);
    });

    test('fromJson correctly identifies sent by me', () {
      final json = {
        'id': 'msg002',
        'chatId': 'chat123',
        'senderId': currentUserId,
        'content': 'My message',
        'messageType': 'text',
        'timestamp': '2024-01-15T11:00:00.000Z',
      };

      final message = Message.fromJson(json, currentUserId);

      expect(message.isSentByMe, true);
    });

    test('fromJson handles file type message', () {
      final json = {
        '_id': 'msg003',
        'chatId': 'chat456',
        'senderId': 'user789',
        'content': 'image.jpg',
        'messageType': 'file',
        'fileUrl': 'https://example.com/files/image.jpg',
        'timestamp': '2024-01-15T12:00:00.000Z',
      };

      final message = Message.fromJson(json, currentUserId);

      expect(message.id, 'msg003');
      expect(message.messageType, 'file');
      expect(message.fileUrl, 'https://example.com/files/image.jpg');
    });

    test('toJson serializes Message correctly', () {
      final message = Message(
        id: 'msg100',
        chatId: 'chat200',
        senderId: 'user300',
        content: 'Test content',
        messageType: 'text',
        timestamp: DateTime.parse('2024-01-20T15:45:00.000Z'),
        isSentByMe: true,
      );

      final json = message.toJson();

      expect(json['id'], 'msg100');
      expect(json['chatId'], 'chat200');
      expect(json['senderId'], 'user300');
      expect(json['content'], 'Test content');
      expect(json['messageType'], 'text');
      expect(json['timestamp'], '2024-01-20T15:45:00.000Z');
      expect(json.containsKey('isSentByMe'), false);
    });

    test('equality works correctly', () {
      final message1 = Message(
        id: '1',
        chatId: 'c1',
        senderId: 's1',
        content: 'Hi',
        messageType: 'text',
        timestamp: DateTime.parse('2024-01-01T00:00:00.000Z'),
        isSentByMe: true,
      );

      final message2 = Message(
        id: '1',
        chatId: 'c1',
        senderId: 's1',
        content: 'Hi',
        messageType: 'text',
        timestamp: DateTime.parse('2024-01-01T00:00:00.000Z'),
        isSentByMe: true,
      );

      final message3 = Message(
        id: '2',
        chatId: 'c1',
        senderId: 's1',
        content: 'Hi',
        messageType: 'text',
        timestamp: DateTime.parse('2024-01-01T00:00:00.000Z'),
        isSentByMe: true,
      );

      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });
  });
}
