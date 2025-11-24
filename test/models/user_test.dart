import 'package:flutter_test/flutter_test.dart';
import 'package:newpro/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('fromJson creates User correctly', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'role': 'customer',
        'name': 'Test User',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.role, 'customer');
      expect(user.name, 'Test User');
    });

    test('fromJson handles _id field', () {
      final json = {
        '_id': '456',
        'email': 'vendor@example.com',
        'role': 'vendor',
      };

      final user = User.fromJson(json);

      expect(user.id, '456');
      expect(user.email, 'vendor@example.com');
      expect(user.role, 'vendor');
      expect(user.name, null);
    });

    test('toJson serializes User correctly', () {
      const user = User(
        id: '789',
        email: 'user@test.com',
        role: 'customer',
        name: 'John Doe',
      );

      final json = user.toJson();

      expect(json['id'], '789');
      expect(json['email'], 'user@test.com');
      expect(json['role'], 'customer');
      expect(json['name'], 'John Doe');
    });

    test('equality works correctly', () {
      const user1 = User(
        id: '1',
        email: 'test@test.com',
        role: 'customer',
        name: 'Test',
      );

      const user2 = User(
        id: '1',
        email: 'test@test.com',
        role: 'customer',
        name: 'Test',
      );

      const user3 = User(
        id: '2',
        email: 'test@test.com',
        role: 'customer',
        name: 'Test',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });
}
