import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'chat_screen.dart';
import 'package:flash_chat/conponents/rounded_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'dart:developer' as logger;
import 'dart:io' show Platform;
import 'package:auth_buttons/auth_buttons.dart';

class WelcomeScreen extends StatefulWidget {
  static const String? id = 'wellcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool isLoggedInGoogle = false;
  bool isLoggedInFacebook = false;
  bool isLoggedInTwitter = false;
  late Map userProfile;

  late AnimationController controller;
  late Animation animation;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late GoogleSignInAccount _currentUser;

  // Future<User> initiateGoogleLogin(BuildContext context) async {
  //   // Scaffold.of(context).showSnackBar(),
  // }

  void _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final User? user =
        (await _firebaseAuth.signInWithCredential(credential)).user;
    assert(user?.email != null);
    assert(user?.displayName != null);
    assert(!user!.isAnonymous);
    assert(await user?.getIdToken() != null);

    final User? currentUser = await _firebaseAuth.currentUser!;
    assert(user?.uid == currentUser?.uid);
    setState(() {
      if (user != null) {
        isLoggedInGoogle = true;
        print('登入Google帳號成功');
        context.go('/ChatScreen');
        // _userID = user.uid;
        print(user.uid);
      } else {
        isLoggedInGoogle = false;
      }
    });
  }

  // void _signInWithFacebook() async {
  //   // 影片教學 https://www.youtube.com/watch?v=bD-BdZ376_c
  //   var facebookLogin = FacebookLogin();
  //   var result = await facebookLogin.logIn(['email']);
  //   bool isLoggedIn = result == FacebookLoginStatus.loggedIn;
  //   print('$isLoggedIn');
  //   switch (result.status) {
  //     case FacebookLoginStatus.error:
  //       setState(() => isLoggedIn = false);
  //       print('FacebookLoginStatus.error');
  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       setState(() => isLoggedIn = false);
  //       print('FacebookLoginStatus.cancelledByUser');
  //       break;
  //     case FacebookLoginStatus.loggedIn:
  //       final token = result.accessToken.token;
  //       final graphResponse = await http.get(Uri.parse(
  //           'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}'));
  //       final profile = JSON.jsonDecode(graphResponse.body);
  //       AuthCredential credential = FacebookAuthProvider.credential(token);
  //       var user = await FirebaseAuth.instance.signInWithCredential(credential);
  //       setState(() {
  //         userProfile = profile;
  //         isLoggedIn = true;
  //       });
  //       print('登入Facebook帳號成功');
  //       context.go('/ChatScreen');
  //       break;
  //   }
  // }

  // void _signInWithTwitter() async {
  //   var twitterLogin = new TwitterLogin(
  //     consumerKey: 'RXJ6YY8Sd1Y1Qu2Y6LTJNDjX8',
  //     consumerSecret: 'ABrRtbeSNqXQeGM6gQIY0uUNo5E9kKMOi1PTKh9hiWiKkLOex6',
  //   );

  //   final TwitterLoginResult result = await twitterLogin.authorize();

  //   switch (result.status) {
  //     case TwitterLoginStatus.loggedIn:
  //       var session = result.session;
  //       // _sendTokenAndSecretToServer(session.token, session.secret);
  //       AuthCredential credential = TwitterAuthProvider.credential(
  //         accessToken: result.session.token,
  //         secret: result.session.secret,
  //       );

  //       FirebaseAuth.instance
  //           .signInWithCredential(credential)
  //           .then((signedInUser) {
  //         context.go('/ChatScreen');
  //         // Navigator.of(context).pushReplacementNamed('/login_screen');
  //       }).catchError((e) {
  //         print(e);
  //       });
  //       break;
  //     case TwitterLoginStatus.cancelledByUser:
  //       // _showCancelMessage();
  //       break;
  //     case TwitterLoginStatus.error:
  //       // _showErrorMessage(result.error);
  //       break;
  //   }
  // }

  // Example code of how to sign in anonymously.
  void _signInAnonymously() async {
    final User? user = (await _firebaseAuth.signInAnonymously()).user;
    assert(user != null);
    assert(user!.isAnonymous);
    assert(!user!.emailVerified);
    assert(await user!.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user!.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      print(user);
      // assert(user?.providerData.length == 1);
      // assert(user?.providerId == 'firebase');
      assert(user?.uid != null);
      // assert(user?.displayName == null);
      assert(user?.photoURL == null);
      // assert(user?.email == null);
    }

    final User currentUser = await _firebaseAuth.currentUser!;
    assert(user!.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        // _success = true;
        // _userID = user.uid;
        print('匿名登入成功');
        context.go('/ChatScreen');
      } else {
        // _success = false;
        print('匿名登入失敗');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
      // upperBound: 1.0,
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    controller.forward();
    // controller.reverse(from: 1.0);

    animation.addStatusListener((status) {
      // print(status); // 顯示AnimationStatus的狀態是 dismissed 或 forward 或 completed
      if (status == AnimationStatus.completed) {
        controller.reverse(from: 1.0);
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.addListener(() {
      setState(() {});
      // logger.log(controller.value);  // 顯示數值
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 顏色透明Colors.red.withOpacity(0~1的數值))
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  // 自動調整大小以免畫面超出螢幕
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: animation.value * 55,
                    ),
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chat 聊天室 ${(animation.value * 100).toInt()}%',
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                      ),
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                  totalRepeatCount: 4,
                  pause: const Duration(milliseconds: 100),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            // 使用匿名登入
            RoundedButton(
              title: '使用匿名登入',
              color: Colors.deepOrange,
              onPressed: () => _signInAnonymously(),
            ),
            // 使用Google登入
            GoogleAuthButton(
              onPressed: () => _signInWithGoogle(),
              themeMode: ThemeMode.dark,
            ),
            // 使用Google登入
            isLoggedInFacebook
                ? Column(
                    children: <Widget>[
                      Image.network(
                        userProfile["picture"]["data"]["url"],
                        height: 50.0,
                        width: 50.0,
                      ),
                      Text(userProfile["name"]),
                      OutlinedButton(
                        child: Text("Logout"),
                        onPressed: () {
                          setState(() {
                            isLoggedInFacebook = false;
                          });
                        },
                      )
                    ],
                  )
                : FacebookAuthButton(
                    onPressed: () => null,
                  ),
            // 使用Twitter登入
            TwitterAuthButton(
              onPressed: () => null,
            ),
            RoundedButton(
              // 這個函式有整理在 conponents/rounded_button.dart
              title: "其他登入",
              color: Colors.lightBlueAccent,
              onPressed: () {
                return context.go('/LoginScreen');
              },
            ),
            RoundedButton(
              // 這個函式有整理在 conponents/rounded_button.dart
              title: "註冊帳號",
              color: Colors.blueAccent,
              onPressed: () {
                //Go to registration screen.
                return context.go('/RegistrationScreen');
              },
            ),
            Container(
              alignment: Alignment.center,
              child: Text('請選擇登入方式'),
            ),
          ],
        ),
      ),
    );
  }
}
