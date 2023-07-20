import 'package:cs310_project/utils/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkThrough extends StatefulWidget {
  const WalkThrough({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _WalkThroughState createState() => _WalkThroughState();
}

class _WalkThroughState extends State<WalkThrough> {
  int currentPage = 0;
  int totalPageCount = 5;
  List<String> AppBarTitles = [
    'WELCOME',
    'FEED',
    'FEED',
    'FEED',
    'DIRECT MESSAGES'
  ];
  List<String> PageTitles = [
    'Capturista is a new social media app',
    'Vitalize your feed',
    'React to posts',
    "Search",
    'Start conversations'
  ];
  List<String> imageURLs = [
    'images/cellphone.PNG',
    'images/circ.PNG',
    'images/social.PNG',
    'images/search.PNG',
    'images/purple.jpg'
  ];
  List<String> imageCaptions = [
    'Continue to see what awaits you!',
    'You can share text, media, video, topic, location!',
    'You can like, dislike, comment and reshare!',
    'You can search for new friends and topics or find your contacts and subscribed topics!',
    'You can message your connections!'
  ];
  List<String> nextButton = ['Next', 'Next', 'Next', 'Next', 'Welcome'];
  String _message = '';
  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }
  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Walkthrough',
      screenClassOverride: '/walkthrough',
    );
    setmessage('setCurrentScreen succeeded');
  }
  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Searchresultprofiles_log',
    );
    setmessage('Custom event log succeeded');
  }


  void _incrementInitScreen() async {
    int _initScreen;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _initScreen = (prefs.getInt('_initScreen') ?? 0) + 1;
      prefs.setInt('_initScreen', _initScreen);

      print("incremented shared pref -> _initScreen = $_initScreen");
    });
  }

  void nextPage() {
    setState(() {
      if (currentPage == 4) {
        Navigator.popAndPushNamed(context, '/welcome');
        _incrementInitScreen();
      }
      else if (currentPage < totalPageCount - 1)
        currentPage += 1;
    });
  }

  void prevPage() {
    setState(() {
      if (currentPage > 0) currentPage -= 1;
    });
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
      /*appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text(AppBarTitles[currentPage], style: appBarTitleTextStyle),
        centerTitle: true,
      ),*/
      body: Container(
        padding: const EdgeInsets.all(20.0),
        color: AppColors.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    PageTitles[currentPage],
                    style: headingTextStyle,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.backgroundColor,
                  backgroundImage: AssetImage(imageURLs[currentPage]),
                  radius: 140.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    imageCaptions[currentPage],
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: OutlinedButton(
                    onPressed: prevPage,
                    child: Text('Prev', style: buttonTextStyle),
                  ),
                  width: 120,
                ),
                Text(
                  '${currentPage + 1}/$totalPageCount',
                  style: buttonTextStyle,
                  textAlign: TextAlign.center,
                ),
                Container(
                  child: OutlinedButton(
                    onPressed: nextPage,
                    child: Text(nextButton[currentPage], style: buttonTextStyle),
                  ),
                  width: 120,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
