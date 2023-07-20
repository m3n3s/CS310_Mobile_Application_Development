import 'package:flutter/material.dart';
import 'colors.dart';
import 'styles.dart';

class LocationContainer extends StatefulWidget {
  final String loc;
  final Function delete;
  LocationContainer({this.loc, this.delete});

  @override
  _LocationContainerState createState() => _LocationContainerState();
}

class _LocationContainerState extends State<LocationContainer> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: <Widget> [
          Text(
            widget.loc,
            style: mediumPuntoTextStyle,
          ),

          TextButton(
            onPressed: widget.delete,
            child: Text("Unfollow"),
          ),
        ],
      ),
    );
  }
}
