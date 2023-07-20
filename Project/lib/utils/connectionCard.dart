import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/model/comment_class.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'colors.dart';
import 'styles.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';

class connectionCard extends StatefulWidget {
  final Function() notifyParent;
  connectionCard({ this.username = "", @required this.notifyParent});
  final String username; //username of the connection

  @override
  _connectionCardState createState() => _connectionCardState();
}

class _connectionCardState extends State<connectionCard> {
  // url for the profile picture of the user who commented this comment:
  String url = "https://t4.ftcdn.net/jpg/02/38/86/89/360_F_238868953_D6dfKSahj9HBXzzNleaPmfQI8gtN1jq5.jpg";
  String myUsername;

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

    widget.notifyParent() ;
  }
  Future<void> _getMyUsername() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    print("notifications _getMyUserName: myUsername = $myUsername");
  }

  Future<void> RemoveConnection() async {

    if(widget.username != '') {
      print("connection to be removed in RemoveConnection is : "  ) ;
      QuerySnapshot mySN = await FirebaseFirestore.instance.collection("Profile")
          .where("username", isEqualTo: myUsername).get() ;
      QuerySnapshot theirSN = await FirebaseFirestore.instance.collection("Profile")
          .where("username", isEqualTo: widget.username).get() ;
      //Remove from waiting connection requests
      await FirebaseFirestore.instance.collection("Profile")
          .doc(theirSN.docs[0].id)
          .update({"connections": FieldValue.arrayRemove([myUsername])});
      await FirebaseFirestore.instance.collection("Profile")
          .doc(mySN.docs[0].id)
          .update(
          {"connections": FieldValue.arrayRemove([widget.username])});
    }
    else
      print("username is null in RemoveConnection");

    setState(() {
      initState();
    });
  }

  @override
  void initState() {
    getProfilePic() ;
    _getMyUsername();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.start,
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
                backgroundImage: url.contains("http") ? NetworkImage(url) : MemoryImage((base64.decode(url))),
              ),

                  Text(
                    widget.username,
                    style: mediumPuntoTextStyle,
                  ),

                RawMaterialButton(
                  child: Text("Remove"),
                  fillColor: Colors.red,
                  onPressed: ()
                {
                  RemoveConnection();
                }, )
            ],
          ),
        ),
      ),
    );
  }
}
