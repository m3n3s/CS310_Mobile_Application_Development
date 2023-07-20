import 'package:cs310_project/utils/bottom_nav.dart';
import 'package:cs310_project/utils/connectionCard.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cs310_project/helperfunctions/sharedpref_helper';


class connectionList extends StatefulWidget {
  const connectionList({Key key, this.analytics, this.observer, this.myUsername})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final String myUsername;

  @override
  _connectionListState createState() => _connectionListState();
}

class _connectionListState extends State<connectionList> {
  String _message = '';
  final databaseReference = FirebaseFirestore.instance;
  List <String> connectionList=[] ;

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _setCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Connections',
      screenClassOverride: '/connections',
    );
    setmessage('setCurrentScreen succeeded');
    // print(files);
  }

  Future<void> _setLogEvent() async {
    await widget.analytics.logEvent(
      name: 'Connections_log',
    );
    setmessage('Custom event log succeeded');
  }

  Future<void> check() async {
    QuerySnapshot val;

    try {
      val = await FirebaseFirestore.instance
          .collection('Profile')
          .where('username', isEqualTo: widget.myUsername)
          .get();

    }catch(error){
      print(error);
    }
    if(val.docs.length > 0){
      connectionList = List.from(val.docs[0]["connections"]);
      print(connectionList) ;
    }
    else
      print("length of connections is zero") ;

    setState(() {
      //initState();
    });
  }

  refresh() {
    setState(() {
      initState();
    });
  }



  @override
  void initState() {
    _setCurrentScreen();
    _setLogEvent();
    check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigation(),
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Connections",
          style: TextStyle(
            color: AppColors.headingColor,
            fontWeight: FontWeight.w900,
            fontSize: 30.0,
            letterSpacing: -0.7,
            fontFamily: 'OpenSans',
          ),
        ),
        //   ],
        //   ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        children: [
          for(int i=0; i< connectionList.length; i++)
            connectionCard(
              username: connectionList[i],
              notifyParent: refresh,
            ),
        ],
      ),



      /*
      StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Profiles")
              .where('username', isEqualTo: widget.myUsername)
              .snapshots(),

          // stream: FirebaseFirestore.instance.collection("Notifications").snapshots(),
          // stream: FirebaseFirestore.instance.collection("Notifications").where('profile', isEqualTo: '/Profile/6LfoijN7UntcCewBHqFZ').snapshots(),
          builder: (context, snapshot) {
            print("in connectionList myUsername: " + widget.myUsername) ;

            if (!snapshot.hasData) return const Text("No connections found");

              //itemExtent: 80.0,
              // padding: const EdgeInsets.all(15),
            //  shrinkWrap: true,
             // itemCount: snapshot.data.docs.length,
              // separatorBuilder: (BuildContext context, int index) => const Divider(
              //    color:AppColors.secondary,
              //   thickness: 1,
              // height: 0,
              //       ),
            //  itemBuilder: (context, index) {
            for (var con in snapshot.data.documents["connections"])
              print (con);
               /* return  ListView.builder(
                //itemExtent: 90.0,
               // itemBuilder: (context, i) =>
                //    postsList(context, snapshot.data.docs[0]),
                //separatorBuilder: (_, i) => Divider(),
                    itemBuilder: (context, i)  {
                    for (var con in snapshot.data.docs[0]["connections"])
                      print (con);
                    return Text("Okay") ;
                  },
                itemCount: snapshot.data.docs[0]["connections"].length); */
/*
                    snapshot.data.docs[0]["connections"]
                    .map((connection) => connectionCard(username: connection,))
                    .toList() ;
*/

            //  },

          }),                                         */
      //)
    );
  }
}
