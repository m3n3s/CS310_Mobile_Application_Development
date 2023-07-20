import 'package:flutter/material.dart';
import 'package:cs310_project/model/post_class.dart';
import 'package:cs310_project/model/profile_class.dart';
import 'package:http/http.dart';
import 'colors.dart';
import 'styles.dart';

class SearchProfile extends StatefulWidget {
  SearchProfile({this.profile});

  final Profile profile;

  @override
  _SearchProfileState createState() => _SearchProfileState();
}

class _SearchProfileState extends State<SearchProfile> {
  @override
  Widget build(BuildContext context) {
    final _keyComment = GlobalKey<FormState>();

    @override
    void initState() {
      super.initState();
    }

    return Container(
      color: AppColors.backgroundColor,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row for top part
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                // users profile pic
                backgroundImage: NetworkImage(
                    widget.profile.profilePicURL),
                radius: 30,
              ),
              SizedBox(width: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.profile.username,
                    style: textStyle,
                  ),
                ],
              ),
            ],
          ),
        ],

      ),
    );
  }
}