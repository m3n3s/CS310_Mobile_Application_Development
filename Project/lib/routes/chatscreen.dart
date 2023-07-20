import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/routes/chats.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';
import 'package:random_string/random_string.dart';
import 'package:cs310_project/services/database.dart';
import '../utils/colors.dart';
import 'package:cs310_project/services/database.dart';

class ChatScreen extends StatefulWidget{
  final String chatWithUsername;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  ChatScreen(this.chatWithUsername, this.analytics, this.observer);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>{

  String chatRoomId, messageId = "";
  Stream messageStream;
  String myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  String _message = '';

  void setMessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Chatscreen_log',
    );
    setMessage('Custom event log succeeded');
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'ChatScreen',
      screenClassOverride: '/chatscreen',
    );
    setMessage('setCurrentScreen succeeded');
  }

  getMyInfoFromSharedPreference() async{
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdByUsernames(myUserName, widget.chatWithUsername);
  }

  getChatRoomIdByUsernames(String a, String b){
    if(a.substring(0,1).codeUnitAt(0)> b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    }
    else{
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendByMe){
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal:16, vertical: 4),
          //color: Colors.indigo.shade900,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight:
              sendByMe ? Radius.circular(0) : Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft:
              sendByMe ? Radius.circular(24) : Radius.circular(0),
              ),
              color: sendByMe ? Colors.blueGrey.shade900 : Colors.deepPurple.shade800 ,
            ),
          padding: EdgeInsets.all(16),
            child: Text(message, style: TextStyle(color: Colors.white),)),
        Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: sendByMe ? Container(
            height:12,
            width: 12,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              shape:BoxShape.circle,
            ),
            child:  Icon(Icons.done, size:8, color:AppColors.backgroundColor),

          ) : Container(),
        )
      ],
    );
  }

  Widget chatMessages()
  {
    return StreamBuilder(
     stream: messageStream,
     builder: (context,snapshot){
       return snapshot.hasData ? ListView.builder(
         padding: EdgeInsets.only(bottom:80),
           itemCount:snapshot.data.docs.length ,
           reverse: true,
           itemBuilder: (context,index){
             DocumentSnapshot ds = snapshot.data.docs[index];
             return chatMessageTile(ds["message"], myUserName == ds["sendBy"]);
           }
           ): Center(child: CircularProgressIndicator());
     },
    );
  }

  getAndSetMessages()async{
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  addMessage(bool sendClicked){
    if(messageTextEditingController.text != ""){
      String message  = messageTextEditingController.text;
      var lastMessageTs = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "message" : message,
        "sendBy" : myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      //messageid
      if(messageId ==""){
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods().addMessage(chatRoomId,messageId,messageInfoMap)
      .then((value){
        Map<String,dynamic> lastMessageInfoMap = {
          "lastMessage" : message,
          "lastMessageSendTs" : lastMessageTs,
          "lastMessageSendBy": myUserName
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);
        if(sendClicked){
          //remove the text in the message input field
          messageTextEditingController.text= "";
          // make message id blank to get regenerated on next message send
          messageId = "";
        }
      });
    }
  }

  doThisOnLaunch() async{
   await getMyInfoFromSharedPreference();
   getAndSetMessages();
  }

  @override
  void initState()
  {
    doThisOnLaunch();
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.email),
              backgroundColor: Colors.deepPurple.shade800,
            ),
            SizedBox(width: 8.0,),
            Column( children: [Text(widget.chatWithUsername)],)
          ],

        ), //Text(widget.name),
      ),
      body: Container(child: Stack(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.brown.withOpacity(0.3),
              padding: EdgeInsets.symmetric(horizontal: 6,vertical: 8),
              child: Row(
                children:
                [Expanded(
                    child: TextField(
                      controller: messageTextEditingController,
                      onChanged: (value){
                        addMessage(false);
                      },
                      decoration:
                      InputDecoration(
                          border: InputBorder.none
                ,hintText: "type a message",
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.w700)
                      ),
                    ),
                ),
                GestureDetector(
                  onTap: () {
                    addMessage(true);
                  },
                    child: Icon(Icons.send, color: Colors.white))
              ],),
            ),
          )
        ],
      ),),
    );
  }
}