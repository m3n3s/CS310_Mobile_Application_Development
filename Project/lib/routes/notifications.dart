import 'package:cs310_project/utils/bottom_nav.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';

import 'notificationPost.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key key, this.analytics, this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String myUsername;
  String _message = '';
  final databaseReference = FirebaseFirestore.instance;
  final db = FirebaseFirestore.instance;

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Notifications',
      screenClassOverride: '/notifications',
    );
    setmessage('setCurrentScreen succeeded');
    // print(files);
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Notifications_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> _getMyUsername() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    print("notifications _getMyUserName: myUsername = $myUsername");
  }

  Future<void> onAccept(String username, String notDocID) async {
    print("not to be deleted in onAccept is : " + notDocID ) ;
    String notifID = db.collection("Notifications")
        .doc().id; // gets random doc id
    QuerySnapshot mySN = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    QuerySnapshot theirSN = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: username).get() ;

    //Remove from notifications
    if(notDocID != '') {
      await FirebaseFirestore.instance.collection("Notifications")
          .doc(notDocID)
          .delete();
    }
    //Remove from waiting connection requests
    await FirebaseFirestore.instance.collection("Profile")
        .doc(theirSN.docs[0].id)
        .update({"waitingRequests": FieldValue.arrayRemove([myUsername])});
    await FirebaseFirestore.instance.collection("Profile")
        .doc(mySN.docs[0].id)
        .update({"waitingRequests": FieldValue.arrayRemove([username])});

    await FirebaseFirestore.instance.collection("Profile")
        .doc(theirSN.docs[0].id)
        .update({"connections": FieldValue.arrayUnion([myUsername])});
    await FirebaseFirestore.instance.collection("Profile")
        .doc(mySN.docs[0].id)
        .update({"connections": FieldValue.arrayUnion([username])});

    // send connection notification
    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    String notifID2 = db.collection("Notifications")
        .doc().id; // gets random doc id
    await db.collection("Notifications")
        .doc(notifID)
        .set({
      "fromUsername":username,
      "toUsername": myUsername,
      "createdDate": formattedDate,
      "postID": "2",
      "notificationType": "Connections",
      "notification": "$username connected with you!",
    });

    await db.collection("Notifications")
        .doc(notifID2)
        .set({
      "fromUsername": myUsername,
      "toUsername": username,
      "createdDate": formattedDate,
      "postID": "2",
      "notificationType": "Connections",
      "notification": "$myUsername connected with you!",
    });

    setState(() {

    });

  }
  Future<void> onDecline(String username, String notDocID) async {
    print("not to be deleted in onDeclin is : " + notDocID ) ;
    QuerySnapshot mySN = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    QuerySnapshot theirSN = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: username).get() ;

    //Remove from notifications
    if(notDocID != '') {
      await FirebaseFirestore.instance.collection("Notifications")
          .doc(notDocID)
          .delete();
    }
    //Remove from waiting connection requests
    await FirebaseFirestore.instance.collection("Profile")
        .doc(theirSN.docs[0].id)
        .update({"waitingRequests": FieldValue.arrayRemove([myUsername])});
    await FirebaseFirestore.instance.collection("Profile")
        .doc(mySN.docs[0].id)
        .update({"waitingRequests": FieldValue.arrayRemove([username])});

    setState(() {

    });
  }


  @override
  void initState() {
    _getMyUsername();
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigation(),
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
            color: AppColors.headingColor,
            fontWeight: FontWeight.w900,
            fontSize: 30.0,
            letterSpacing: -0.7,
            fontFamily: 'OpenSans',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Notifications")
              .where('toUsername', isEqualTo: myUsername)
              .snapshots(),

         builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text("No notifications found");

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {

                    String postID = snapshot.data.docs[index]["postID"];
                    print("POSTID = $postID");
                    if(snapshot.data.docs[index]["notificationType"] != "Connections") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationPost(
                                postID: postID,
                              ),
                        ),
                      );
                    }
                  },
                  splashColor: Colors.green,
                  child: Card(
                    margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                if (snapshot.data.docs[index]
                                        ["notificationType"] ==
                                    "Likes/Dislikes")
                                  Icon(Icons.thumbs_up_down,
                                      color: AppColors.secondary, size: 30),
                                if (snapshot.data.docs[index]
                                        ["notificationType"] ==
                                    "Comment")
                                  Icon(Icons.comment,
                                      color: AppColors.secondary, size: 30),
                                if (snapshot.data.docs[index]
                                        ["notificationType"] ==
                                    "Reshare")
                                  Icon(Icons.repeat,
                                      color: AppColors.secondary, size: 30),
                                if (snapshot.data.docs[index]
                                        ["notificationType"] ==
                                    "Connections")
                                  Icon(Icons.person,
                                      color: AppColors.secondary, size: 30),
                                if (snapshot.data.docs[index]
                                        ["notificationType"] ==
                                    "Direct Messages")
                                  Icon(Icons.send,
                                      color: AppColors.secondary, size: 30),
                              ],
                            ),
                            SizedBox(width: 20),

                            //SizedBox (width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        '${snapshot.data.docs[index]["notification"]}',
                                        style: TextStyle(
                                          fontSize: 15,
                                        )),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      //'${DateFormat.yMMMd().add_jm().format(snapshot.data.docs[index]["createdDate"].toDate())}',
                                      snapshot.data.docs[index]["createdDate"],
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                if(snapshot.data.docs[index]
                                ["notificationType"] ==
                                    "Connections" && snapshot.data.docs[index]
                                ["postID"] =="1" ) Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RawMaterialButton(
                                      child: Text("Accept"),
                                      fillColor: Colors.lightGreenAccent,
                                      onPressed: () {
                                        print("not to be deleted is: " + snapshot.data.docs[index].id ) ;
                                        //TODO: Send notification the request sender and remove from both waitingRequests lists
                                        onAccept (snapshot.data.docs[index]["fromUsername"], snapshot.data.docs[index].id);
                                      },
                                    ),
                                    SizedBox(width: 10),

                                    RawMaterialButton(
                                      child: Text("Decline"),
                                      fillColor: Colors.redAccent,
                                      //TODO: Send notification the request sender and remove from both waitingRequests lists
                                      onPressed: ()
                                      {
                                        print("not to be deleted is: " + snapshot.data.docs[index].id ) ;
                                        onDecline (snapshot.data.docs[index]["fromUsername"], snapshot.data.docs[index].id);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        )),
                  ),
                );
              },
            );
          }),
      //)
    );
  }
}
