import 'package:cs310_project/model/profile_class.dart';
import 'package:cs310_project/model/comment_class.dart';

class Post {
  String text;
  String date;
  int likes;
  int dislikes;
  int comments; // Number of comments
  List <Comment> commentList;
  String location;
  List <dynamic> tags;
  String postImageURL; // Not sure if we can access the image from database using 'NetworkImage'
  //VideoElement postVideo; // Not sure if 'VideoElement' is correct!!!
  Profile profile; // The profile which shared this post

  // Constructor:
  Post({ this.text = "", this.date = "", this.likes = 0, this.dislikes = 0,
    this.comments = 0, this.commentList, this.location = "",
    this.tags, this.postImageURL = "", this.profile});

  void newComment(Comment c){
    commentList.add(c);
    comments += 1;
  }
}
