// ignore_for_file: prefer_const_constructors

import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Models/recent_chats_model.dart';
import 'chat_page.dart';

class RecentChats extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecentChatsState();
  }
}

class RecentChatsState extends State<RecentChats> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference usersDetailsRef =
      FirebaseDatabase().reference().child("Users_Details");

  List<RecentChatsModel> recentChatsModelList = [];
  late RecentChatsModel recentChatsModel;

  String defaultAvatarFromFirebaseStorage =
      "https://firebasestorage.googleapis.com/v0/b/alfa-e718f.appspot.com/o/default_images%2Fdefault_avatar.png?alt=media&token=bdd51c63-438e-4621-88ca-f47c29b5bb4e";

  @override
  void initState() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    usersDetailsRef.keepSynced(true);

    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("Recent_Chats")
        .orderByChild("timeStamp")
        .onValue
        .listen((event) {
      var KEYS = event.snapshot.value.keys;
      var DATA = event.snapshot.value;

      recentChatsModelList.clear();

      for (var individualKey in KEYS) {
        recentChatsModel = RecentChatsModel(
            DATA[individualKey]["peerId"],
            DATA[individualKey]["peerName"],
            DATA[individualKey]["peerAvatar"],
            DATA[individualKey]["peerStatus"],
            DATA[individualKey]["lastMessage"],
            DATA[individualKey]["read"],
            DATA[individualKey]["timeStamp"]);

        //  postsList.add(posts);
        setState(() {
          recentChatsModelList.insert(0, recentChatsModel);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Chats"),
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        height: double.infinity,
        // color: widget.showInDrawer == true ? kPrimaryLightColor : null,
        child: recentChatsModelList.length == 0
            ? Container(
                margin: EdgeInsets.only(top: 50.0),
                child: const Center(
                  child: Text(
                    "No recent chats to show",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ))
            : ListView.builder(
                // physics: NeverScrollableScrollPhysics(),

                shrinkWrap: true,
                itemCount: recentChatsModelList.length,
                itemBuilder: (BuildContext context, int index) {
                  return RecentsChatUI(
                    recentChatsModelList[index].peerId,
                    recentChatsModelList[index].peerName,
                    recentChatsModelList[index].peerAvatar,
                    recentChatsModelList[index].peerStatus,
                    recentChatsModelList[index].lastMessage,
                    recentChatsModelList[index].read,
                    recentChatsModelList[index].timeStamp,
                  );
                },
              ),
      ),
    );
  }

  String convertToTitleCase(String text) {
    if (text == null) {
      //  return null;
    }

    if (text.length <= 1) {
      return text.toUpperCase();
    }

    // Split string into multiple words
    final List<String> words = text.split(' ');

    // Capitalize first letter of each words
    final capitalizedWords = words.map((word) {
      if (word.trim().isNotEmpty) {
        final String firstLetter = word.trim().substring(0, 1).toUpperCase();
        final String remainingLetters = word.trim().substring(1);

        return '$firstLetter$remainingLetters';
      }
      return '';
    });

    // Join/Merge all words back to one String
    return capitalizedWords.join(' ');
  }

  Widget RecentsChatUI(String peerId, String peerName, String peerAvatar,
      String peerStatus, String lastMessage, String read, String timeStamp) {
    String currentUserRecentChatId =
        FirebaseAuth.instance.currentUser!.uid + "-" + peerId;

    String peerRecentChatId =
        peerId + "-" + FirebaseAuth.instance.currentUser!.uid;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(peerId, peerName, peerAvatar
                  , currentUserRecentChatId)));
      },
      child: Ink(
        child: Container(
            margin: EdgeInsets.all(8.0),
            // height: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    peerAvatar == ""
                        ? CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 148, 234, 176),
                            radius: 25,
                            backgroundImage:
                                NetworkImage(defaultAvatarFromFirebaseStorage),
                          )
                        : Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(0xFFCBB6E9),
                                radius: 25,
                                backgroundImage: NetworkImage(peerAvatar),
                              ),
                              // Positioned(
                              //     right: 4,
                              //     top: 40,
                              //     bottom: 8,
                              //     child: Icon(
                              //       Icons.circle,
                              //       size: 12,
                              //       color: Colors.grey,
                              //     ))
                            ],
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              // widget.user.name,
                              convertToTitleCase(peerName),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      read == "true" ? null : FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 3.0),
                            ),
                          ],
                        ),
                        Stack(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Visibility(
                                visible: false,
                                // typingStatusFromFirebase == "true"
                                //     ? true
                                //     : false,
                                child: Image.asset(
                                  "assets/images/typing_indicator.gif",
                                  width: 28.0,
                                  height: 28.0,
                                )),
                            Container(
                              // margin: EdgeInsets.only(
                              //     left: typingStatusFromFirebase == "true"
                              //         ? 30.0
                              //         : 0.0),
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                lastMessage,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: read == "true"
                                        ? null
                                        : FontWeight.bold),
                              ),
                            ),
                            Visibility(
                              visible: read == "true" ? false : true,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                      margin:
                                          EdgeInsets.only(left: 5, right: 5),
                                      child: Icon(
                                        Icons.donut_small_rounded,
                                        size: 20,
                                        color:
                                            Color.fromARGB(255, 135, 201, 138),
                                      ))),
                            )
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 60.0),
                  child: Divider(
                    color: Colors.grey,
                    thickness: 0.3,
                  ),
                )
              ],
            )),
      ),
    );
  }
}
