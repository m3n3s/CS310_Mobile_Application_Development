import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/routes/zoomedProfile.dart';
import 'package:cs310_project/utils/bottom_nav.dart';
import 'package:cs310_project/utils/feedPost.dart';
import 'package:cs310_project/utils/locationContainer.dart';
import 'package:cs310_project/utils/photoPostCard.dart';
import 'package:cs310_project/utils/postCard.dart';
import 'package:cs310_project/utils/profilePost.dart';
import 'package:cs310_project/utils/video.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/bottom_nav.dart';
import '../utils/styles.dart';
import 'login.dart';
import 'package:cs310_project/services/auth.dart';
import 'welcome.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';

class OthersProfileView extends StatefulWidget {
  const OthersProfileView({Key key, this.analytics, this.observer, this.username}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final String username ;

  @override
  _OthersProfileViewState createState() => _OthersProfileViewState();
}

class _OthersProfileViewState extends State<OthersProfileView> {
  String _message = '';
  //String profileID, userID;
  String myUsername;
  List <dynamic> marked ;
  FeedPosts post;
  List<FeedPosts> posts;
  bool showProfile ;
  bool isConnected ;
  bool isWaiting ;

  var markedData ;
  final db = FirebaseFirestore.instance;
  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'OthersProfile',
      screenClassOverride: '/othersprofile',
    );
    setmessage('setCurrentScreen succeeded');
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'OthersProfile_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> _getMyUsername() async {
    posts = [];
    showProfile = false;
    isConnected = false;
    isWaiting = false;
    myUsername = await SharedPreferenceHelper().getUserName();
    print("in profile _getMyUsername: myUsername = $myUsername");
    print("myusername: $myUsername");

    List <String> connectionList, waitingList;
    QuerySnapshot val, itr;
    val = await FirebaseFirestore.instance
        .collection('Profile')
        .where('username', isEqualTo: myUsername)
        .get();

    QuerySnapshot val2;
    val2= await FirebaseFirestore.instance
        .collection('Profile')
        .where('username', isEqualTo: widget.username)
        .get();

    print(val);
    connectionList = List.from(val.docs[0]["connections"]);
    waitingList = List.from(val.docs[0]["waitingRequests"]);
    print("waitingList" + waitingList.toString());

    if(waitingList.contains(widget.username))
      isWaiting =true;


    if(connectionList.contains(widget.username)) {
      showProfile = true;
      isConnected = true;
    }
    else
       {

         if(val2.docs[0]["type"] == "public") {
           showProfile = true;
         }
       }

    if(showProfile) {
      marked = val2.docs[0]["marked"];


      print("marked post list" + marked.toString());
      for (int i = 0; i < marked.length; i++) {
        itr = await FirebaseFirestore.instance
            .collection('Posts')
            .where('postID', isEqualTo: marked[i])
            .get();

        posts.add(FeedPosts(
          text: itr.docs[0]["text"],
          date: itr.docs[0]["date"],
          likes: itr.docs[0]["likes"],
          dislikes: itr.docs[0]["dislikes"],
          postID: marked[i],
          location: itr.docs[0]["location"],
          postImageURL: itr.docs[0]["postImageURL"],
          tags: List.from(itr.docs[0]["tags"]),
          username: itr.docs[0]["username"],
          comments: itr.docs[0]["comments"],
          analytics: widget.analytics,
          observer: widget.observer,
        ));
      }
    }

    print ("isWaiting" + isWaiting.toString() + "   isConnected" + isConnected.toString() + "   showProfile" + showProfile.toString()) ;
    setState(() {});
  }

  Future connectionPressed(String type) async {
    String notifID = db.collection("Notifications")
        .doc().id; // gets random doc id
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    QuerySnapshot theirsn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: widget.username).get() ;

    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    if(type=="private"){
      print("in connectionPressed: private, id: " + notifID) ;
      await db.collection("Notifications")
          .doc(notifID)
          .set({
        "fromUsername": myUsername,
        "toUsername": widget.username,
        "createdDate": formattedDate,
        "postID": "1",
        "notificationType": "Connections",
        "notification": "$myUsername sent you a connection request!",
      });
      await FirebaseFirestore.instance.collection("Profile")
          .doc(theirsn.docs[0].id)
          .update({"waitingRequests": FieldValue.arrayUnion([myUsername])});

      await FirebaseFirestore.instance.collection("Profile")
          .doc(mysn.docs[0].id)
          .update({"waitingRequests": FieldValue.arrayUnion([widget.username])});
    }
    else
      {
        String notifID2 = db.collection("Notifications")
            .doc().id;

        await db.collection("Notifications")
            .doc(notifID2)
            .set({
          "fromUsername":widget.username,
          "toUsername": myUsername,
          "createdDate": formattedDate,
          "postID": "2",
          "notificationType": "Connections",
          "notification": "${widget.username} connected with you!",
        });

        print("in connectionPressed: public, id: " + notifID) ;
        await db.collection("Notifications")
            .doc(notifID)
            .set({
          "fromUsername": myUsername,
          "toUsername": widget.username,
          "createdDate": formattedDate,
          "postID": "2",
          "notificationType": "Connections",
          "notification": "$myUsername connected with you!",
        });

        await FirebaseFirestore.instance.collection("Profile")
            .doc(mysn.docs[0].id)
            .update({"connections": FieldValue.arrayUnion([widget.username])});
        await FirebaseFirestore.instance.collection("Profile")
            .doc(theirsn.docs[0].id)
            .update({"connections": FieldValue.arrayUnion([myUsername])});
      }
    setState(() {
      initState();
    });
  }

  _getMarked() async {
    // var data = db.collection("Posts")
    //     .where("postID", isEqualTo: marked[0].toString())
    //    .get().docs[0] ;

    //  DocumentSnapshot val ;
    print("in get marked") ;
    db.collection('Posts')
        .where('postID', isEqualTo: "post4")
        .snapshots().single.then((value) { print("iceride" + value.docs[0].data()["text"]) ; } ) ;

  }

  ImageProvider<Object> showProfilePicture(doc) {
    if (doc["profilePicURL"].toString() != null && doc["profilePicURL"].toString().contains("http"))
      return NetworkImage(doc["profilePicURL"].toString());
    else if (doc["profilePicURL"].toString() != null)
      return MemoryImage(base64.decode(doc["profilePicURL"].toString()));
    //else return Container();
  }

  @override
  void initState() {
    _getMyUsername();
    _setCurrentScreen();
    _setLogEvent();
    _getMarked();
    //getProfileID();
    super.initState();
  }

  Widget postsList(BuildContext context, DocumentSnapshot document) {
    print(document["text"].toString());
    return ListTile(
      title: Card(
        color: AppColors.postCardColor,
        margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                document["text"].toString(),
                style: textStyle,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    document["date"],
                    style: textStyle,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Icon(
                    Icons.thumb_up,
                    size: 14,
                    color: AppColors.headingColor,
                  ),
                  SizedBox(
                    width: 1.0,
                  ),
                  Text(
                    document["likes"].toString(),
                    style: textStyle,
                  ),
                  SizedBox(
                    width: 1.0,
                  ),
                  Icon(
                    Icons.comment,
                    size: 14,
                    color: AppColors.headingColor,
                  ),
                  Text(
                    document["comments"].toString(),
                    style: textStyle,
                  ),
                  SizedBox(
                    width: 1,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget photoList(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Card(
        color: AppColors.postCardColor,
        margin: EdgeInsets.fromLTRB(0, 4, 8, 4),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              //Image.asset('assets/simayprofile.png'),
              if( document["postImageURL"] != null && document["postImageURL"].contains("http"))
                Image.network(document["postImageURL"])
              else if (document["postImageURL"] != null) Image.memory(base64.decode(document["postImageURL"]))
              else Container(),

              Text(
                document["text"] == null ? "no text" : document["text"],
                style: textStyle,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    //'${DateFormat.yMMMd().add_jm().format(document["date"].toDate())}',
                    document["date"],
                    style: textStyle,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Icon(
                    Icons.thumb_up,
                    size: 14,
                    color: AppColors.headingColor,
                  ),
                  SizedBox(
                    width: 1.0,
                  ),
                  Text(
                    document["likes"].toString(),
                    style: textStyle,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Icon(
                    Icons.comment,
                    size: 14,
                    color: AppColors.headingColor,
                  ),
                  Text(
                    document["comments"].toString(),
                    style: textStyle,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  bool reported = false;
  final _keyReportMessage = GlobalKey<FormState>();
  String comment = "";
  String reportMessage = "";
  String name = "";

  Future reportPressed() async{
    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user don't need to tap the button to cancel
      builder: (context) {
        return AlertDialog(
          title: const Text('Why would you like to report this user?'),
          content: SingleChildScrollView(
              child: Form(
                key: _keyReportMessage,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  onSaved: (String value) {
                    reportMessage = value;
                  },
                ),
              )
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Report'),
              onPressed: () async{
                _keyReportMessage.currentState.save();
                print("report message = $reportMessage");

                if(reportMessage != null){
                  final db = FirebaseFirestore.instance;
                  String id = db.collection("Reports")
                      .doc().id; // gets random doc id

                  await db.collection("Reports")
                      .doc(id)
                      .set({
                    "fromUsername": myUsername,
                    "createdDate": formattedDate,
                    "postID": 0,
                    "reportType": "User",
                    "reportedUser": name,
                    "message": reportMessage,
                  });

                  reported = true;
                  String rmessage = reportMessage.toString();
                  String reporter = myUsername;
                  String username = 'turapha19@gmail.com';
                  String password = 'rnjcztahnqbogczj'; // app password for security
                  final smtpServer = gmail(username, password);
                  final message = Message()
                    ..from = Address(username, 'Capturista')
                    ..recipients.add('edemirci@sabanciuniv.edu') //email address of admin
                    ..subject = 'Capturista Report Notification  ${DateTime.now()}'
                    ..text = 'User with username $reporter reported user: $name reason for the report is $rmessage';
                  try {
                    final sendReport = await send(message, smtpServer);
                    print('Message sent: ' + sendReport.toString());
                  } on MailerException catch (e) {
                    print('Message not sent.');
                    for (var p in e.problems) {
                      print('Problem: ${p.code}: ${p.msg}');
                    }
                  }

                  setState(() {});
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: BottomNavigation(),
      backgroundColor: AppColors.backgroundColor,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Profile")
              .where('username', isEqualTo: widget.username)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text("No profile found");

            name = snapshot.data.docs[0]["name"];
            return Padding(
              padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
              child: Column(children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          print("tapped");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => zoomedProfile(url:
                                  snapshot.data.docs[0]["profilePicURL"].toString())));
                        },
                        child: CircleAvatar(
                          // in order to centralize it, wrap with center
                          backgroundColor: Colors.black,
                          backgroundImage: showProfilePicture(snapshot.data.docs[0]),
                          //backgroundImage:  NetworkImage('https://sistersnetwork.de/wp-content/uploads/2018/03/Bildschirmfoto-2018-03-25-um-18.00.42.png'),
                          radius: 40.0,
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  snapshot.data.docs[0]["name"].toString() +
                                      " " +
                                      snapshot.data.docs[0]["lastname"].toString(),
                                  style: headingTextStyle,
                                ),

                                reported ?
                                IconButton(
                                  icon: Icon(Icons.report_problem_outlined),
                                  color: AppColors.primary,
                                  onPressed: reportPressed,
                                )
                                    : IconButton(
                                  icon: Icon(Icons.report_problem_outlined),
                                  color: Colors.grey,
                                  onPressed: reportPressed,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            //puts an empty box between name and username
                            Text(
                              '@' +
                                  snapshot.data.docs[0]["username"].toString(),
                              style: mediumPuntoTextStyle,
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.email,
                                  color: AppColors.primary,
                                ),
                                SizedBox(
                                  width: 8.0,
                                ), //puts an empty box horizontally
                                Text(
                                  snapshot.data.docs[0]["email"].toString(),
                                  style: smallPuntoTextStyle,
                                ),
                              ],
                            ),
                          ]
                      ),

                    ]
                ),
                SizedBox(
                  height: 10,
                ),
                Text(snapshot.data.docs[0]["bio"].toString()),
                if(isConnected) RawMaterialButton(
                    fillColor: AppColors.primary,
                    splashColor: Colors.green,
                  child: Container(
                    width: 110,
                    height: 25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Connected", style: TextStyle(color: Colors.white)),

                        Icon(Icons.check, color:Colors.green),
                      ],
                    ),
                  ),
                    onPressed: () {
                    //TODO: Remove from connection list
                    })
                    else if (isWaiting)  RawMaterialButton(
                    child: Text("Pending Request", style: TextStyle(color: Colors.white)),
                fillColor: AppColors.primary,
                splashColor: Colors.green,
                    onPressed: () {
                      //TODO requesti geri cekme
                    })

                    else if (isWaiting == false && showProfile==false)  RawMaterialButton(
                    child: Text(" Send Connection Request ", style: TextStyle(color: Colors.white)),
                    fillColor: AppColors.primary,
                    splashColor: Colors.green,
                    onPressed: () {
                        connectionPressed("private");
                    })
                else  RawMaterialButton(
                    child: Text("Connect", style: TextStyle(color: Colors.white)),
                fillColor: AppColors.primary,
                splashColor: Colors.green,
                    onPressed: () {
                      connectionPressed("public");
                    }),
                Divider(
                  color: AppColors.captionColor,
                  thickness: 2.0,
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          'Posts',
                          style: textStyle,
                        ),
                        Text(
                          snapshot.data.docs[0]["posts"].length.toString(),
                          style: textStyle,
                        ),
                      ],
                    ),
                    //SizedBox(width: 8.0,),

                    //SizedBox(width: 8.0,),
                    Column(
                      children: <Widget>[
                        Text(
                          'Connections',
                          style: textStyle,
                        ),
                        Text(
                          snapshot.data.docs[0] ["connections"].length.toString(),
                          style: textStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  thickness: 2.0,
                  color: AppColors.captionColor,
                ),
                showProfile ? DefaultTabController(
                  length: 3,
                  child: Expanded(
                    child: Scaffold(
                      backgroundColor: AppColors.backgroundColor,
                      appBar: TabBar(
                        labelColor: AppColors.captionColor,
                        tabs: <Widget>[
                          Tab(child: FittedBox(child: Text("Post"))),
                          Tab(child: FittedBox(child: Text("Photo"))),
                          //Tab(child: FittedBox(child: Text("Video"))),
                          //Tab(child: FittedBox(child: Text("Location"))),
                          Tab(child: FittedBox(child: Text("Marked"))),
                        ],
                      ),
                      body: TabBarView(children: <Widget>[
                        // For 'Posts' tab:
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Posts")
                              .where("username", isEqualTo: widget.username)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData)
                              return const Text("No posts found");
                            return ListView.builder(
                                //itemExtent: 90.0,
                                itemBuilder: (context, i) =>
                                    ProfilePosts(
                                      text: snapshot.data.docs[i]["text"],
                                      date: snapshot.data.docs[i]["date"],
                                      likes: snapshot.data.docs[i]["likes"],
                                      dislikes: snapshot.data.docs[i]["dislikes"],
                                      location: snapshot.data.docs[i]["location"],
                                      postImageURL: snapshot.data.docs[i]["postImageURL"],
                                      tags: List.from(snapshot.data.docs[i]["tags"]),
                                      username: snapshot.data.docs[i]["username"],
                                      comments: snapshot.data.docs[i]["comments"],
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                    ),
                                itemCount: snapshot.data.docs.length);
                          },
                        ),

                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Posts")
                              .where("postImageURL", isNotEqualTo: "")
                              .where("username", isEqualTo: widget.username)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData)
                              return const Text("No posts found");
                            return ListView.builder(
                                itemBuilder: (context, i) =>
                                    ProfilePosts(
                                      text: snapshot.data.docs[i]["text"],
                                      date: snapshot.data.docs[i]["date"],
                                      likes: snapshot.data.docs[i]["likes"],
                                      dislikes: snapshot.data.docs[i]["dislikes"],
                                      location: snapshot.data.docs[i]["location"],
                                      postImageURL: snapshot.data.docs[i]["postImageURL"],
                                      tags: List.from(snapshot.data.docs[i]["tags"]),
                                      username: snapshot.data.docs[i]["username"],
                                      comments: snapshot.data.docs[i]["comments"],
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                    ),
                                itemCount: snapshot.data.docs.length);
                          },
                        ),

                       marked.length!=0 ? ListView.builder(
                            itemBuilder: (context, i){
                              return posts[i];
                            },
                            itemCount: marked.length)
                           : Container(child: Center(child: Text("No marked posts")),),

                      ]),
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height:85,),
                      Icon(Icons.lock_outline_rounded, size: 60,),
                      SizedBox(height:5,),
                      Text("This account is private", style: TextStyle(fontSize: 25,) ),
                      SizedBox(height:8,),
                      Text("Send connection request to see the content of this profile", style: TextStyle(fontSize: 16,) ),
                    ],
                  ),
                ) ,
              ]),
            );
          }
      ),
    );
  }
}
