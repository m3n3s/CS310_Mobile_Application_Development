import 'package:cs310_project/main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:cs310_project/main.dart';


class Welcome extends StatefulWidget {
  const Welcome({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  String _message = '';

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }
  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Welcome',
      screenClassOverride: '/welcome',
    );
    setmessage('setCurrentScreen succeeded');
  }
  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Searchresultprofiles_log',
    );
    setmessage('Custom event log succeeded');
  }

  @override
  void initState() {
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }

  void pressedLoginButton() {
    Navigator.popAndPushNamed(context, '/login');
  }

  void pressedRegisterButton() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        color: AppColors.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Capturista!',
                  style: welcomePageStyle,
                )
              ],
            ),
            //SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.backgroundColor,
                  backgroundImage: AssetImage('images/capturista.jpeg'),
                  radius: 140.0,
                ),
              ],
            ),
            //SizedBox(height: 20.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.tightFor(width: 140, height: 60),
                      child: OutlinedButton(
                        onPressed: pressedLoginButton,
                        child: Text('Login', style: appBarTitleTextStyle),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 10.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.tightFor(width: 140, height: 60),
                      child: OutlinedButton(
                        child: Text('Register', style: appBarTitleTextStyle),
                        onPressed: pressedRegisterButton,
                        style: OutlinedButton.styleFrom(
                          elevation: 10.0,
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
