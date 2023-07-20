import 'package:cs310_project/utils/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cs310_project/model/post_class.dart';

import '../utils/styles.dart';


class PostCard extends StatelessWidget {
  final Post post;
  final Function delete;
  PostCard({this.post, this.delete});

  @override
  Widget build(BuildContext context) {
    return Card( // card widget
      // we can also put margin to card
      color: AppColors.postCardColor,
      margin: EdgeInsets.fromLTRB(0, 4, 8, 4),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              post.text,
              style: textStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${post.date}',
                  style: textStyle,
                ),

                SizedBox(width: 8.0,),

                Icon(
                  Icons.thumb_up,
                  size: 14,
                  color: AppColors.headingColor,
                ),

                SizedBox(width: 1.0,),

                Text(
                  '${post.likes}',
                  style: textStyle,
                ),

                SizedBox(width: 8.0,),

                Icon(
                  Icons.comment,
                  size: 14,
                  color: AppColors.headingColor,
                ),

                Text(
                  '${post.comments}',
                  style: textStyle,
                ),

                SizedBox(width: 10,),

                IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 14,
                      color: Colors.red,
                    ),
                    onPressed: delete
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
