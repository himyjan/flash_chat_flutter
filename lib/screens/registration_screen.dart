import 'package:flutter/material.dart';
import 'package:flash_chat/conponents/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(         // 自動調整大小以免畫面超出螢幕
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress, // 限制輸入文字的類型為email
              textAlign: TextAlign.center,
              onChanged: (value) {
                //Do something with the user input.
                email = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: '請輸入註冊信箱'), // 方法寫在 constants.dart中 並使用copywith更改預設屬性
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              obscureText: true,         // 隱藏輸入的密碼
              textAlign: TextAlign.center,
              onChanged: (value) {
                //Do something with the user input.
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: '請輸入註冊密碼'), // 方法寫在 constants.dart中 並使用copywith更改預設屬性
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: '註冊',
              color: Colors.blueAccent,
              onPressed: () async {
                //Implement login functionality.
                // print(email);
                // print(password);
                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                  if (newUser != null) {
                    Navigator.pushNamed(context, ChatScreen.id);
                  }
                }
                catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
