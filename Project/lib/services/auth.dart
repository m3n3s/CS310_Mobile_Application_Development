import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';
import 'package:cs310_project/services/database.dart';
import 'package:cs310_project/routes/feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/feed.dart';
class AuthMethods{

  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser(){
    return auth.currentUser;
  }
  signInWithGoogle(BuildContext context)async
  {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken
    );
    UserCredential result = await _firebaseAuth.signInWithCredential(credential);

    User userDetails = result.user;

    if(result != null){
    SharedPreferenceHelper().saveUserEmail(userDetails.email);
    SharedPreferenceHelper().saveUserId(userDetails.uid);
    SharedPreferenceHelper().saveUserName(userDetails.email.replaceAll("@sabanciuniv.edu", ""));
    SharedPreferenceHelper().saveDisplayName(userDetails.displayName);
    SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL);
    Map<String,dynamic> userInfoMap = {
      "email": userDetails.email,
      "username": userDetails.email.replaceAll("@sabanciuniv.edu", ""),
      "name": userDetails.displayName,
      "imgUrl": userDetails.photoURL
    };
    DatabaseMethods().addUserInfoToDB(userDetails.uid, userInfoMap).then(
            (value){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Feed()));
      });
    }
  }


  Future signOut()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    prefs.setInt("_initScreen", 1);
    await auth.signOut();
  }
}