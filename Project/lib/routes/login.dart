import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cs310_project/model/profile_class.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cs310_project/services/auth.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String mail, pwd;
  final _key = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String _message = '';

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }
  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Login',
      screenClassOverride: '/login',
    );
    setmessage('setCurrentScreen succeeded');
  }
  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Login_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future _getUsernameFromDB() async{
    String username;
    QuerySnapshot val;

    print("before username query in login: username = $username");

    try {
      val = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: mail)
          .get();
    }catch(error){
      print(error);
    }

    if(val.docs.length > 0){
      username = val.docs[0]["username"];

      SharedPreferenceHelper().saveUserName(username);
      SharedPreferenceHelper().saveUserEmail(mail);
    }
    else{
      print("Not Found");
    }

    print("after username query in login: username = $username");
  }


  Future<void> loginUser() async {
    try {
      UserCredential userCredential =
      await auth.signInWithEmailAndPassword(email: mail, password: pwd);
      //print(userCredential.toString());

      await _getUsernameFromDB();

      Navigator.popAndPushNamed(context, '/feed');

    } on FirebaseAuthException catch (e) {
      print(e.toString());
      if (e.code == 'user-not-found') {
        //signupUser();
        setmessage('No such user exists');
      } else if (e.code == 'wrong-password') {
        setmessage('Please check your password');
      }
      showAlertDialog('Unsuccessful login', _message);
    }
  }

  Future logInWithGoogle() async {
    final GoogleSignInAccount account = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication authentication =
    await account.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);

    final UserCredential authResult =
    await auth.signInWithCredential(credential);
    final User user = authResult.user;

    mail = user.email;
    await _getUsernameFromDB();
  }



  Future<void> showAlertDialog(String title, String message) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, //User must tap button
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title, style: textStyle),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(message, style: textStyle),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _setCurrentScreen();
    _setLogEvent();
    auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is signed out');
      } else {
        print('User is signed in');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'LOGIN',
          style: appBarTitleTextStyle,
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 10.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        //child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Form(
              key: _key,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: AppColors.secondary,
                            filled: true,
                            hintText: 'Enter your e-mail',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.all(Radius.zero),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'You cannot leave e-mail empty';
                            }
                            if (!EmailValidator.validate(value)) {
                              return 'Please enter a valid e-mail address';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            mail = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: AppColors.secondary,
                            filled: true,
                            hintText: 'Enter your password',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.all(Radius.zero),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'You cannot leave password empty';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            pwd = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0, width: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            if (_key.currentState.validate()) {
                              _key.currentState.save();
                            }

                            // if user can log in:
                            loginUser();
                            //if successful
                            //Navigator.popAndPushNamed(context, '/feed');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Login',
                              style: buttonTextStyle2,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SignInButton(
                    Buttons.Google,
                    text: "Login with Google",
                    onPressed: () {

                      logInWithGoogle();
                      Navigator.pushNamed(context, "/feed");
                    },
                  ),
                  Center(child: SizedBox(height: 10.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text('Not already signed up?', style: textStyle),
                      ),
                      TextButton(
                        onPressed: () => Navigator.popAndPushNamed(
                            context, '/register'),
                        child: Text(
                          'Sign up!',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: AppColors.primary,
                            fontSize: 20.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
