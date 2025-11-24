import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'blocs/chat_conversation/chat_conversation_bloc.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/chat_list_viewmodel.dart';
import 'services/authentication_service.dart';
import 'services/chat_service.dart';
import 'services/message_service.dart';
import 'services/socket_service.dart';
import 'services/file_upload_service.dart';
import 'repositories/local_storage_repository.dart';
import 'models/chat.dart';
import 'views/login_screen.dart';
import 'views/chat_list_screen.dart';
import 'views/chat_conversation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final localStorageRepository = LocalStorageRepository();
    final authenticationService = AuthenticationService(
      localStorageRepository: localStorageRepository,
    );
    final chatService = ChatService();
    final messageService = MessageService();
    final socketService = SocketService();
    final fileUploadService = FileUploadService();

    return MultiProvider(
      providers: [
        // Repository Providers
        Provider.value(value: localStorageRepository),
        Provider.value(value: authenticationService),
        Provider.value(value: chatService),
        Provider.value(value: messageService),
        Provider.value(value: socketService),
        Provider.value(value: fileUploadService),

        // MVVM ViewModels (using ChangeNotifierProvider)
        ChangeNotifierProvider(
          create: (_) =>
              AuthViewModel(authenticationService: authenticationService)
                ..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatListViewModel(chatService: chatService),
        ),

        // BLoC Providers (for complex features like chat conversation)
        BlocProvider(
          create: (_) => ChatConversationBloc(
            messageService: messageService,
            socketService: socketService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3B82F6),
            secondary: Color(0xFF8B5CF6),
            surface: Color(0xFF161B22),
            surfaceContainerHighest: Color(0xFF30363D),
            onSurface: Colors.white,
            onSurfaceVariant: Color(0xFF8B949E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161B22),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF161B22),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF30363D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            hintStyle: const TextStyle(color: Color(0xFF6B6E82)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
                settings: settings,
              );
            case '/chat-list':
              return MaterialPageRoute(
                builder: (context) => const ChatListScreen(),
                settings: settings,
              );
            case '/chat-conversation':
              // Extract arguments for chat conversation screen
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null &&
                  args['chat'] != null &&
                  args['currentUserId'] != null) {
                return MaterialPageRoute(
                  builder: (context) => ChatConversationScreen(
                    chat: args['chat'] as Chat,
                    currentUserId: args['currentUserId'] as String,
                  ),
                  settings: settings,
                );
              }
              // If arguments are invalid, return error screen
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Invalid navigation arguments')),
                ),
              );
            default:
              // Unknown route
              return MaterialPageRoute(
                builder: (context) =>
                    const Scaffold(body: Center(child: Text('Page not found'))),
              );
          }
        },
      ),
    );
  }
}

/// Wrapper widget that handles authentication state and navigation
/// Uses MVVM pattern with AuthViewModel
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Show loading indicator while checking authentication status
        if (authViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate to chat list if authenticated
        if (authViewModel.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/chat-list');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate to login if not authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/login');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
