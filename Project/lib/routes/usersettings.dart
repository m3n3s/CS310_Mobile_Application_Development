import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import '../utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class UserSettings extends StatefulWidget {
  const UserSettings({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings>
{
  final db = FirebaseFirestore.instance;
  File imageFile;
  String profilePicture = "";

  getFromGallery() async {
    print("getfromgallery called");
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);

        String encodedImageString = base64.encode(
            File(pickedFile.path).readAsBytesSync().toList());
        print(encodedImageString);
        profilePicture = encodedImageString;
        print(profilePicture);

        updateProfilePicture(profilePicture);
      });
    }
  }

  String _message = '';

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }
  String myUsername;
  String editedname;
  String editedlastname;
  String editedbio;
  String editedpassword;

  String type;

  final _keyname = GlobalKey<FormState>();
  final _keylastname = GlobalKey<FormState>();
  final _keybio = GlobalKey<FormState>();
  final _keypassword = GlobalKey<FormState>();

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'User Settings',
      screenClassOverride: '/usersettings',
    );
    setmessage('setCurrentScreen succeeded');
  }
  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Searchresultprofiles_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> updateProfilePicture(String text) async{
    CollectionReference db = FirebaseFirestore.instance.collection('Profile');
    CollectionReference db2 = FirebaseFirestore.instance.collection('users');
    myUsername = await SharedPreferenceHelper().getUserName();
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    QuerySnapshot mysn2 = await FirebaseFirestore.instance.collection("users")
        .where("username", isEqualTo: myUsername).get() ;
    db2.doc(mysn2.docs[0].id)
        .update({'profilePicURL': text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
    return db.doc(mysn.docs[0].id)
        .update({'profilePicURL': text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> acceptAll () async {
    print ("acceptAll called") ;
    QuerySnapshot mySN = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;


    List myWaitingList = List.from(mySN.docs[0]["waitingRequests"]);
    for (var username in myWaitingList)
    {
      print("username in waiting requests: " + username);
      QuerySnapshot theirSN = await FirebaseFirestore.instance.collection("Profile")
          .where("username", isEqualTo: username).get() ;

      //Remove from waiting connection requests
      await FirebaseFirestore.instance.collection("Profile")
          .doc(theirSN.docs[0].id)
          .update({"waitingRequests": FieldValue.arrayRemove([myUsername])});
      await FirebaseFirestore.instance.collection("Profile")
          .doc(mySN.docs[0].id)
          .update({"waitingRequests": FieldValue.arrayRemove([username])});

      //Add to connections
      await FirebaseFirestore.instance.collection("Profile")
          .doc(theirSN.docs[0].id)
          .update({"connections": FieldValue.arrayUnion([myUsername])});
      await FirebaseFirestore.instance.collection("Profile")
          .doc(mySN.docs[0].id)
          .update({"connections": FieldValue.arrayUnion([username])});

    }

    //Remove from notifications
    db.collection('Notifications').where('postID', isEqualTo: "1").where("toUsername", isEqualTo: myUsername).get()
      .then((querySnapshot) {
      // Once we get the results, begin a batch

        print("accept all" + querySnapshot.docs[0]["notification"]) ;
        querySnapshot.docs.forEach((doc) {
          print("silinecek notification" + doc.data()["notification"].toString());
          FirebaseFirestore.instance.collection("Notifications")
              .doc(doc.id)
              .delete();

        });
      });
  }

  Future<void> updateUserName(String text) async{

    CollectionReference db = FirebaseFirestore.instance.collection('Profile');
    myUsername = await SharedPreferenceHelper().getUserName();
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    return db
        .doc(mysn.docs[0].id)
        .update({'name': text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> updateUserLastName(String text) async{
    CollectionReference db = FirebaseFirestore.instance.collection('Profile');
    myUsername = await SharedPreferenceHelper().getUserName();
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    return db
        .doc(mysn.docs[0].id)
        .update({'lastname': text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> updateType(String text) async{
    CollectionReference db = FirebaseFirestore.instance.collection('Profile');
    myUsername = await SharedPreferenceHelper().getUserName();
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    if(text == "public")
      acceptAll ();
    return db
        .doc(mysn.docs[0].id)
        .update({'type': text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));

  }

  Future<void> updateUserBio(String text) async{
    CollectionReference db = FirebaseFirestore.instance.collection('Profile');
    myUsername = await SharedPreferenceHelper().getUserName();
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("Profile")
        .where("username", isEqualTo: myUsername).get() ;
    return db
        .doc(mysn.docs[0].id)
        .update({'bio': text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }


  Future<void> updateUserPassword(String text) async{
    CollectionReference db = FirebaseFirestore.instance.collection('users');
    myUsername = await SharedPreferenceHelper().getUserName();
    QuerySnapshot mysn = await FirebaseFirestore.instance.collection("users")
        .where("username", isEqualTo: myUsername).get() ;
    return db
        .doc(mysn.docs[0].id)
        .update({'password': text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future deactivateAccount() async{
    myUsername = await SharedPreferenceHelper().getUserName();

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user don't need to tap the button to cancel
      builder: (context) {
        return AlertDialog(
          title: Text("WARNING!", style: textStyle,),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Do you want to deactivate this account?', style: textStyle),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async{
                QuerySnapshot sn = await FirebaseFirestore.instance
                    .collection("Profile")
                    .where("username", isEqualTo: myUsername)
                    .get();

                await db.collection("Profile")
                    .doc(sn.docs[0].id)
                    .update({"deactivated": true});

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteAccount() async{
    myUsername = await SharedPreferenceHelper().getUserName();

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user don't need to tap the button to cancel
      builder: (context) {
        return AlertDialog(
          title: Text("WARNING!", style: textStyle,),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Do you want to delete this account?', style: textStyle),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async{
                QuerySnapshot sn = await FirebaseFirestore.instance
                    .collection("Profile")
                    .where("username", isEqualTo: myUsername)
                    .get();

                // delete from profile collection
                await db.collection("Profile")
                    .doc(sn.docs[0].id)
                    .delete();

                // delete from users collection
                sn = await FirebaseFirestore.instance
                  .collection("users")
                  .where("username", isEqualTo: myUsername)
                  .get();
                String id = sn.docs[0].id;
                await db.collection("users")
                    .doc(id)
                    .delete();

                // delete from firebase auth
                User user = FirebaseAuth.instance.currentUser;
                user.delete();

                Navigator.pushNamed(context, "/welcome");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _setCurrentScreen();
    _setLogEvent();
    super.initState();
  }
  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            'User Settings',
            style: appBarTitleTextStyle,
          ),
          centerTitle: true,
          backgroundColor: AppColors.headingColor,
          elevation: 0, // deletes the shadow of the app bar
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10.0,),
              InkWell(
                onTap: ()
                  {
                  print("tapped on camera icon");

                    getFromGallery();
                  },
                child: Container(
                  height: 100.0,
                  decoration: new BoxDecoration(
                    color: Colors.orange.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        //Image.file(
                          //imageFile,
                          //fit: BoxFit.cover,
                        //)
                        Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.black,
                          size: 50.0,
                        ),
                      ],
                    ),
                  ),),
              ),
              const SizedBox(height: 5.0),
              Center(
                  child:
                  InkWell(
                    onTap: (){print("tapped on 'Set New Photo'");},
                    child: Text("Set New Photo", style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    )),
                  ),
              ),
              Card(
                margin: const EdgeInsets.fromLTRB(32.0,16.0,32.0,8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: <Widget>[
                    ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text('First Name :')
                            ),
                            Expanded(
                              child: Form(
                                key: _keyname,
                                child: TextFormField(
                                  onSaved: (String value) {
                                    editedname = value;
                                    setState(() {
                                    });
                                  },
                                  // your TextField's Content
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: new Icon(Icons.check_box_rounded, color: Colors.green,),
                          color: Colors.black26,
                          onPressed: () {
                            _keyname.currentState.save();
                            updateUserName(editedname);
                            setState(() {
                            });
                          },
                        )
                    ),
                    ourDivider(),
                    ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text('Last Name :')
                            ),
                            Expanded(
                              child: Form(
                                key: _keylastname,
                                child: TextFormField(
                                  onSaved: (String value) {
                                    editedlastname = value;
                                    setState(() {
                                    });
                                  },
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: new Icon(Icons.check_box_rounded, color: Colors.green,),
                          color: Colors.black26,
                          onPressed: () {
                              _keylastname.currentState.save();
                              updateUserLastName(editedlastname);
                              setState(() {
                              });
                          },
                        )
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              Card(
                margin: const EdgeInsets.fromLTRB(32.0,16.0,32.0,8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: <Widget>[
                    ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text('Bio :')
                            ),
                            Expanded(
                              child: Form(
                                key: _keybio,
                                child: TextFormField(
                                  onSaved: (String value) {
                                    editedbio = value;
                                    setState(() {
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: new Icon(Icons.check_box_rounded, color: Colors.green,),
                          color: Colors.black26,
                          onPressed: () {
                            _keybio.currentState.save();
                            updateUserBio(editedbio);
                            setState(() {});
                          },
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              Card(
                margin: const EdgeInsets.fromLTRB(32.0,16.0,32.0,8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: <Widget>[
                    RadioListTile<String>(
                      title: const Text('Public'),
                      value: "public",
                      groupValue: type,
                      onChanged: (String value) {
                        setState(() {
                          type = value;
                          updateType(type);
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Private'),
                      value: "private",
                      groupValue: type,
                      onChanged: (String value) {
                        setState(() {
                          type = value;
                          updateType(type);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              Card(
                margin: const EdgeInsets.fromLTRB(32.0,16.0,32.0,8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Text('Password :'),
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              child: Form(
                                key: _keypassword,
                                child: TextFormField(
                                  // your TextField's Content
                                  onSaved: (String value) {
                                    editedpassword = value;
                                    setState(() {
                                    });
                                  },

                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: new Icon(Icons.check_box_rounded, color: Colors.green,),
                          color: Colors.black26,
                          onPressed: () {
                            _keypassword.currentState.save();
                            updateUserPassword(editedpassword);
                            setState(() {

                            });

                          },
                        )
                    ),

                    ourDivider(),
                  ],
                ),
              ),

              Center(
                child: OutlinedButton(
                  onPressed: deactivateAccount,
                  child: Text("Deactivate Account"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontWeight: FontWeight.w900,
                        )
                    ),
                  ),
                ),
              ),

              Center(
                child: OutlinedButton(
                  onPressed: deleteAccount,
                  child: Text("Delete Account"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontWeight: FontWeight.w900,
                        )
                    ),
                  ),
                ),
              ),

            ],
          )
        )
      ),
    );
  }
}

Container ourDivider(){
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0, ),
    width: double.infinity,
    height: 1.0,
    color: Colors.grey.shade400,
  );
}