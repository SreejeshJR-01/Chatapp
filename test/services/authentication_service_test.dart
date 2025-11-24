import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:newpro/models/user.dart';
import 'package:newpro/repositories/local_storage_repository.dart';
import 'package:newpro/services/authentication_service.dart';

import 'authentication_service_test.mocks.dart';

@GenerateMocks([http.Client, LocalStorageRepository])
void main() {
  group('AuthenticationService Tests', () {
    late MockClient mockHttpClient;
    late MockLocalStorageRepository mockLocalStorage;
    late AuthenticationService authService;

    setUp(() {
      mockHttpClient = MockClient();
      mockLocalStorage = MockLocalStorageRepository();
      authService = AuthenticationService(
        httpClient: mockHttpClient,
        localStorageRepository: mockLocalStorage,
      );
    });

    group('login', () {
      test('successful login returns User', () async {
        final responseBody = json.encode({
          'success': true,
          'user': {
            'id': '123',
            'email': 'test@example.com',
            'role': 'customer',
            'name': 'Test User',
          },
        });

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        final user = await authService.login(
          'test@example.com',
          'password123',
          'customer',
        );

        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.role, 'customer');
        expect(user.name, 'Test User');
      });

      test('invalid credentials throws exception', () async {
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Unauthorized', 401));

        expect(
          () => authService.login('wrong@example.com', 'wrong', 'customer'),
          throwsA(isA<Exception>()),
        );
      });

      test('server error throws exception', () async {
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        expect(
          () => authService.login('test@example.com', 'password', 'customer'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('saveUserData', () {
      test('saves user data to local storage', () async {
        const user = User(
          id: '123',
          email: 'test@example.com',
          role: 'customer',
          name: 'Test User',
        );

        when(mockLocalStorage.saveString(any, any))
            .thenAnswer((_) async => {});

        await authService.saveUserData(user);

        verify(mockLocalStorage.saveString(
          LocalStorageRepository.USER_ID,
          '123',
        )).called(1);
        verify(mockLocalStorage.saveString(
          LocalStorageRepository.USER_EMAIL,
          'test@example.com',
        )).called(1);
        verify(mockLocalStorage.saveString(
          LocalStorageRepository.USER_ROLE,
          'customer',
        )).called(1);
        verify(mockLocalStorage.saveString(
          LocalStorageRepository.USER_NAME,
          'Test User',
        )).called(1);
      });
    });

    group('getCurrentUser', () {
      test('returns User when data exists', () async {
        when(mockLocalStorage.getString(LocalStorageRepository.USER_ID))
            .thenAnswer((_) async => '123');
        when(mockLocalStorage.getString(LocalStorageRepository.USER_EMAIL))
            .thenAnswer((_) async => 'test@example.com');
        when(mockLocalStorage.getString(LocalStorageRepository.USER_ROLE))
            .thenAnswer((_) async => 'customer');
        when(mockLocalStorage.getString(LocalStorageRepository.USER_NAME))
            .thenAnswer((_) async => 'Test User');

        final user = await authService.getCurrentUser();

        expect(user, isNotNull);
        expect(user!.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.role, 'customer');
        expect(user.name, 'Test User');
      });

      test('returns null when data does not exist', () async {
        when(mockLocalStorage.getString(any)).thenAnswer((_) async => null);

        final user = await authService.getCurrentUser();

        expect(user, isNull);
      });
    });

    group('logout', () {
      test('removes all user data from local storage', () async {
        when(mockLocalStorage.remove(any)).thenAnswer((_) async => {});

        await authService.logout();

        verify(mockLocalStorage.remove(LocalStorageRepository.USER_ID))
            .called(1);
        verify(mockLocalStorage.remove(LocalStorageRepository.USER_EMAIL))
            .called(1);
        verify(mockLocalStorage.remove(LocalStorageRepository.USER_ROLE))
            .called(1);
        verify(mockLocalStorage.remove(LocalStorageRepository.USER_NAME))
            .called(1);
      });
    });
  });
}
