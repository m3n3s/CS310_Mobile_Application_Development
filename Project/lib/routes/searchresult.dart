import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:cs310_project/model/profile_class.dart';
import 'package:cs310_project/utils/feedPost.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({Key key, this.analytics, this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String _message = '';

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Searchresult_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Search Result',
      screenClassOverride: '/searchresult',
    );
    setmessage('setCurrentScreen succeeded');
  }

  @override
  void initState() {
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> postContainers;

    List<Post> posts = [
      Post(
        text:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque aliquam, velit malesuada pellentesque lobortis, "
            "dolor ante sollicitudin sapien, et elementum metus risus in arcu.",
        postImageURL:
            "https://imgd.aeplcdn.com/476x268/n/cw/ec/38904/mt-15-front-view.jpeg?q=80",
        date: "20 APRIL 2021",
        location: "Izmir",
        tags: ["landspace", "photography"],
        profile: Profile(
          username: "anotherusername",
          profilePicURL:
              "https://imgd.aeplcdn.com/476x268/n/cw/ec/38904/mt-15-front-view.jpeg?q=80",
        ),
      ),
    ];

    if (posts.isNotEmpty) {
      postContainers = posts.map((e) => FeedPosts(
          //post: e, //!!!!!
          )).toList();
    } else {
      postContainers = [
        Center(child: Text("There are no posts in feed.")),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headingColor,
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: ListView.separated(
            itemBuilder: (_, i) => postContainers[i],
            separatorBuilder: (_, i) => Divider(),
            itemCount: postContainers.length,
          ),
        ),
      ]),
    );
  }
}
