import 'dart:convert';

import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:cs310_project/model/profile_class.dart';
import 'package:cs310_project/utils/searchProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'othersProfilePage.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';

class SearchResultProfiles extends StatefulWidget {
  const SearchResultProfiles({Key key, this.analytics, this.observer, this.searchInput})
      : super(key: key);

  final String searchInput;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SearchResultStateProfiles createState() => _SearchResultStateProfiles();
}

class _SearchResultStateProfiles extends State<SearchResultProfiles> {
  String _message = '';
  String myUsername ;
  final databaseReference = FirebaseFirestore.instance;

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Search Result Profiles', //direk search result mi diyelim?
      screenClassOverride: '/searchresultprofiles',
    );
    setmessage('setCurrentScreen succeeded');
  }
  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Searchresultprofiles_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> _getMyUsername() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    print("Search Result Profiles _getMyUserName: myUsername = $myUsername");
  }

  @override
  void initState() {
    _setCurrentScreen();
    _setLogEvent();
    _getMyUsername();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> showProfilePicture(url) {
      if (url.toString() != null && url.toString().contains("http"))
        return NetworkImage(url.toString());
      else if (url.toString() != null)
        return MemoryImage(base64.decode(url.toString()));
      //else return Container();
    }


    Widget postContainer(BuildContext context, DocumentSnapshot document) {
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

                    CircleAvatar(
                      // users profile pic
                      //backgroundImage: NetworkImage(document['profilePicURL']),
                      backgroundImage: showProfilePicture(document['profilePicURL']),
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
                            // TODO: will be implemented when profile views are ready
                            if(document["username"]!= myUsername) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      OthersProfileView(
                                        username: document["username"], // it is the same as ds["username"]
                                      )
                              ));
                            }
                            else
                            {
                              Navigator.pushNamed(context, '/profile');
                            }
                          },
                          child: Text(
                            document["username"],
                            style: textStyle,
                          ),
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

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.headingColor,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Profile')
              .where("username", isGreaterThanOrEqualTo: widget.searchInput)
              .where('username', isLessThan: widget.searchInput +'z')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return const Text("No matching profile found");

            return ListView.builder(
                itemExtent: 80.0,
                itemBuilder: (context, i) =>
                    postContainer(context, snapshot.data.docs[i]),
                //separatorBuilder: (_, i) => Divider(),
                itemCount: snapshot.data.docs.length);
          },
        )
    );
  }
}
