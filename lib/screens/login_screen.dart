import 'package:flutter/material.dart';
import 'package:flash_chat/conponents/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String? id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _firebaseAuth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool showLoading = false;

  // bool isLoggedInGithub = false;
  // bool isLoggedInTwitter = false;

  // void _signInWithGithub() async {
  //   final AuthCredential credential = GithubAuthProvider.credential(
  //     token: _tokenController.text,
  //   );
  //   final User user =
  //       (await _firebaseAuth.signInWithCredential(credential)).user;
  //   assert(user.email != null);
  //   assert(user.displayName != null);
  //   assert(!user.isAnonymous);
  //   assert(await user.getIdToken() != null);

  //   final User currentUser = await _firebaseAuth.currentUser!;
  //   assert(user.uid == currentUser.uid);
  //   setState(() {
  //     if (user != null) {
  //       // _message = 'Successfully signed in with Github. ' + user.uid;
  //       isLoggedInGithub = true;
  //       print('登入Github帳號成功');
  //       Navigator.pushNamed(context, ChatScreen.id);
  //     } else {
  //       // _message = 'Failed to sign in with Github. ';
  //       isLoggedInGithub = false;
  //       print('登入Github帳號失敗');
  //     }
  //   });
  // }

  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _tokenSecretController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showLoading, // 透過bool變數控制載入畫面
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                // 自動調整大小以免畫面超出螢幕
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
                controller: _tokenController,
                keyboardType: TextInputType.emailAddress, // 限制輸入文字的類型為email
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText:
                        '請輸入登入信箱'), // 方法寫在 constants.dart中 並使用copywith更改預設屬性
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _tokenSecretController,
                obscureText: true, // 隱藏輸入的密碼
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText:
                        '請輸入登入密碼'), // 方法寫在 constants.dart中 並使用copywith更改預設屬性
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: '使用信箱登入',
                color: Colors.lightBlueAccent,
                onPressed: () async {
                  //Implement login functionality.
                  // print(email);
                  // print(password);
                  setState(() {
                    showLoading = true; // 透過改變bool變數控制載入畫面
                  });
                  try {
                    final newUser =
                        await _firebaseAuth.signInWithEmailAndPassword(
                            email: email!, password: password!);
                    if (newUser != null) {
                      Navigator.pushNamed(context, ChatScreen.id!);
                    }
                  } catch (e) {
                    print(e);
                  }
                  setState(() {
                    showLoading = false; // 透過改變bool變數控制載入畫面
                  });
                },
              ),
              // RoundedButton(
              //   title: '使用Github登入',
              //   color: Colors.blueGrey,
              //   onPressed: () => _signInWithGithub(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
