import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/model/comment_class.dart';
import 'package:cs310_project/routes/searchresultlocation.dart';
import 'package:cs310_project/routes/searchresultposts.dart';
import 'package:cs310_project/routes/searchresultprofiles.dart';
import 'package:cs310_project/routes/searchresulttopics.dart';
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
import 'package:cs310_project/helperfunctions/sharedpref_helper';

class Feed extends StatefulWidget {
  const Feed({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String myUsername = "";
  List followed;
  String _message = '';

  void setMessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Feed_log',
    );
    setMessage('Custom event log succeeded');
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Feed',
      screenClassOverride: '/feed',
    );
    setMessage('setCurrentScreen succeeded');
  }
  Future <void> getFollowed() async {
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    followed = List.from(mysn.docs[0]["connections"]) ;
      followed.add(myUsername);
      print("followed: " + followed.toString());
      setState(() {

      });
  }

  String searchInput;
  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    print("This is feed's initState");
    _getMyUsername();
    _setCurrentScreen();
    _setLogEvent();

    super.initState();
  }

  Future<void> _getMyUsername() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    print("myUsername = $myUsername");
    getFollowed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigation(),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
            ),

            Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Form(
                          key: _key,
                          child: Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: InputDecoration(
                                fillColor: AppColors.secondary,
                                filled: true,
                                hintText: 'Search by',
                                prefixIcon:
                                    Icon(Icons.search, color: AppColors.captionColor),
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primary),
                                  borderRadius: BorderRadius.all(Radius.zero),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'You cannot leave search box empty';
                                }
                                return null;
                              },
                              onSaved: (String value) {
                                searchInput = value;
                              },
                            )
                          ),
                        )
                      ]
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            child: Text(
                              "profiles",
                              style: smallPuntoTextStyle,
                            ),
                            onPressed: () {
                              if (_key.currentState.validate()) {
                                _key.currentState.save();
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchResultProfiles(searchInput: searchInput,),
                                  ),
                               );
                              }
                            }
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            child: Text(
                              "posts",
                              style: smallPuntoTextStyle,
                            ),
                            onPressed: () {
                              if (_key.currentState.validate()) {
                                _key.currentState.save();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchResultPosts(searchInput: searchInput,),
                                  ),
                                );
                              }
                            }
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            child: Text(
                              "topics",
                              style: smallPuntoTextStyle,
                            ),
                            onPressed: () {
                              if (_key.currentState.validate()) {
                                _key.currentState.save();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchResultTopics(searchInput: searchInput,),
                                  ),
                                );
                              }
                            }
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            child: Text(
                              "locations",
                              style: smallPuntoTextStyle,
                            ),
                            onPressed: () {
                              if (_key.currentState.validate()) {
                                _key.currentState.save();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchResultLocation(searchInput: searchInput,),
                                  ),
                                );
                              }
                            }
                          ),
                        ),
                      ],
                    )
                  ]
                )
            ),

            // get the followed users from database
       /*     StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Profile")
                  .where("username", isEqualTo: myUsername)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  DocumentSnapshot ds = snapshot.data.docs[0];

                  if(ds["connections"] != null){
                    followed = List.from(ds["connections"]);
                    followed.add(myUsername);
                    print("followed: " + followed.toString());
                  }

                  else
                    print("inside stream builder that gets following users: ds['following'] is null");
                }
                return Container();
              },
            ),
*/
            // posts:
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Posts")
                  .where("username", whereIn: followed)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return Center(
                    child: Container(
                      child: Text("No posts!"),
                    ),
                  );
                }

                print("snapshot.data.docs.length: " + snapshot.data.docs.length.toString() + " connections: " +  followed.toString() ) ;

                return Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    separatorBuilder: (context, i) => Divider(),
                    itemBuilder: (context, i) {
                      DocumentSnapshot ds = snapshot.data.docs[i];

                      return FeedPosts(
                        text: ds["text"],
                        date: ds["date"],
                        likes: ds["likes"],
                        dislikes: ds["dislikes"],
                        postID: ds.id,
                        location: ds["location"],
                        postImageURL: ds["postImageURL"],
                        tags: List.from(ds["tags"]),
                        username: ds["username"],
                        myUsername: myUsername,
                        comments: ds["comments"],
                        analytics: widget.analytics,
                        observer: widget.observer,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
