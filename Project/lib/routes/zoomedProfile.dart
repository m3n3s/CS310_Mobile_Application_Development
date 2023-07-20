import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class zoomedProfile extends StatefulWidget {
  const zoomedProfile({Key key, this.url}) : super(key: key);

  final String url;

  @override
  _zoomedProfileState createState() => _zoomedProfileState();
}

class _zoomedProfileState extends State<zoomedProfile> {
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
        child: PhotoView(
      imageProvider: //NetworkImage(widget.url)
      showProfilePicture(widget.url),

    ));
  }
}
