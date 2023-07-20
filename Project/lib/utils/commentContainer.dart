import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/model/comment_class.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'colors.dart';
import 'styles.dart';

class CommentContainer extends StatefulWidget {
  CommentContainer({this.comment = "", this.date = "", this.username = ""});
  final String comment; //comment text
  final String date; //date of this comment
  final String username; //username of the user who commented this comment

  @override
  _CommentContainerState createState() => _CommentContainerState();
}

class _CommentContainerState extends State<CommentContainer> {
  // url for the profile picture of the user who commented this comment:
  String url = "https://t4.ftcdn.net/jpg/02/38/86/89/360_F_238868953_D6dfKSahj9HBXzzNleaPmfQI8gtN1jq5.jpg";

  Future getProfilePic() async{
    // profile images look blue when the username is not in Profiles collection in db
    QuerySnapshot val;

    try {
      val = await FirebaseFirestore.instance
          .collection('Profile')
          .where('username', isEqualTo: widget.username)
          .get();

    }catch(error){
      print(error);
    }
    if(val.docs.length > 0 && val.docs[0]["profilePicURL"] != null){
      url = val.docs[0]["profilePicURL"];
    }

    setState(() {

    });
  }

  @override
  void initState() {
    getProfilePic() ;
    super.initState();
  }

  ImageProvider<Object> showProfilePicture(url) {
    if (url!= null && url.contains("http"))
      return NetworkImage(url.toString());
    else if (url != null)
      return MemoryImage(base64.decode(url.toString()));
    //else return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            /*
            Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Profile")
                    .where("username", isEqualTo: widget.username)
                    .snapshots(),
                builder: (context, snapshot) {
                  String url;
                  if (!snapshot.hasData){
                    url = "https://t4.ftcdn.net/jpg/02/38/86/89/360_F_238868953_D6dfKSahj9HBXzzNleaPmfQI8gtN1jq5.jpg";
                    return Container();
                  }

                  print("length = " + snapshot.data.docs.length.toString());
                  //print("data -> " + snapshot.data.docs[0].toString());
                  DocumentSnapshot ds = snapshot.data.docs[0]; // ERROR

                  if(ds["profilePicURL"] != null)
                    url = ds["profilePicURL"];

                  return CircleAvatar(
                    // TODO: what if there is no valid url -> fix it later
                    backgroundImage: NetworkImage(url),
                  );
                }
              ),
            ),

             */

            CircleAvatar(
              backgroundImage: showProfilePicture(url),
              //NetworkImage(url),
            ),

            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.username + ":",
                  style: mediumPuntoTextStyle,
                ),
                Text(
                  widget.comment,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
