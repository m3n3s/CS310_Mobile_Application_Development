import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/routes/othersProfilePage.dart';
import 'package:cs310_project/routes/postComments.dart';
import 'package:cs310_project/routes/profile.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:http/http.dart';
import 'colors.dart';
import 'styles.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class FeedPosts extends StatefulWidget {
  FeedPosts(
      {this.text = "",
      this.date = "",
      this.likes = 0,
      this.dislikes = 0,
      this.postID = "",
      this.comments = 0,
      this.location = "",
      this.postImageURL = "",
      this.tags,
      this.username = "",
      this.myUsername = "",
      this.analytics,
      this.observer});

  final String text;
  final String date;
  final int likes;
  final int dislikes;
  final int comments; // Number of comments
  final String postID;
  final String location;
  final List tags;
  final String postImageURL;
  final String username; //username of the one who posted this post
  final String myUsername;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _FeedPostsState createState() => _FeedPostsState();
}

class _FeedPostsState extends State<FeedPosts> {
  TextEditingController messageTextEditingController = TextEditingController();
  final _keyComment = GlobalKey<FormState>();
  final _keyReportMessage = GlobalKey<FormState>();
  String comment = "";
  String reportMessage = "";

  bool liked = false;
  bool disliked = false;
  bool reshared = false;
  bool bookmarked = false;
  bool reported = false;

  Future thumbsUpPressed() async{

    // maybe add some animation of some sort?
    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    // get the like status for this post
    QuerySnapshot sn = await FirebaseFirestore.instance
        .collection("Likes")
        .where("postID", isEqualTo: widget.postID)
        .where("username", isEqualTo: widget.myUsername)
        .get();

    bool exists = false; // bool that indicates if that document exists in db
    if(sn.docs.length > 0){
      liked = sn.docs[0]["likeStatus"];
      disliked = sn.docs[0]["dislikeStatus"];
      exists = true;
    }

    if(!disliked) {
      // if this user did not disliked this post continue:
      final db = FirebaseFirestore.instance;
      String id = db
          .collection("Likes")
          .doc()
          .id; // gets random doc id
      if (!liked && !exists) {
        liked = true;
        // add to db that myUsername liked this post and send notification to username
        db.collection("Likes").doc(id).set({
          "likeStatus": true,
          "dislikeStatus": false,
          "username": widget.myUsername,
          "postID": widget.postID,
        });

        // update post's like count
        await db.collection("Posts")
            .doc(widget.postID)
            .update({"likes": FieldValue.increment(1)});

        // send notification to username
        String notifID = db
            .collection("Likes")
            .doc()
            .id; // gets random doc id

        await db.collection("Notifications")
            .doc(notifID)
            .set({
          "fromUsername": widget.myUsername,
          "toUsername": widget.username,
          "createdDate": formattedDate,
          "postID": widget.postID,
          "notificationType": "Likes/Dislikes",
          "notification": "${widget.myUsername} liked your post!",
        });
      }

      else if (!liked && exists) {
        liked = true;
        // update the existing poc, don't add a new one
        await db.collection("Likes")
            .doc(sn.docs[0].id)
            .update({"likeStatus": true});

        // update post's like count
        await db.collection("Posts")
            .doc(widget.postID)
            .update({"likes": FieldValue.increment(1)});

        // send notification
        String notifID = db
            .collection("Likes")
            .doc()
            .id; // gets random doc id
        await db.collection("Notifications")
            .doc(notifID)
            .set({
          "fromUsername": widget.myUsername,
          "toUsername": widget.username,
          "createdDate": formattedDate,
          "postID": widget.postID,
          "notificationType": "Likes/Dislikes",
          "notification": "${widget.myUsername} liked your post!",
        });
      }

      else {
        liked = false;
        // take back the like and make like status false
        await db.collection("Likes")
            .doc(sn.docs[0].id)
            .update({"likeStatus": false});

        var result = await db.collection("Posts").where(
            "postID", isEqualTo: widget.postID).get();
        int n = result.docs[0]["likes"];

        if (n > 0) {
          await db.collection("Posts")
              .doc(widget.postID)
              .update({"likes": n - 1});
        }
      }
    }
    setState(() {});
  }

  Future thumbsDownPressed() async{
    // get the dislike status for this post
    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    QuerySnapshot sn = await FirebaseFirestore.instance
        .collection("Likes")
        .where("postID", isEqualTo: widget.postID)
        .where("username", isEqualTo: widget.myUsername)
        .get();

    bool exists = false;
    if(sn.docs.length > 0){
      liked = sn.docs[0]["likeStatus"];
      disliked = sn.docs[0]["dislikeStatus"];
      exists = true;
    }

    if(!liked) {
      // if this user did not like this post continue:
      final db = FirebaseFirestore.instance;
      String id = db
          .collection("Likes")
          .doc()
          .id; // gets random doc id
      if (!disliked && !exists) {
        disliked = true;
        // add to db that myUsername disliked this post and send ?notification to username?
        db.collection("Likes").doc(id).set({
          "likeStatus": false,
          "dislikeStatus": true,
          "username": widget.myUsername,
          "postID": widget.postID,
        });

        // update post's dislike count
        await db.collection("Posts")
            .doc(widget.postID)
            .update({"dislikes": FieldValue.increment(1)});

        // send notification to username
        String notifID = db
            .collection("Likes")
            .doc()
            .id; // gets random doc id
        await db.collection("Notifications")
            .doc(notifID)
            .set({
          "fromUsername": widget.myUsername,
          "toUsername": widget.username,
          "createdDate": formattedDate,
          "postID": widget.postID,
          "notificationType": "Likes/Dislikes",
          "notification": "${widget.myUsername} disliked your post!",
        });
      }

      else if (!disliked && exists) {
        disliked = true;
        // update the existing doc, don't add a new one
        await db.collection("Likes")
            .doc(sn.docs[0].id)
            .update({"dislikeStatus": true});

        // update post's dislike count
        await db.collection("Posts")
            .doc(widget.postID)
            .update({"dislikes": FieldValue.increment(1)});

        // send notification
        String notifID = db
            .collection("Likes")
            .doc()
            .id; // gets random doc id
        await db.collection("Notifications")
            .doc(notifID)
            .set({
          "fromUsername": widget.myUsername,
          "toUsername": widget.username,
          "createdDate": formattedDate,
          "postID": widget.postID,
          "notificationType": "Likes/Dislikes",
          "notification": "${widget.myUsername} disliked your post!",
        });
      }

      else {
        disliked = false;
        // take back the dislike from post and make dislike status false
        await db.collection("Likes")
            .doc(sn.docs[0].id)
            .update({"dislikeStatus": false});

        var result = await db.collection("Posts").where(
            "postID", isEqualTo: widget.postID).get();
        int n = result.docs[0]["dislikes"];

        if (n > 0) {
          await db.collection("Posts")
              .doc(widget.postID)
              .update({"dislikes": n - 1});
        }
      }
    }
    setState(() {});
  }

  Future resharePressed() async{
    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
    // add this post's id to this user's posts list if it is not already in it
    QuerySnapshot sn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: widget.myUsername)
        .get();

    if(sn.docs.length > 0) {
      List array = sn.docs[0]["posts"];

      // if this post was already reshared before:
      if(array.contains(widget.postID)) {
        await FirebaseFirestore.instance.collection("Profile")
            .doc(sn.docs[0].id)
            .update({"posts": FieldValue.arrayRemove([widget.postID])});

        reshared = false;
        setState(() {});
        return null;
      }

      // add this post's potID to this user's posts array in db
      await FirebaseFirestore.instance.collection("Profile")
          .doc(sn.docs[0].id)
          .update({"posts": FieldValue.arrayUnion([widget.postID])});
      print("after adding post to posts list in if");

      reshared = true;

      // send notification
      final db = FirebaseFirestore.instance;
      String notifID = db.collection("Notifications")
          .doc().id; // gets random doc id
      await db.collection("Notifications")
          .doc(notifID)
          .set({
        "fromUsername": widget.myUsername,
        "toUsername": widget.username,
        "createdDate": formattedDate,
        "postID": widget.postID,
        "notificationType": "Reshare",
        "notification": "${widget.myUsername} reshared your post!",
      });

    }

    setState(() {});
  }

  Future bookmarkPressed() async{
    // add this post's id to this user's marked list if it is not already in it
    QuerySnapshot sn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: widget.myUsername)
        .get();

    if(sn.docs.length > 0) {
      List array = sn.docs[0]["marked"];

      // if this post was already marked before:
      if(array.contains(widget.postID)) {
        await FirebaseFirestore.instance.collection("Profile")
            .doc(sn.docs[0].id)
            .update({"marked": FieldValue.arrayRemove([widget.postID])});

        bookmarked = false;
        setState(() {});
        return null;
      }

      await FirebaseFirestore.instance.collection("Profile")
          .doc(sn.docs[0].id)
          .update({"marked": FieldValue.arrayUnion([widget.postID])});
      print("after adding post to marked list in if");
      bookmarked = true;
    }
    setState(() {});
  }

  Future reportPressed() async{
    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

   return showDialog<void>(
      context: context,
      barrierDismissible: true, // user don't need to tap the button to cancel
      builder: (context) {
        return AlertDialog(
          title: const Text('Why would you like to report this post?'),
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
                      "fromUsername": widget.myUsername,
                      "createdDate": formattedDate,
                      "postID": widget.postID,
                      "reportType": "Post",
                      "message": reportMessage,
                    });

                  reported = true;
                  String rid = widget.postID.toString();
                  String rmessage = reportMessage.toString();
                  String reporter = widget.myUsername.toString();
                  String username = 'turapha19@gmail.com';
                  String password = 'rnjcztahnqbogczj'; // app password for security
                  final smtpServer = gmail(username, password);
                  final message = Message()
                    ..from = Address(username, 'Capturista')
                    ..recipients.add('edemirci@sabanciuniv.edu') //email address of admin
                    ..subject = 'Capturista Report Notification  ${DateTime.now()}'
                    ..text = 'User with username $reporter reported post with postID: $rid reason for the report is $rmessage';
                  try {
                    final sendReport = await send(message, smtpServer);
                    print('Message sent: ' + sendReport.toString());
                  } on MailerException catch (e) {
                    print('Message not sent.');
                    for (var p in e.problems) {
                      print('Problem: ${p.code}: ${p.msg}');
                    }
                  }

                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future makeCommentPressed() async{
    print("make comment pressed");
    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    final db = FirebaseFirestore.instance;

    String id = db.collection("Comments").doc().id; // gets random doc id
    db.collection("Comments").doc(id).set({
      "comment": comment,
      "createdDate": formattedDate,
      "fromUser": widget.myUsername,
      "postID": widget.postID,
    });

    //update post's comment number
    db.collection("Posts").doc(widget.postID)
        .update({"comments": FieldValue.increment(1)});

    // send notification
    String notifID = db.collection("Notifications")
        .doc().id; // gets random doc id
    await db.collection("Notifications")
        .doc(notifID)
        .set({
          "fromUsername": widget.myUsername,
          "toUsername": widget.username,
          "createdDate": formattedDate,
          "postID": widget.postID,
          "notificationType": "Comment",
          "notification": "${widget.myUsername} commented on your post!",
        });

    setState(() {});
  }

  void _getPostData() async{
    // get like, dislike status:
    QuerySnapshot sn = await FirebaseFirestore.instance.collection("Likes")
        .where("username", isEqualTo: widget.myUsername)
        .where("postID", isEqualTo: widget.postID)
        .get();

    if(sn.docs.length > 0) {
      liked = sn.docs[0]["likeStatus"];
      disliked = sn.docs[0]["dislikeStatus"];
    }

    // get reshare status:
    sn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: widget.myUsername)
        .get();

    if(sn.docs.length > 0) {
      List array = sn.docs[0]["posts"];

      if(array.isNotEmpty && array.contains(widget.postID) && widget.username != widget.myUsername)
        reshared = true;
    }

    // get bookmark status;
    sn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: widget.myUsername)
        .get();

    if(sn.docs.length > 0) {
      List array = sn.docs[0]["marked"];

      if(array.isNotEmpty && array.contains(widget.postID))
        bookmarked = true;
    }

    // get report status
    sn = await FirebaseFirestore.instance.collection("Reports")
        .where("postID", isEqualTo: widget.postID)
        .get();

    if(sn.docs.length > 0) {
      reported = true;
    }

    setState(() {});
  }

  @override
  void initState() {
    _getPostData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String url = "https://t4.ftcdn.net/jpg/02/38/86/89/360_F_238868953_D6dfKSahj9HBXzzNleaPmfQI8gtN1jq5.jpg";
    ImageProvider<Object> showProfilePicture(doc) {
      if (doc["profilePicURL"].toString() != null && doc["profilePicURL"].toString().contains("http"))
        return NetworkImage(doc["profilePicURL"].toString());
      else if (doc["profilePicURL"].toString() != null)
        return MemoryImage(base64.decode(doc["profilePicURL"].toString()));
    }

    return Container(
      color: AppColors.backgroundColor,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row for top part
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Profile")
                .where("username", isEqualTo: widget.username)
                .snapshots(),
            builder: (context, snapshot) {

              if(snapshot.hasData) {
                DocumentSnapshot ds = snapshot.data.docs[0];
                if(ds["profilePicURL"] != null)
                  url = ds["profilePicURL"];


                List<Widget> widgetList = [Container()];

                if(widget.location != ""){
                  widgetList.add(Icon(Icons.location_pin));
                  widgetList.add(Text(widget.location));
                }

                if(widget.tags.toString() != "[]"){
                  widgetList.add(Icon(Icons.tag));
                  widgetList.add(Text(widget.tags.toString()));
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      // users profile pic
                      //backgroundImage: NetworkImage(url),
                      backgroundImage: showProfilePicture(snapshot.data.docs[0]),

                      radius: 30,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextButton(
                            onPressed: (){
                             if(widget.username!= widget.myUsername) {
                               Navigator.push(context, MaterialPageRoute(
                                   builder: (context) =>
                                       OthersProfileView(
                                         username: widget.username,
                                       )
                               ));
                             }
                             else
                               {
                                 Navigator.pushNamed(context, '/profile');
                               }
                            },
                            child: Text(
                              ds["username"],
                              style: textStyle,
                            ),
                        ),

                        Row(
                          children: widgetList,
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Container();
            }
          ),

          Divider(
            thickness: 1,
          ),

         if( widget.postImageURL != null && widget.postImageURL.contains("http"))
            Image.network(widget.postImageURL)
         else if (widget.postImageURL != null) Image.memory(base64.decode(widget.postImageURL))
          else Container(),

          SizedBox(
            height: 20,
          ),

          // Post text
          Text(
            widget.text,
          ),

          // Row for icons such as like etc.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[

              liked ?
              IconButton(
                icon: Icon(Icons.thumb_up_sharp),
                color: AppColors.primary,
                onPressed: thumbsUpPressed,
              )
              : IconButton(
                icon: Icon(Icons.thumb_up_sharp),
                color: Colors.grey,
                onPressed: thumbsUpPressed,
              ),

              disliked ? IconButton(
                icon: Icon(Icons.thumb_down_sharp),
                color: AppColors.primary,
                onPressed: thumbsDownPressed,
              )
              : IconButton(
                icon: Icon(Icons.thumb_down_sharp),
                color: Colors.grey,
                onPressed: thumbsDownPressed,
              ),

              reshared ?
              IconButton(
                icon: Icon(Icons.repeat),
                color: AppColors.primary,
                onPressed: resharePressed,
              )
              : IconButton(
                icon: Icon(Icons.repeat),
                color: Colors.grey,
                onPressed: resharePressed,
              ),

              bookmarked ?
              IconButton(
                icon: Icon(Icons.bookmark_border),
                color: AppColors.primary,
                onPressed: bookmarkPressed,
              )
              : IconButton(
                icon: Icon(Icons.bookmark_border),
                color: Colors.grey,
                onPressed: bookmarkPressed,
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

          TextButton(
            child: Text("View Comments (${widget.comments})"),
            onPressed: () {
              FirebaseAnalytics a;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostComments(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    postID: widget.postID,
                  ),
                )
              );
            },
            style: TextButton.styleFrom(
              primary: Colors.grey,
            ),
          ),

          // comment bar
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Form(
                  key: _keyComment,
                  child: TextFormField(
                    controller: messageTextEditingController,
                    decoration: InputDecoration(
                      suffix: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            if(messageTextEditingController.text != "") {
                              print("inside if");
                              _keyComment.currentState.save();
                              comment = messageTextEditingController.text;

                              makeCommentPressed();

                              messageTextEditingController.text= "";
                              FocusScope.of(context).unfocus();

                              setState(() {});
                            }
                          }
                      ),
                      fillColor: AppColors.backgroundColor,
                      focusColor: Colors.grey,
                      filled: true,
                      hintText: 'Make a comment',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value != null) {
                        return value;
                      }

                      return null;
                    },
                    onSaved: (String value) {
                      comment = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
