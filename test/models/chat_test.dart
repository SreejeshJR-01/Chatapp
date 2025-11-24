import 'package:flutter_test/flutter_test.dart';
import 'package:newpro/models/chat.dart';

void main() {
  group('Chat Model Tests', () {
    test('fromJson creates Chat correctly', () {
      final json = {
        'id': 'chat123',
        'participantId': 'user456',
        'participantName': 'John Vendor',
        'lastMessage': 'Hello there',
        'lastMessageTime': '2024-01-15T10:30:00.000Z',
        'unreadCount': 3,
      };

      final chat = Chat.fromJson(json);

      expect(chat.id, 'chat123');
      expect(chat.participantId, 'user456');
      expect(chat.participantName, 'John Vendor');
      expect(chat.lastMessage, 'Hello there');
      expect(chat.lastMessageTime, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(chat.unreadCount, 3);
    });

    test('fromJson handles _id field', () {
      final json = {
        '_id': 'chat789',
        'participantId': 'user123',
        'participantName': 'Jane Customer',
      };

      final chat = Chat.fromJson(json);

      expect(chat.id, 'chat789');
      expect(chat.participantId, 'user123');
      expect(chat.participantName, 'Jane Customer');
      expect(chat.lastMessage, null);
      expect(chat.lastMessageTime, null);
      expect(chat.unreadCount, 0);
    });

    test('toJson serializes Chat correctly', () {
      final chat = Chat(
        id: 'chat001',
        participantId: 'user002',
        participantName: 'Test User',
        lastMessage: 'Test message',
        lastMessageTime: DateTime.parse('2024-01-20T15:45:00.000Z'),
        unreadCount: 5,
      );

      final json = chat.toJson();

      expect(json['id'], 'chat001');
      expect(json['participantId'], 'user002');
      expect(json['participantName'], 'Test User');
      expect(json['lastMessage'], 'Test message');
      expect(json['lastMessageTime'], '2024-01-20T15:45:00.000Z');
      expect(json['unreadCount'], 5);
    });

    test('equality works correctly', () {
      final chat1 = Chat(
        id: '1',
        participantId: 'p1',
        participantName: 'Name',
        lastMessage: 'Hi',
        lastMessageTime: DateTime.parse('2024-01-01T00:00:00.000Z'),
        unreadCount: 1,
      );

      final chat2 = Chat(
        id: '1',
        participantId: 'p1',
        participantName: 'Name',
        lastMessage: 'Hi',
        lastMessageTime: DateTime.parse('2024-01-01T00:00:00.000Z'),
        unreadCount: 1,
      );

      final chat3 = Chat(
        id: '2',
        participantId: 'p1',
        participantName: 'Name',
        lastMessage: 'Hi',
        lastMessageTime: DateTime.parse('2024-01-01T00:00:00.000Z'),
        unreadCount: 1,
      );

      expect(chat1, equals(chat2));
      expect(chat1, isNot(equals(chat3)));
    });
  });
}
