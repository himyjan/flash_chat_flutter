import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:time/time.dart';
import 'package:flutter_icons/flutter_icons.dart';

final _firestore = Firestore.instance; // 移出來外面讓其他Class可以取用(使用在MessageStream)
FirebaseUser loggedInUser;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin(); // 通知擴充

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  String name;
  String photoUrl;
  String receiverUid;
  ChatScreen({this.name, this.photoUrl, this.receiverUid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText = '';
  File _image;
  

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  // Future upLoadImage(File _image, String email) async {
  //   String fileName = p.extension(_image.path),
  //   StorageReference firebaseStorageRef = FirebaseStorage().ref().child(fileName);
  //   StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
  //   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //   setState(() {
  //     print('Profile Picture uploaded');
  //     Scaffold.of(context).showSnackBar(SnackBar(content: Text('圖片已上傳'),));
  //   });
  // } 

  Future<String> getProfilePictureUrl(String email) async {
  // 用使用者信箱當作索引值去找到對應的文件
    var doc = await Firestore.instance.collection('Users').document(email).get();
    if (doc.exists) {
      return doc.data['profile_picture_url'];
    }
    return '';
  }

  void updateProfilePictureUrl(String email, String url) async {
  // 用使用者信箱當作索引值去新增or更新 圖片路徑
    await Firestore.instance.collection("Users").document(email).setData({
      'profile_picture_url': url,
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();

    // // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // var initializationSettingsAndroid =
    // AndroidInitializationSettings('app_icon');
    // var initializationSettingsIOS = IOSInitializationSettings();
    // var initializationSettings = InitializationSettings(
    //     initializationSettingsAndroid, initializationSettingsIOS);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen(payload)),
    );
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email); // 顯示登入帳號的信箱
      }
    }
    catch (e) {
      print(e);
    }
  }

  // void getMessages() async { 
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var message in messages.documents) {
  //     print(message.data);
  //   }
  // }

  void messagesStream() async { // 這個方法會在資料庫增加新資料時自動取得最新資料
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Ionicons.ios_log_out),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();  // 登出帳戶
                Navigator.pop(context); // 回上一個頁面
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(), // 寫在下面
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController, // 輸入框控制器，含有清空輸入框的功能
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send message functionality.
                      if (messageText != '') {
                        final String currentTime = DateTime.now().toString(); // 取得時間
                        messageTextController.clear(); // 執行輸入框控制器的 清空輸入框
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser.displayName != null ? loggedInUser.displayName : loggedInUser.email,
                          'time': currentTime,
                        });
                        messageText = '';
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  static const mNotificationBar = const MethodChannel('notification_bar.flutter.io/notificationBar'); // 訊息通知
  TextEditingController mControllera = TextEditingController();
  TextEditingController mControllerb = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {  // 如果snapshot中有資料更新訊息
          final messages = snapshot.data.documents.reversed; // 讀取時將訊息翻轉(主要是為了自動向下捲到新訊息)
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];
            final currentTime = message.data['time'];

            final currentUser = loggedInUser.displayName != null ? loggedInUser.displayName :  loggedInUser.email;

            final messageWidget = MessageBubble(
              sender: messageSender,
              text: messageText,
              time: currentTime,
              isMe: currentUser == messageSender, // 建立訊息時，判斷是否是此登入帳號的訊息
            );
            showOngoingNotification(flutterLocalNotificationsPlugin, title: messageSender, body: messageText,);

            messageWidgets.add(messageWidget);
          }
          return Expanded(  // 防止占滿整個畫面，留下位置給頁面其他Widget
              child: ListView(   // 可捲動畫面
              reverse: true, // 將原本翻轉過的訊息再次翻轉回來(主要是為了自動向下捲到新訊息)
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageWidgets,
            ),
          );
        }
        else if (!snapshot.hasData){  // 如果snapshot中沒有資料更新訊息
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender, this.text, this.time, this.isMe}); // 建構子
  final String time;
  String sender;
  final String text;
  final bool isMe;
  
  @override
  Widget build(BuildContext context) {
    if (sender == null) {
      this.sender = '匿名';
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // 透過isMe將訊息分為左右
        children: <Widget>[
          Text(      // 發訊人標籤文字
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Text(      // 發訊人標籤文字    
            time.toString(),
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          
          Material(
            // borderRadius: BorderRadius.circular(30.0),  // 四邊圓角
            borderRadius: isMe ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ) : BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),    // 三邊圓角
            elevation: 5.0,  // 背後的小陰影
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                // '$text from $sender',
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future showOngoingNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  int id = 0,
}) => _showNotification(notifications,
        title: title, body: body, id: id, type: _ongoing);

Future _showNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  @required NotificationDetails type,
  int id = 0,
}) =>
    notifications.show(id, title, body, type);

NotificationDetails get _noSound {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'silent channel id',
    'silent channel name',
    'silent channel description',
    playSound: false,
  );
  final iOSChannelSpecifics = IOSNotificationDetails(presentSound: false);

  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showSilentNotification(
    FlutterLocalNotificationsPlugin notifications, {
      @required String title,
      @required String body,
      int id = 0,
    }) =>
    _showNotification(notifications,
        title: title, body: body, id: id, type: _noSound);

NotificationDetails get _ongoing {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    importance: Importance.Max,
    priority: Priority.High,
    ongoing: true,
    autoCancel: false,
  );
  final iOSChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

class SecondScreen extends StatefulWidget { 
  final String payload;
  SecondScreen(this.payload);
  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  var newsList = {
    1:"Anand Mahindra gets note from 11 year girl to curb noise pollution",
    2:"26 yr old engineer brings 10 pons back to life",
    5:"Donald trump says windmill cause cancer."
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen with payload"),
      ),
      body: Center(
        child: Center(
          child: Text(
            newsList[int.parse(_payload)],
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}