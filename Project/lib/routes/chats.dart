import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/utils/bottom_nav.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:cs310_project/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dimension.dart';
import 'package:cs310_project/routes/chatscreen.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';

class Chats extends StatefulWidget {
  const Chats({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  bool isSearching = false;
  Stream usersStream;
  String myProfilePic, myUsername, myEmail;
  Stream chatRoomsStream;
  TextEditingController searchUsernameEditingController =
      TextEditingController();

  @override
  void initState() {
    onScreenLoaded();
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }

  String _message = '';

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Chats',
      screenClassOverride: '/chats',
    );
    setmessage('setCurrentScreen succeeded');
  }

  Future<void> getMyInfoFromSharedPreference() async {
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUsername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        ChatRoomListTile(ds["lastMessage"], ds.id, myUsername, widget.analytics, widget.observer),
                  );
                })
            : Center(child: Text("No chats found!"));
      },
    );
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);
    setState(() {});
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUsername, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUsername, username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(username, widget.analytics, widget.observer)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: profileUrl.contains("http") ? Image.network(
              profileUrl,
              height: 50,
              width: 50,
            ):  Image.memory(
              base64.decode(profileUrl),
              height: 50,
              width: 50,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                email,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                    profileUrl: ds["imgUrl"],
                    email: ds["email"],
                    username: ds["username"],
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Chats_log',
    );
    setmessage('Custom event log succeeded');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
      automaticallyImplyLeading: false,
        title: Center(child: Text("Messages")),
      ),*/
      bottomNavigationBar: BottomNavigation(),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 12,
                  ),
                  isSearching
                      ? GestureDetector(
                          onTap: () {
                            isSearching = false;
                            searchUsernameEditingController.text = "";
                            setState(() {});
                          },
                          child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_back_sharp)),
                        )
                      : Container(),
                  Expanded(
                    child: Container(
                      //margin: EdgeInsets.symmetric(vertical: 30),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey,
                            width: 2.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: searchUsernameEditingController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search for People"),
                          )),
                          GestureDetector(
                              onTap: () {
                                if (searchUsernameEditingController.text !=
                                    "") {
                                  onSearchBtnClick();
                                }
                              },
                              child: Icon(Icons.search))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 35,
              ),
              isSearching ? searchUsersList() : chatRoomsList()
            ],
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername, this.analytics, this.observer);
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  String _message = '';

  void setMessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Chatroom_log',
    );
    setMessage('Custom event log succeeded');
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'ChatRoom',
      screenClassOverride: '/chats',
    );
    setMessage('setCurrentScreen succeeded');
  }

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);

    name = "${querySnapshot.docs[0]["username"]}";
    profilePicUrl = "${querySnapshot.docs[0]["profilePicURL"]}";

    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(username, widget.analytics, widget.observer)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: profilePicUrl.contains("http") ? Image.network(
              profilePicUrl,
              height: 40,
              width: 40,
            ):
                Image.memory(
                  base64.decode(profilePicUrl),
                  height: 40,
                  width: 40,
                ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 3,
              ),
              Text(widget.lastMessage)
            ],
          ),
        ],
      ),
    );
  }
}
