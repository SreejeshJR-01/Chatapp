import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:newpro/blocs/auth/auth_bloc.dart';
import 'package:newpro/blocs/auth/auth_event.dart';
import 'package:newpro/blocs/auth/auth_state.dart';
import 'package:newpro/models/user.dart';
import 'package:newpro/services/authentication_service.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthenticationService])
void main() {
  group('AuthBloc Tests', () {
    late MockAuthenticationService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthenticationService();
    });

    test('initial state is AuthInitial', () {
      final authBloc = AuthBloc(authenticationService: mockAuthService);
      expect(authBloc.state, const AuthInitial());
      authBloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when LoginRequested succeeds',
      build: () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          role: 'customer',
          name: 'Test User',
        );
        when(mockAuthService.login(any, any, any))
            .thenAnswer((_) async => user);
        when(mockAuthService.saveUserData(any)).thenAnswer((_) async => {});
        return AuthBloc(authenticationService: mockAuthService);
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'test@example.com',
        password: 'password',
        role: 'customer',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(
          user: User(
            id: '123',
            email: 'test@example.com',
            role: 'customer',
            name: 'Test User',
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested fails',
      build: () {
        when(mockAuthService.login(any, any, any))
            .thenThrow(Exception('Invalid credentials'));
        return AuthBloc(authenticationService: mockAuthService);
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'wrong@example.com',
        password: 'wrong',
        role: 'customer',
      )),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when LogoutRequested',
      build: () {
        when(mockAuthService.logout()).thenAnswer((_) async => {});
        return AuthBloc(authenticationService: mockAuthService);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when CheckAuthStatus finds user',
      build: () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          role: 'customer',
        );
        when(mockAuthService.getCurrentUser()).thenAnswer((_) async => user);
        return AuthBloc(authenticationService: mockAuthService);
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(
          user: User(
            id: '123',
            email: 'test@example.com',
            role: 'customer',
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when CheckAuthStatus finds no user',
      build: () {
        when(mockAuthService.getCurrentUser()).thenAnswer((_) async => null);
        return AuthBloc(authenticationService: mockAuthService);
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
