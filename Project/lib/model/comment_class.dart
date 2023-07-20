import 'package:cs310_project/model/profile_class.dart';

class Comment{
  String text;
  String date;
  Profile user;

  Comment({this.text, this.date, this.user});
}