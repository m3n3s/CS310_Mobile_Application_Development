import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/utils/styles.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cs310_project/routes/login.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:google_sign_in/google_sign_in.dart";
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:cs310_project/services/auth.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';

import '../routes/feed.dart';

class Register extends StatefulWidget {
  const Register({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _Register createState() => _Register();
}

class _Register extends State<Register> {
  String email, username, pwd, repeatedpwd;
  final _key = GlobalKey<FormState>();
  bool usernameExists = false;

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
      screenName: 'Register',
      screenClassOverride: '/register',
    );
    setmessage('setCurrentScreen succeeded');
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Register_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> signUpUser() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: pwd);
      print(userCredential.toString());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user.uid)
          .set({
        "email": email,
        "profilePicURL":
            "https://t4.ftcdn.net/jpg/02/38/86/89/360_F_238868953_D6dfKSahj9HBXzzNleaPmfQI8gtN1jq5.jpg",
        "username": username,
        "password": pwd,
      });

      // TODO: add all of the necessary fields to document
      // If something is missing please add
      await FirebaseFirestore.instance
        .collection('Profile')
        .doc(username)
        .set({
          "username": username,
          "connections": [],
          "waitingRequests" : [],
          "type" : "public",
          "deactivated": false,
          "bio" : "",
          "name" : "",
          "lastname" : "",
          "posts" : [],
          "marked" : [],
          "email": email,
          "profilePicURL":
            "https://t4.ftcdn.net/jpg/02/38/86/89/360_F_238868953_D6dfKSahj9HBXzzNleaPmfQI8gtN1jq5.jpg",
      });

      SharedPreferenceHelper().saveUserName(username);
      SharedPreferenceHelper().saveUserEmail(email);
      SharedPreferenceHelper().saveUserId(userCredential.user.uid);

      Navigator.popAndPushNamed(context, '/feed');
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      if (e.code == 'email-already-in-use') {
        setmessage('This email is already in use');
      } else if (e.code == 'weak-password') {
        setmessage(
            'Weak password, add uppercase, lowercase, digit, special character, emoji, etc.');
      }
      showAlertDialog('Unsuccessful login', _message);
    }
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount account = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication authentication =
        await account.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);

    final UserCredential authResult =
        await auth.signInWithCredential(credential);
    final User user = authResult.user;

    //TODO: should be a unique given name: CHANGE LATER
    String username = user.email.replaceAll(user.email.substring(user.email.indexOf("@")), "");

    //TODO: assign a unique default username and redirect to settings to change username
    await FirebaseFirestore.instance
      .collection('users')
      .doc(authResult.user.uid)
      .set({
        "profilePicURL": user.photoURL,
        "username": username,
        "password": "google-password", // default value, doesn't matter what it is since login will be via google log in
        "email": user.email,
      });

    //TODO: also add to the Profile collection
    await FirebaseFirestore.instance
      .collection('Profile')
      .doc(username)
      .set({
        "username": username, // should be a unique given name: CHANGE LATER
        "connections": [],
        "waitingRequests" : [],
        "type" : "public",
        "deactivated": false,
        "bio" : "",
        "name" : "",
        "lastname" : "",
        "posts" : [],
        "marked" : [],
        "email": user.email,
        "profilePicURL": user.photoURL,
      });

    SharedPreferenceHelper().saveUserName(username);
    SharedPreferenceHelper().saveUserEmail(email);
    SharedPreferenceHelper().saveUserId(user.uid);
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

  Future checkUsername(String username) async{
    QuerySnapshot sn = await FirebaseFirestore.instance
        .collection("Profile")
        .where('username', isEqualTo: username)
        .get();

    if (sn.docs.length > 0) {
      return true;
    }
    else
      return false; // username is unique.
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
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'REGISTER',
          style: appBarTitleTextStyle,
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Form(
              key: _key,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        //flex: 1,
                        width: 375,
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
                            email = value;
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
                            hintText: 'Enter your username',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.all(Radius.zero),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your username';
                            }

                            return null;
                          },
                          onSaved: (String value) {
                            username = value;
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
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            pwd = value;
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: AppColors.secondary,
                            filled: true,
                            hintText: 'Repeat password',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.backgroundColor),
                              borderRadius: BorderRadius.all(Radius.zero),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            repeatedpwd = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () async{
                            if (_key.currentState.validate()) {
                              _key.currentState.save();
                              bool exists = await checkUsername(username);

                              if (pwd != repeatedpwd) {
                                showAlertDialog(
                                    "ERROR", 'Please confirm your password.');
                              }
                              else if(exists){
                                showAlertDialog(
                                    "ERROR", 'Username already in use.');
                              }
                              else {
                                //Sign up process
                                signUpUser();
                                print("Successful signup");
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Register',
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
                    text: "Sign up with Google",
                    onPressed: () {
                      signInWithGoogle();
                      Navigator.pushNamed(context, "/feed");
                    },
                  ),
                  Center(child: SizedBox(height: 10.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text('Already a member?', style: textStyle),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.popAndPushNamed(context, '/login'),
                        child: Text(
                          'Login!',
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
