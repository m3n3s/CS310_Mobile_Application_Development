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
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/bottom_nav.dart';
import '../utils/styles.dart';
import 'connectionList.dart';
import 'login.dart';
import 'package:cs310_project/services/auth.dart';
import 'welcome.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';


class ProfileView extends StatefulWidget {
  const ProfileView({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _message = '';
  String profileID, userID;
  String myUsername;
  List <dynamic> marked ;
  FeedPosts post;
  List<FeedPosts> posts;
  var markedData ;
  var myPostQuery;
  final db = FirebaseFirestore.instance;

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Profile',
      screenClassOverride: '/profile',
    );
    setmessage('setCurrentScreen succeeded');
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Myprofile_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> _getMyUsername() async {
    posts = [];
    myUsername = await SharedPreferenceHelper().getUserName();
    print("in profile _getMyUsername: myUsername = $myUsername");
    print("myusername: $myUsername");
    QuerySnapshot val, itr;
    val = await FirebaseFirestore.instance
        .collection('Profile')
        .where('username', isEqualTo: myUsername)
        .get();
    print(val);
    marked = List.from(val.docs[0]["marked"]);

    print("marked post list" + marked.toString() + " length of marked is: ${marked.length}");
    for (int i=0; i<marked.length; i++)
    {
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
      )) ;
    }

    print("length of marked posts is: ${posts.length}") ;

    QuerySnapshot myPostQuery = await FirebaseFirestore.instance
        .collection("Posts")
        .where("postImageURL", isNotEqualTo: "")
        .where("username", isEqualTo: myUsername)
        .get();

    if(myPostQuery==null)
      print("result is null");
    else
      print("length: " + myPostQuery.docs.length.toString());

    for(int i= 0; i< myPostQuery.docs.length ; i++)
    {
      print(myPostQuery.docs[i]["username"] + " my post query doc id " + myPostQuery.docs[i].id) ;
    }
  }

  ImageProvider<Object> showProfilePicture(doc) {
    if (doc["profilePicURL"].toString() != null && doc["profilePicURL"].toString().contains("http"))
      return NetworkImage(doc["profilePicURL"].toString());
    else if (doc["profilePicURL"].toString() != null)
      return MemoryImage(base64.decode(doc["profilePicURL"].toString()));
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

  @override
  void initState() {
    _getMyUsername();
    _setCurrentScreen();
    _setLogEvent();
    // _getMarked();
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
              if( document["postImageURL"] != null && document["postImageURL"].contains("http"))
                Image.network(document["postImageURL"])
              else if (document["postImageURL"] != null)
                Image.memory(base64.decode(document["postImageURL"]))
              else Container(),

              Text(
                document["text"] == null ? "no text" : document["text"],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigation(),
      backgroundColor: AppColors.backgroundColor,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Profile")
              .where('username', isEqualTo: myUsername)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text("No profile found");
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
                                  builder: (context) => zoomedProfile(
                                      url: snapshot.data.docs[0]["profilePicURL"].toString()
                                  )
                              )
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          backgroundImage: showProfilePicture(snapshot.data.docs[0]),
                          radius: 40.0,
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              snapshot.data.docs[0]["name"].toString() +
                                  " " +
                                  snapshot.data.docs[0]["lastname"].toString(),
                              style: headingTextStyle,
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
                          ]),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.settings, color: AppColors.primary),
                          onPressed: () {
                            Navigator.pushNamed(context, '/usersettings');
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon:
                          Icon(Icons.exit_to_app, color: AppColors.primary),
                          onPressed: () {
                            AuthMethods().signOut().then((s) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Welcome()));
                            });
                          },
                        ),
                      ),
                    ]),
                SizedBox(
                  height: 10,
                ),
                Text(snapshot.data.docs[0]["bio"].toString()),
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
                    InkWell(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Connections',
                            style: textStyle,
                          ),
                          Text(
                            snapshot.data.docs[0]["connections"].length.toString(),
                            style: textStyle,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => connectionList(myUsername:
                                myUsername)
                            )
                        );
                      },
                    ),
                  ],
                ),
                Divider(
                  thickness: 2.0,
                  color: AppColors.captionColor,
                ),
                DefaultTabController(
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
                              .collection("Profile")
                              .where("username", isEqualTo: myUsername)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData)
                              return const Text("No posts found");

                            List array = List.from(snapshot.data.docs[0]["posts"]);

                            return ListView.builder(
                              itemBuilder: (context, i) => StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("Posts")
                                      .where("postID", isEqualTo: array[i])
                                      .snapshots(),
                                  builder: (context, snapshot){
                                    if(snapshot.hasData && snapshot.data.docs.length > 0) {

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Dismissible(
                                          key: UniqueKey(),
                                          direction: DismissDirection.endToStart,
                                          onDismissed: (direction) async {
                                            setState(() async {
                                              FirebaseFirestore.instance
                                                  .collection("Posts")
                                                  .doc(snapshot.data.docs[i].id)
                                                  .delete();

                                              String postIDtoDelete = snapshot
                                                  .data
                                                  .docs[i].id;

                                              myUsername =
                                              await SharedPreferenceHelper()
                                                  .getUserName();
                                              print(
                                                  "notifications _getMyUserName: myUsername = $myUsername");

                                              QuerySnapshot sn = await FirebaseFirestore
                                                  .instance
                                                  .collection("Profile")
                                                  .where("username",
                                                  isEqualTo: myUsername)
                                                  .get();

                                              if (sn.docs.length > 0) {
                                                await FirebaseFirestore.instance
                                                    .collection("Profile")
                                                    .doc(sn.docs[0].id)
                                                    .update({
                                                  "posts": FieldValue.arrayRemove(
                                                      [postIDtoDelete])
                                                });
                                                print(
                                                    "after adding post to posts list in if");
                                              }
                                            });
                                          },
                                          background: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFE6E6),
                                              borderRadius: BorderRadius.circular(
                                                  15),
                                            ),
                                            child: Row(
                                              children: [
                                                Spacer(),
                                                Image.network(
                                                  "https://cdn1.iconfinder.com/data/icons/office-and-business-14/48/32-512.png",
                                                  height: 50,
                                                  width: 50,),
                                              ],
                                            ),
                                          ),
                                          child: ProfilePosts(
                                            text: snapshot.data.docs[0]["text"],
                                            date: snapshot.data.docs[0]["date"],
                                            likes: snapshot.data.docs[0]["likes"],
                                            dislikes: snapshot.data
                                                .docs[0]["dislikes"],
                                            postID: snapshot.data
                                                .docs[0]["postID"],
                                            location: snapshot.data
                                                .docs[0]["location"],
                                            postImageURL: snapshot.data
                                                .docs[0]["postImageURL"],
                                            tags: List.from(
                                                snapshot.data.docs[0]["tags"]),
                                            username: snapshot.data
                                                .docs[0]["username"],
                                            comments: snapshot.data
                                                .docs[0]["comments"],
                                            analytics: widget.analytics,
                                            observer: widget.observer,
                                          ),
                                        ),
                                      );
                                    }

                                    return Container();
                                  }
                              ),

                              itemCount: array.length,
                            );
                          },
                        ),

                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Posts")
                              .where("postImageURL", isNotEqualTo: "")
                              .where("username", isEqualTo: myUsername)
                              .snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData)
                              return const Text("No posts found");

                            return ListView.builder(
                                itemBuilder: (context, i) =>
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Dismissible(
                                        key: UniqueKey(),
                                        direction: DismissDirection.endToStart,
                                        onDismissed: (direction) async {
                                          FirebaseFirestore.instance
                                              .collection("Posts")
                                              .doc('postID')
                                              .delete()
                                              .then((_) {
                                            print("success!");
                                          });
                                          setState(() {

                                          });
                                        },
                                        background: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFE6E6),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            children: [
                                              Spacer(),
                                              Image.network("https://cdn1.iconfinder.com/data/icons/office-and-business-14/48/32-512.png",
                                                height: 50,
                                                width: 50,),
                                            ],
                                          ),
                                        ),
                                        child: ProfilePosts(
                                          text: snapshot.data.docs[i]["text"],
                                          date: snapshot.data.docs[i]["date"],
                                          likes: snapshot.data.docs[i]["likes"],
                                          dislikes: snapshot.data.docs[i]["dislikes"],
                                          postID:snapshot.data.docs[i]["postID"],
                                          location: snapshot.data.docs[i]["location"],
                                          postImageURL: snapshot.data.docs[i]["postImageURL"],
                                          tags: List.from(snapshot.data.docs[i]["tags"]),
                                          username: snapshot.data.docs[i]["username"],
                                          comments: snapshot.data.docs[i]["comments"],
                                          analytics: widget.analytics,
                                          observer: widget.observer,
                                        ),
                                      ),
                                    ),
                                itemCount: snapshot.data.docs.length
                            );
                          },
                        ),

                        ListView.builder(
                          itemBuilder: (context, i){
                            return posts[i];
                          },
                          itemCount: (marked != null ? marked.length : 0),
                        ),
                      ]),
                    ),
                  ),
                )
              ]),
            );
          }
      ),
    );
  }
}