import 'package:cs310_project/model/post_class.dart';

class Profile{
  String username;
  String name;
  String lastname;
  String profilePicURL;
  String bio;
  List <Post> posts; // Posts that are shared by this profile
  List <String> locations; // Locations that are followed by this profile
  List <Post> marked; // Posts that are bookmarked by this profile

  Profile({this.username = "", this.name = "", this.lastname = "",
    this.profilePicURL = "", this.bio = "", this.posts,
    this.locations, this.marked});
}