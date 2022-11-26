import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/all_users_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/firebase/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: FlashChat()));
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return WelcomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'LoginScreen',
          builder: (BuildContext context, GoRouterState state) {
            return LoginScreen();
          },
        ),
        GoRoute(
          path: 'RegistrationScreen',
          builder: (BuildContext context, GoRouterState state) {
            return RegistrationScreen();
          },
        ),
        GoRoute(
          path: 'AllUsersScreen',
          builder: (BuildContext context, GoRouterState state) {
            return AllUsersScreen();
          },
        ),
        GoRoute(
          path: 'ChatScreen',
          builder: (BuildContext context, GoRouterState state) {
            return ChatScreen();
          },
        ),
      ],
    ),
  ],
);

class FlashChat extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // 取消顯示右上角debug標籤
      routerConfig: _router,
    );
  }
}
