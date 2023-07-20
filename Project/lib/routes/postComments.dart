import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/commentContainer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';

class PostComments extends StatefulWidget {
  const PostComments({Key key, this.analytics, this.observer, this.postID})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final String postID;

  @override
  _PostCommentsState createState() => _PostCommentsState();
}

class _PostCommentsState extends State<PostComments> {
  String _message = '';

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Post Comments',
      screenClassOverride: '/postComments',
    );
    setmessage('setCurrentScreen succeeded');
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Postcomments_log',
    );
    setmessage('Custom event log succeeded');
  }

  @override
  void initState() {
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Comments")
            .where("postID", isEqualTo: widget.postID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                child: Text("No comments!"),
              ),
            );
          }

          // data exists in snapshot
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, i) {
              DocumentSnapshot ds = snapshot.data.docs[i];

              return CommentContainer(
                comment: ds["comment"],
                date: ds["createdDate"],
                username: ds["fromUser"],
              );
            },
          );
        },
      ),
    );
  }
}
