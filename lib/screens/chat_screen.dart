
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser; // email과 passwrod가 들어감.

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    try{
      //현재 유저정보 가져오기
      final user = await _auth.currentUser();
      if(user!=null){
        loggedInUser=user;
      }
    }catch(e){
      print(e);
    }
  }

  //getDocuments로 받으면 실시간 적용이 안된다.
//  void getMessages() async{
//    final messages =  await _fireStore.collection('messages').getDocuments();
//    //messages.documents은 listview
//    for(var meesage in messages.documents){
//      print(meesage.data);//message.data= >  {sender: giyo1128@email.com, text: hello }
//    }
//  }

  //snapshots은 stream임. stream으로 받으면 기다리지 않고 변화가 생기면 바로바로 변경함.
  //_fireStore.collection('messages').snapshots()은 list임
//  void messageStream() async {
//    await for(var snaphost in _fireStore.collection('messages').snapshots()){//collection
//      for(var message in snaphost.documents){//documents
//        //print(message.data);//내용
//      }
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
          IconButton(
            //로그아웃버튼
            icon: FaIcon(FontAwesomeIcons.doorOpen),
              onPressed: () {
//                messageStream();
                _auth.signOut();
               Navigator.pop(context);
              }),
        ],
        title: Text('채팅내용'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //채팅 내용
            MessageStream(),
            //인풋버튼
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      //컨트롤러를 관리하에 두고 버튼을 누르면 지워지도록 설정
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'text':messageText,
                        'sender':loggedInUser.email,
                        'timestamp' : DateTime.now().millisecondsSinceEpoch,
                      });
                    },
                    icon: FaIcon(FontAwesomeIcons.paperPlane, color: Colors.lightBlue,),
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
  @override
  Widget build(BuildContext context) {
    return    StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').snapshots(),//snapshots가 stream임
      builder:  (context, snapshot){
        if(!snapshot.hasData){
          return Container(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }//hasData는 bool값, true or false

        //reversed는 마지막 부분으로 최신화면을 보여주기 위해 사용함.
        final messages = snapshot.data.documents; //document총괄 (파베 가운데)

        List<MessageBubble> messageBubbles =[];
        for (var message in messages){
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          final messageTimeStamp = message.data['timestamp'].toString();

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser==messageSender,
            timeStamp: messageTimeStamp,
          );
             messageBubbles.add(messageBubble);
             messageBubbles.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

        }
        return Expanded(
          child: ListView(
            //텍스트 리스트뷰를 만들고 텍스트 위젯을 넣어서 컬럼에다가 넣는다.
            //column도 []시작하니 listview인것
            reverse: true,//맨 아래부터 글이 나오도록
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children:messageBubbles,
          ),
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {

  final String sender;
  final String text;
  final String timeStamp;
  final bool isMe;

  const MessageBubble({Key key, this.sender, this.text, this.timeStamp, this.isMe}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender, style: TextStyle(fontSize: 12.0, color: Colors.black45),),
          Material(
            borderRadius:
            isMe ?
            BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            )
            :
            BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                  '$text',
              style: TextStyle(
                  fontSize: 15.0,
                color: isMe ? Colors.white : Colors.black,
              ),),
            ),

          ),
        ],
      ),
    );
  }
}
