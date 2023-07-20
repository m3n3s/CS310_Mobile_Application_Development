import 'package:cs310_project/routes/chats.dart';
import 'package:cs310_project/routes/connectionList.dart';
import 'package:cs310_project/routes/feed.dart';
import 'package:cs310_project/routes/login.dart';
import 'package:cs310_project/routes/newpost.dart';
import 'package:cs310_project/routes/notificationPost.dart';
import 'package:cs310_project/routes/notifications.dart';
import 'package:cs310_project/routes/othersProfilePage.dart';
import 'package:cs310_project/routes/postComments.dart';
import 'package:cs310_project/routes/profile.dart';
import 'package:cs310_project/routes/register.dart';
import 'package:cs310_project/routes/searchresultlocation.dart';
import 'package:cs310_project/routes/usersettings.dart';
import 'package:cs310_project/routes/welcome.dart';
import 'package:cs310_project/routes/walkthrough.dart';
import 'package:cs310_project/routes/searchresult.dart';
import 'package:cs310_project/routes/searchresultprofiles.dart';
import 'package:cs310_project/routes/searchresultposts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'routes/searchresulttopics.dart';

SharedPreferences prefs;
int _initScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //Loading counter value on start
  _loadInitScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //prefs.setInt("_initScreen", 0); // this line is for testing
      _initScreen = (prefs.getInt('_initScreen') ?? 0);
      print("load shared pref -> _initScreen = $_initScreen");
    });
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  bool _seen = false;

  setEnteredAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enteredApp', true);
  }

  loadEnteredAppStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _seen = prefs.getBool('enteredApp');
    });
  }

  @override
  void initState() {
    loadEnteredAppStatus();
    super.initState();
    //FirebaseCrashlytics.instance.crash(); //to test if crashlytics is working
    _loadInitScreen();
    print("this is init state");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization, //_initialization
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Cannot connect to firebase: ' + snapshot.error.toString());
            return AppBase();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            print('Firebase connected');
            return AppBase();
          }
          return AppBase();
        });
  }
}

class AppBase extends StatelessWidget {
  const AppBase({
    Key key,
  }) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  selectStart() {
    if (_initScreen == 0)
      return WalkThrough(analytics: analytics, observer: observer);

    return Welcome(analytics: analytics, observer: observer);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false, // added for chats
      navigatorObservers: <NavigatorObserver>[observer],

      //home: selectStart(),
      home: Login(analytics: analytics, observer: observer),
      routes: {
        '/walkthrough': (context) =>
            WalkThrough(analytics: analytics, observer: observer),
        '/welcome': (context) =>
            Welcome(analytics: analytics, observer: observer),
        '/login': (context) => Login(analytics: analytics, observer: observer),
        '/register': (context) =>
            Register(analytics: analytics, observer: observer),
        '/feed': (context) => Feed(analytics: analytics, observer: observer),
        '/newpost': (context) =>
            NewPost(analytics: analytics, observer: observer),
        '/chats': (context) => Chats(analytics: analytics, observer: observer),
        '/notifications': (context) => Notifications(analytics: analytics, observer: observer),
        '/profile': (context) => ProfileView(analytics: analytics, observer: observer),
        '/searchresult': (context) => SearchResult(analytics: analytics, observer: observer),
        '/searchresultprofiles': (context) => SearchResultProfiles(analytics: analytics, observer: observer),
        '/searchresultposts': (context) => SearchResultPosts(analytics: analytics, observer: observer),
        '/searchresultlocation': (context) => SearchResultLocation(analytics: analytics, observer: observer),
        '/searchresulttopics': (context) => SearchResultTopics(analytics: analytics, observer: observer),
        '/usersettings': (context) => UserSettings(analytics: analytics, observer: observer),
        '/notificationpost': (context) => NotificationPost(analytics: analytics, observer: observer),
        '/othersprofilepage': (context) => OthersProfileView(analytics: analytics, observer: observer),
        '/connections': (context) => connectionList(analytics: analytics, observer: observer),
      },
    );
  }
}