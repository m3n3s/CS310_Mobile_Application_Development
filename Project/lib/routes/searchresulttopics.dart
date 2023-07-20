import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/feedPost.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:cs310_project/model/profile_class.dart';
import 'package:cs310_project/utils/searchProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SearchResultTopics extends StatefulWidget {
  const SearchResultTopics({Key key, this.analytics, this.observer, this.searchInput})
      : super(key: key);

  final String searchInput;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SearchResultTopicsState createState() => _SearchResultTopicsState();
}

class _SearchResultTopicsState extends State<SearchResultTopics> {
  String _message = '';

  final databaseReference = FirebaseFirestore.instance;

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Search Result Topics',
      screenClassOverride: '/searchresulttopics',
    );
    setmessage('setCurrentScreen succeeded');
  }
  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Searchresulttopics_log',
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

    /*
    Widget TextPostContainer(BuildContext context, DocumentSnapshot document) {
      return ListTile(
          title: Row(children: [

            Padding(
              padding: EdgeInsets.all(10.0),

              child: Container(
                width: 350.0,
                height: 120.0,
                color: AppColors.backgroundColor,
                //padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Row for top part
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        /*CircleAvatar(
                          // users profile pic
                          backgroundImage: NetworkImage(document['profilePicURL']),
                          radius: 30,
                        ),*/
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              document['username'],
                              style: textStyle,
                            ),
                            SizedBox(height: 5,),
                            Text(
                              document['textpost'],
                              style: textStyle,
                            ),
                            SizedBox(height: 5,),
                            Text(
                              document['date'],
                              style: textStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]));
    }



    Widget PicturePostContainer(BuildContext context, DocumentSnapshot document) {
      return ListTile(
          title: Row(children: [

            Padding(
              padding: EdgeInsets.all(10.0),

              child: Container(
                //width: 350.0,
                //height: 100.0,
                //height: MediaQuery.of(context).size.height,
                color: AppColors.backgroundColor,
                //padding: EdgeInsets.all(16),
                child: Column(
                  //color: AppColors.backgroundColor,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Row for top part
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        Row(
                          children: [
                            CircleAvatar(
                              // users profile pic
                              backgroundImage: NetworkImage(document['profilePicURL']),
                              radius: 20,
                            ),

                            SizedBox(
                              width: 5.0,
                            ),

                            Text(document['username'],
                              style: TextStyle(
                                fontSize: 10,
                              ),), //BURDA username 'e  ULASAMADIM  olmuyor asla!!!!!!
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Image.network(document['postImageURL'], width: 300, height: 150,)
                            ),
                            Row(
                              children: [
                                Text(
                                    document['tags'].toString(),
                                  style: TextStyle(
                                    fontSize: 14
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Text( document['text'],  style: textStyle, ),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.thumb_up, color: AppColors.primary,),
                                SizedBox(width: 3,),
                                Text( "${document['likes']}" ),
                                SizedBox(width: 10,),
                                Icon(Icons.thumb_down, color: AppColors.primary,),
                                SizedBox(width: 3,),
                                Text( "${document['dislikes']}" ),
                                SizedBox(width: 10,),
                                Icon(Icons.comment, color: AppColors.primary,),
                                SizedBox(width: 3,),
                                Text( "${document['comments']}" ),
                              ],
                            ),

                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]));
    }
    */

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.headingColor,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Posts") // denemek icin tekrar farkli bir collection actim
              .where('tags', arrayContainsAny: [widget.searchInput, "#${widget.searchInput}"])
              .limit(50)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData){
              print("No data ...");
              return  Container(height: 350,width: 500,child: Text("No matching post found"));}
            else{
              print('Data exists, printing listview ...');
              return ListView.builder(
                 
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
                      comments: ds["comments"],
                      analytics: widget.analytics,
                      observer: widget.observer,
                    );
                  },
                  itemCount: snapshot.data.docs.length);
            }


          },
        )
    );
  }
}
