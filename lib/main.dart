import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/all_users_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
// import 'package:firebase_ui_oauth_twitter/firebase_ui_oauth_twitter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/firebase/user_repository.dart';

final actionCodeSettings = ActionCodeSettings(
  url: 'https://flutterfire-e2e-tests.firebaseapp.com',
  handleCodeInApp: true,
  androidMinimumVersion: '1',
  androidPackageName: 'io.flutter.plugins.firebase_ui.firebase_ui_example',
  iOSBundleId: 'io.flutter.plugins.fireabaseUiExample',
);
final emailLinkProviderConfig = EmailLinkAuthProvider(
  actionCodeSettings: actionCodeSettings,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseUIAuth.configureProviders([
    // EmailAuthProvider(),
    // emailLinkProviderConfig,
    // PhoneAuthProvider(),
    GoogleProvider(
        clientId:
            '951790744962-b42jfptvae0m3jqnm5qmf642oot53d9e.apps.googleusercontent.com',
        redirectUri:
            'https://flutter-flash-chat-a4db3.firebaseapp.com/__/auth/handler'),
    AppleProvider(),
    FacebookProvider(
        clientId: '772812439873865',
        redirectUri:
            'https://flutter-flash-chat-a4db3.firebaseapp.com/__/auth/handler'),
    // TwitterProvider(
    //   apiKey: 'RXJ6YY8Sd1Y1Qu2Y6LTJNDjX8',
    //   apiSecretKey: 'ABrRtbeSNqXQeGM6gQIY0uUNo5E9kKMOi1PTKh9hiWiKkLOex6',
    //   redirectUri:
    //       'https://flutter-flash-chat-a4db3.firebaseapp.com/__/auth/handler',
    // ),
  ]);

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
