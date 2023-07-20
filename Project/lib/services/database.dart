import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';


class DatabaseMethods{
 Future addUserInfoToDB(
     String userId, Map<String, dynamic> userInfoMap) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>>getUserByUserName(String username)async{
   return await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: username).snapshots();
  }
  
  Future addMessage(String chatRoomId, String messageId, Map messageInfoMap)async{
  return FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(chatRoomId)
      .collection("chats")
      .doc(messageId)
      .set(messageInfoMap);
  }

  updateLastMessageSend(String chatRoomId, Map lastMessageInfoMap){
  return FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(chatRoomId).update(lastMessageInfoMap);
  }

  createChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
  final snapShot = await FirebaseFirestore.instance.collection("chatrooms")
  .doc(chatRoomId)
  .get();

  if(snapShot.exists){
   //chatroom already exists
   return true;
  }
  else{
   //chatroom does not exist
   return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId)
       .set(chatRoomInfoMap);
  }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId)async{
   return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId)
       .collection("chats")
       .orderBy("ts",descending: true)
       .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
   String myUserName = await SharedPreferenceHelper().getUserName();
   return FirebaseFirestore.instance
       .collection("chatrooms")
       .orderBy("lastMessageSendTs",descending: true)
       .where("users",arrayContains: myUserName)
       .snapshots();
  }


  Future<QuerySnapshot>getUserInfo(String username)async{
  return await FirebaseFirestore.instance.collection("users")
      .where("username", isEqualTo: username)
      .get();
  }
}