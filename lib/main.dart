import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 取消顯示右上角debug標籤
      home: WelcomeScreen(),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id!: (context) => WelcomeScreen(),
        LoginScreen.id!: (context) => LoginScreen(),
        RegistrationScreen.id!: (context) => RegistrationScreen(),
        AllUsersScreen.id!: (context) => AllUsersScreen(),
        ChatScreen.id!: (context) => ChatScreen(),
      },
    );
  }
}
