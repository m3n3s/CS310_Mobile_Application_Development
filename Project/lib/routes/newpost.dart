import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/utils/bottom_nav.dart';
import 'package:cs310_project/utils/locationContainer.dart';
import 'package:cs310_project/utils/photoPostCard.dart';
import 'package:cs310_project/utils/postCard.dart';
import 'package:cs310_project/utils/video.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
//import "package:firebase_storage/firebase_storage.dart";

class NewPost extends StatefulWidget {
  const NewPost({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  TextEditingController messageTextEditingControllerfortext =
      TextEditingController();
  TextEditingController messageTextEditingControllerfortags =
      TextEditingController();
  TextEditingController messageTextEditingControllerforlocation =
      TextEditingController();
  String _message = '';
  bool value = false; //location sharing preference
  final _key = GlobalKey<FormState>();
  String text = "";
  File imageFile;
  File _video;

  //String date = "";
  String location = "";
  String postID = "";
  String postImageURL = "";
  List<String> tags = [];
  String username;

  Future<void> _getMyUsername() async {
    username = await SharedPreferenceHelper().getUserName();
    print("myUsername = $username");
  }

  Future<void> _post() async {
    print("post called");

    String date = new DateTime.now().toString();
    DateTime dateParse = DateTime.parse(date);
    String formattedDate =
        "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    String id = FirebaseFirestore.instance
        .collection("Posts")
        .doc()
        .id; // gets random doc id

    await FirebaseFirestore.instance.collection('Posts').doc(id).set({
      "comments": 0,
      "date": formattedDate,
      "dislikes": 0,
      "likes": 0,
      "location": location,
      "postID": id,
      "postImageURL": postImageURL,
      "tags": tags,
      "text": text,
      "username": username,
    });
    QuerySnapshot sn = await FirebaseFirestore.instance
        .collection("Profile")
        .where("username", isEqualTo: username)
        .get();

    if (sn.docs.length > 0) {
      await FirebaseFirestore.instance
          .collection("Profile")
          .doc(sn.docs[0].id)
          .update({
        "posts": FieldValue.arrayUnion([id])
      });
      print("after adding post to posts list in if");
    }
    setState(() {});
  }

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'New Post',
      screenClassOverride: '/newpost',
    );
    setmessage('setCurrentScreen succeeded');
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Newpost_log',
    );
    setmessage('Custom event log succeeded');
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
    return Scaffold(
        bottomNavigationBar: BottomNavigation(),
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
            padding: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /*
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/feed');
                        },
                      ),*/
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        'Create a New Post',
                        style: TextStyle(
                          color: AppColors.headingColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 25.0,
                          letterSpacing: -0.7,
                          fontFamily: 'OpenSans',
                        ),
                      )
                    ],
                  ),
                  SizedBox(width: 100, height: 100),
                  DefaultTabController(
                    length: 4,
                    child: Expanded(
                      child: Scaffold(
                        backgroundColor: AppColors.backgroundColor,
                        appBar: TabBar(
                          labelColor: AppColors.captionColor,
                          tabs: [
                            Tab(
                                child:
                                    FittedBox(child: Icon(Icons.text_fields))),
                            Tab(child: FittedBox(child: Icon(Icons.photo))),
                            //Tab(
                            //child: FittedBox(
                            //child: Icon(Icons.video_collection))),
                            Tab(child: FittedBox(child: Icon(Icons.tag))),
                            Tab(
                                child:
                                    FittedBox(child: Icon(Icons.location_on))),
                          ],
                        ),
                        body: Form(
                          key: _key,
                          child: TabBarView(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller:
                                      messageTextEditingControllerfortext,
                                  decoration: InputDecoration(
                                    fillColor: AppColors.postCardColor,
                                    filled: true,
                                    hintText: 'What do you want to share?',
                                    //labelStyle: textStyle,
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.primary),
                                      borderRadius:
                                          BorderRadius.all(Radius.zero),
                                    ),
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 6,
                                  obscureText: false,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  onChanged: (String value) {
                                    text = value;
                                    print(text);
                                    //messageTextEditingController.text = "";
                                    setState(() {});
                                  },
                                ),
                              ),
                              Expanded(
                                  child: SingleChildScrollView(
                                child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //SizedBox(height:150),
                                    Container(
                                        child: imageFile == null
                                            ? Container(
                                                alignment: Alignment.center,
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      FlatButton(
                                                          color: AppColors
                                                              .postCardColor,
                                                          onPressed: () {
                                                            getFromGallery();
                                                          },
                                                          child: Text(
                                                              'Select a photo from your gallery')),
                                                    ]))
                                            : Container(
                                                child: Image.file(
                                                imageFile,
                                                fit: BoxFit.cover,
                                              )))
                                  ],
                                ),
                              )),
                              //VideoPlayerApp(),
                              Expanded(
                                  child: TextFormField(
                                controller: messageTextEditingControllerfortags,
                                decoration: InputDecoration(
                                  fillColor: AppColors.postCardColor,
                                  filled: true,
                                  hintText: 'Add topics using , in between:',
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.primary),
                                    borderRadius: BorderRadius.all(Radius.zero),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 6,
                                obscureText: false,
                                enableSuggestions: false,
                                autocorrect: false,
                                onChanged: (String value) {
                                  tags = value.split(",");
                                  print(tags);
                                  //messageTextEditingController.text = "";
                                  setState(() {});
                                },
                              )),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      messageTextEditingControllerforlocation,
                                  decoration: InputDecoration(
                                    fillColor: AppColors.postCardColor,
                                    filled: true,
                                    hintText:
                                        'Would you like to share your location?',
                                    //labelStyle: textStyle,
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.primary),
                                      borderRadius:
                                          BorderRadius.all(Radius.zero),
                                    ),
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 6,
                                  obscureText: false,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  onChanged: (String value) {
                                    location = value;
                                    print(location);
                                    //messageTextEditingController.text = "";
                                    setState(() {});
                                  },
                                ),
                                /*
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                            activeColor: AppColors.secondary,
                                            value: this.value,
                                            onChanged: (bool val) {
                                              setState(() {
                                                this.value = val;
                                              });
                                            }),
                                        Text('Share your location:',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'OpenSans',
                                            )),
                                      ]),
                                  Image(
                                      image: AssetImage(
                                          'assets/paris-on-map-paris-map-google_3.jpg'))
                                ],*/
                              ),
                            ],
                          ),
                        ),
                        floatingActionButton: FloatingActionButton(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.add),
                          onPressed: () {
                            _key.currentState.save();
                            print("onpressed cagrildi");
                            print(text);
                            print(location);
                            print(tags);
                            _post();
                            messageTextEditingControllerfortext.text = "";
                            messageTextEditingControllerfortags.text = "";
                            messageTextEditingControllerforlocation.text = "";
                            text = "";
                            tags = [];
                            location = "";
                            imageFile = null;
                            FocusScope.of(context).unfocus();
                            setState(() {});
                          },
                        ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.centerFloat,
                      ),
                    ),
                  ),
                ])));
  }

  getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);

        String encodedImageString =
            base64.encode(File(pickedFile.path).readAsBytesSync().toList());
        print(encodedImageString);
        postImageURL = encodedImageString;
        print(postImageURL);
      });
    }
  }
}
