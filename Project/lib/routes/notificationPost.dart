import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/model/comment_class.dart';
import 'package:cs310_project/routes/searchresultprofiles.dart';
import 'package:cs310_project/utils/bottom_nav.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:cs310_project/model/profile_class.dart';
import 'package:cs310_project/utils/feedPost.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:intl/intl.dart';

class NotificationPost extends StatefulWidget {
  const NotificationPost({Key key, this.analytics, this.observer, this.postID})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final String postID;

  @override
  _NotificationPostState createState() => _NotificationPostState();
}

class _NotificationPostState extends State<NotificationPost> {
  final fb = FirebaseFirestore.instance;
  final db = FirebaseFirestore.instance;
  String _message = '';
  String username;
  String pic;
  String fromUsername;
  String fromUsernamePic;
  List<Widget> post_containers;
  List<Comment> commentList = [];

  void setMessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  /*
  void dosomething() {
    db
        .collection("Comments")
        .where("post",
            isEqualTo: FirebaseFirestore.instance
                .collection("Post")
                .doc(widget.postID))
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // doc.data() is never undefined for query doc snapshots
        print(doc.id + " => " + "${doc.data()["comment"]}");
        var fromUser = FirebaseFirestore.instance
            .collection("Profile")
            .doc(doc.data()['fromUser'].path.toString().substring(8));
        fromUser
            .get()
            .then((doc2) => {
                  if (doc2.exists)
                    {
                      fromUsername = doc2.data()["username"],
                      fromUsernamePic = doc2.data()["profilePicURL"],
                      // print ("from user icinde"),
                      // print (fromUsername),
                      // print (fromUsernamePic),

                      commentList.add(Comment(
                        text: doc.data()["comment"],
                        date: doc.data()['createdDate'].toDate().toString(),
                        user: Profile(
                          username: fromUsername,
                          profilePicURL: fromUsernamePic,
                        ),
                      )),
                      // print("comment listin lengthi ${commentList.length}"),
                    }
                })
            .catchError((error) => {
                  print("error"),
                });
      });
    });

    var data = FirebaseFirestore.instance
        .collection("Profile")
        .doc('6LfoijN7UntcCewBHqFZ');

    data
        .get()
        .then((doc) => {
              if (doc.exists) username = doc.data()["username"],
              //  print("username" + doc.data()["username"]),
              pic = doc.data()["profilePicURL"],
            })
        .catchError((error) => {
              print("error"),
            });

    setState(() {});
  }
  */

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'NotificationPost',
      screenClassOverride: 'NotificationPost',
    );
    setMessage('setCurrentScreen succeeded');
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Notificationpost_log',
    );
    setMessage('Custom event log succeeded');
  }

  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setCurrentScreen();
    _setLogEvent();
    //dosomething();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> postContainers;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
        ),
        bottomNavigationBar: BottomNavigation(),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Posts")
                      .doc(widget.postID)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) return const Text("No post found");
                    return ListView.separated(
                      itemBuilder: (context, i) => FeedPosts(
                        text: snapshot.data.get("text"),
                        postImageURL: snapshot.data.get("postImageURL"),
                        //date: snapshot.data.get("createdDate"),
                        date: "12.09.2101",
                            //'${DateFormat.yMMMd().add_jm().format(snapshot.data.get("date").toDate())}',
                        location: "istanbul",//"${snapshot.data.get("location").latitude}" +
                            //" " +
                            //"${snapshot.data.get("location").longitude}",
                        //tags: ["hawk", "photography", "close-up"],
                        tags: snapshot.data.get("tags"),
                        username: snapshot.data.get("username"),
                        //commentList: commentList,
                        comments: snapshot.data.get("comments"),
                        postID: widget.postID,
                        likes: snapshot.data.get("likes"),
                        dislikes: snapshot.data.get("dislikes"),
                      ),
                      separatorBuilder: (context, i) => Divider(),
                      itemCount: 1,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
