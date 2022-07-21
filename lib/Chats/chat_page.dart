// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:alfa/constants.dart';
import 'package:bubble/bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:timeago/timeago.dart' as timeago;

import '../Models/chats.dart';

class ChatPage extends StatefulWidget {
  String peerId, peerFullName, peerAvatar, currentUserRecentChatId;

  ChatPage(this.peerId, this.peerFullName, this.peerAvatar,
      this.currentUserRecentChatId);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DatabaseReference usersDetailsRef =
          FirebaseDatabase().reference().child("Users_Details"),
      chatsRef = FirebaseDatabase().reference().child("Chats");

  List<Chats> chatsList = [];
  late Chats chats;

  late String chatId,
      lastSeenTimeStampFromFirebase = "",
      peerStatusFromFirebase = "",
      currentUserStatus = "",
      currentUserFullNameFromFirebase = "",
      currentUserAvatarFromFirebase = "",
      peerUserTokenIdFromFirebase = "";

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateTime now = DateTime.now();

  final key = new GlobalKey<ScaffoldState>();

  TextEditingController messageTC = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    usersDetailsRef.keepSynced(true);

    chatsRef.keepSynced(true);

    fetchUserDetails();

    String currentUserRecentChatId =
            FirebaseAuth.instance.currentUser!.uid + "-" + widget.peerId,
        peerRecentChatId =
            widget.peerId + "-" + FirebaseAuth.instance.currentUser!.uid;

    /// Fetch chat id using currentUserRecentChatId from Firebase
    chatsRef.child(widget.currentUserRecentChatId).once().then((snapshot) {
      setState(() {
        if (snapshot.value != null) {
          chatId = currentUserRecentChatId;
          fetchChatList(chatId);
        } else {
          chatId = peerRecentChatId;
          fetchChatList(chatId);
        }
      });
    });
    super.initState();
  }

  fetchUserDetails() {

 /// Fetch peer status from firebas
    usersDetailsRef
        .child(widget.peerId)
        .child("status")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          peerStatusFromFirebase = event.snapshot.value;
        });
      }
    });



    /// Fetch fullName from firebas
    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("fullName")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          currentUserFullNameFromFirebase = event.snapshot.value;
        });
      }
    });

    /// Fetch current user avatar from firebase
    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("avatar")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          currentUserAvatarFromFirebase = event.snapshot.value;
        });
      }
    });

    /// Fetch lastSeenTImeStamp from firebase
    usersDetailsRef
        .child(widget.peerId)
        .child("lastSeenTimeStamp")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          lastSeenTimeStampFromFirebase = event.snapshot.value;
        });
      }
    });

    /// Fetch current user status from firebas
    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("status")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          currentUserStatus = event.snapshot.value;
        });
      }
    });

    /// Fetch token id from firebase
    usersDetailsRef
        .child(widget.peerId)
        .child("tokenId")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        peerUserTokenIdFromFirebase = event.snapshot.value;
      }
    });
  }

  fetchChatList(String chatId) {
    chatsRef.child(chatId).onValue.listen((event) {
      var KEYS = event.snapshot.value.keys;
      var DATA = event.snapshot.value;

      chatsList.clear();

      for (var individualKey in KEYS) {
        chats = Chats(
          DATA[individualKey]["chatId"],
          DATA[individualKey]["messageId"],
          DATA[individualKey]["from"],
          DATA[individualKey]["to"],
          DATA[individualKey]["message"],
          DATA[individualKey]["timeStamp"],
        );

        setState(() {
          chatsList.insert(0, chats);
        });
      }

      /// Set recent chat message as read
      usersDetailsRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("Recent_Chats")
          .child(widget.currentUserRecentChatId)
          .child("read")
          .set("true");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          toolbarHeight: 100,
          centerTitle: false,
          backgroundColor: primaryColorGreen,
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 127, 195, 133),
                    radius: 30,
                    backgroundImage: NetworkImage(widget.peerAvatar),
                  ),
                  Positioned(
                      right: 4,
                      top: 45,
                      bottom: 8,
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: peerStatusFromFirebase == "online"
                            ? Colors.lightGreen
                            : Colors.grey,
                      ))
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // widget.user.name,
                    convertToTitleCase(widget.peerFullName),
                    style: TextStyle(fontSize: 18),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3),
                  ),
                  Text(
                    peerStatusFromFirebase != "online"
                        ? convertToTitleCase("Offline"
                            // Jiffy(lastSeenTimeStampFromFirebase)
                            //     .fromNow()

                            // timeago.format(
                            //     DateTime.tryParse(lastSeenTimeStampFromFirebase)
                            //         as DateTime)

                            )
                        : "Online",
                    // ignore: prefer_const_constructors
                    style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 232, 224, 224),
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
          elevation: 0,
        ),
        body: Column(children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: chatsList.isEmpty
                    ? Container(
                        margin: EdgeInsets.only(top: 50.0),
                        child: const Center(
                          child: Text(
                            "No recent chats available to show",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic),
                          ),
                        ))
                    : ListView.builder(
                        // physics: NeverScrollableScrollPhysics(),

                        reverse: true,
                        shrinkWrap: true,
                        itemCount: chatsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ChatListsUI(
                              chatsList[index].chatId,
                              chatsList[index].messageId,
                              chatsList[index].from,
                              chatsList[index].to,
                              chatsList[index].message,
                              chatsList[index].timeStamp);
                        },
                      ),
                //Conversation(user: widget.user),
              ),
            ),
          ),
          buildChatComposer(),
        ]));
  }

  Widget ChatListsUI(String chatId, String messageId, String from, String to,
      String message, String timeStamp) {
    String messageTime = timeago
        .format(DateTime.tryParse(timeStamp) as DateTime)
        .replaceAll("ago", "");

    // timeago.format(DateTime.tryParse(timeStamp)).length >
    //         11
    //     ? ""
    //     : timeago.format(DateTime.tryParse(timeStamp)).replaceAll("ago", "");

    return Container(
        margin: from == FirebaseAuth.instance.currentUser!.uid
            ? EdgeInsets.only(left: 95)
            : EdgeInsets.only(right: 95),
         child:
        // Swipeable(
        //     threshold: 60.0,
        //     onSwipeRight: () {
        //       // // showNormalToastCenter(message);
        //       // setState(() {
        //       //   replyingTextToSave = message;
        //       //   replyingTextVisibility = true;
        //       // });
        //     },
        //     onSwipeLeft: null,
        //     background: Container(
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.all(
        //           Radius.circular(8.0),
        //         ),
        //         // color: Colors.grey[300]
        //       ),
        //       child: ListTile(
        //         leading: Container(
        //           width: 12.0,
        //           height: 12.0,
        //           decoration: BoxDecoration(
        //             shape: BoxShape.circle,
        //             // color: Colors.blue
        //             //leftSelected ? Colors.blue[500] : Colors.grey[600],
        //           ),
        //         ),
        //         trailing: Container(
        //           width: 12.0,
        //           height: 12.0,
        //           decoration: BoxDecoration(
        //             shape: BoxShape.circle,
        //             //  color: Colors.blue
        //
        //             // rightSelected
        //             //     ? Colors.lightGreen[500]
        //             //     : Colors.grey[600],
        //           ),
        //         ),
        //       ),
        //     ),
        //     child:


            Align(
              alignment: from == FirebaseAuth.instance.currentUser!.uid
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: Container(
                  child: Row(
                      mainAxisAlignment:
                          from == FirebaseAuth.instance.currentUser!.uid
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Visibility(
                      visible: from == FirebaseAuth.instance.currentUser!.uid
                          ? false
                          : true,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5.0, right: 5.0),
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFCBB6E9),
                          radius: 12,
                          backgroundImage: NetworkImage(widget.peerAvatar),
                        ),
                      ),
                    ),
                    Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onDoubleTap: () {
                            Clipboard.setData(new ClipboardData(text: message));
                            showNormalToastCenter("Copied to Clipboard");
                            // showNormalToastBottom("Copied to Clipboard");
                          },
                          onLongPress: () {},
                          child: Visibility(
                            // visible: message.toLowerCase() != "wave" &&
                            //         message.toLowerCase() != "image"
                            //     ? true
                            //     : false,
                            child: Bubble(
                                //  margin: BubbleEdges.only(top: 10),
                                radius: Radius.circular(20.0),
                                //  alignment: Alignment.topRight,
                                nip: from ==
                                        FirebaseAuth.instance.currentUser!.uid
                                    ? BubbleNip.rightBottom
                                    : BubbleNip.leftBottom,
                                color: from ==
                                        FirebaseAuth.instance.currentUser!.uid
                                    ? Color.fromARGB(255, 118, 169, 120)
                                    : Colors.grey,

                                // ? Colors.blueGrey
                                // : Colors.grey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Visibility(
                                    //     visible:
                                    //         replyingText != null ? true : false,
                                    //     child: Container(
                                    //       margin: EdgeInsets.only(bottom: 5),
                                    //       decoration: BoxDecoration(
                                    //         color: Colors.white30,
                                    //         borderRadius: BorderRadius.all(
                                    //             Radius.circular(12)),
                                    //       ),
                                    //       // color: Colors.white30,
                                    //       width: double.infinity,
                                    //       height: 45.0,
                                    //       child: Row(
                                    //         children: [
                                    //           Container(
                                    //             margin: EdgeInsets.only(
                                    //                 top: 5, bottom: 5),
                                    //             child: VerticalDivider(
                                    //               thickness: 5,
                                    //               color: Colors.grey,
                                    //             ),
                                    //           ),
                                    //           Container(
                                    //             margin:
                                    //                 EdgeInsets.only(left: 4),
                                    //             child: Text(
                                    //               replyingText != null
                                    //                   ? "$replyingText"
                                    //                   : "",
                                    //               maxLines: 1,
                                    //               overflow:
                                    //                   TextOverflow.ellipsis,
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     )),

                                    Container(
                                      margin: EdgeInsets.all(3),
                                      child: Text(
                                        message,
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.white),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(right: 3.0, top: 4.0, bottom: 4),
                          child: Text(
                            messageTime,
                            style: TextStyle(color: Colors.grey, fontSize: 9),
                          ),
                        )
                      ],
                    )),
                  ])),
            )
      //  )

    );
  }

  Container buildChatComposer() {
    return Container(
      padding: EdgeInsets.all(10),
      //EdgeInsets.symmetric(horizontal: 20),
      //  color: Colors.white,
      // height: 100,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14),

              // height: 50,
              decoration: BoxDecoration(
                  //  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                  border:
                      Border.all(color: Color.fromARGB(255, 225, 223, 223))),
              child: Row(
                children: [
                  // Icon(
                  //   Icons.emoji_emotions_outlined,
                  //   color: Colors.grey[500],
                  // ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      controller: messageTC,

                      // ignore: prefer_const_constructors
                      style: TextStyle(
                        fontSize: 14,

                        //   color: Colors.black
                      ),
                      onChanged: (text) {
                        // performActionForTypingStatus(text);
                      },
                      // ignore: prefer_const_constructors
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type your message ...',
                        hintStyle: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          GestureDetector(
              onTap: () {
                if (messageTC.text.isEmpty) {
                  showNormalToastBottom("You cannot send an empty message");
                }

                // else if (blockTitle == "Unblock") {
                //   /// User is blocked

                //   showNormalToastCenter(
                //       "Sorry, you cannot message this user at the moment");
                // }

                else {
                  performActionForSendMessage(messageTC.text);
                }
              },
              child: SizedBox(
                width: 45,
                height: 45,
                child: CircleAvatar(
                  backgroundColor: primaryColorGreen,
                  child: Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Future<Response> sendNotification(
      List<String> tokenIdList, String contents, String heading) async {
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id": oneSignalAppID,
        //kAppId is the App Id that one get from the OneSignal When the application is registered.

        "include_player_ids": tokenIdList,
        //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

        // android_accent_color reprsent the color of the heading text in the notifiction
        "android_accent_color": "FF9976D2",

        "small_icon": currentUserAvatarFromFirebase,

        // "large_icon":
        //     "https://www.filepicker.io/api/file/zPloHSmnQsix82nlj9Aj?filename=name.jpg",

        "headings": {"en": heading},

        "contents": {"en": contents},
      }),
    );
  }

  void performActionForSendMessage(String message) {
    String currentDateForPost = dateFormat.format(DateTime.now());

    String messageToSend = message;

    String messageId = chatsRef.child(chatId).push().key;

    chatsRef.child(chatId).child(messageId).set({
      "chatId": chatId,
      "messageId": messageId,
      "from": FirebaseAuth.instance.currentUser!.uid,
      "to": widget.peerId,
      "message": messageToSend,
      "timeStamp": currentDateForPost + "Z"
    }).then((result) {
      /// Send notification
      sendNotification([peerUserTokenIdFromFirebase], messageToSend,
          currentUserFullNameFromFirebase);
    });

    String currentUserRecentChatId =
        FirebaseAuth.instance.currentUser!.uid + "-" + widget.peerId;
    String peerRecentChatId =
        widget.peerId + "-" + FirebaseAuth.instance.currentUser!.uid;

    /// Save typing status to false
    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("Recent_Chats")
        .child(widget.currentUserRecentChatId)
        .child("typing")
        .set("false");

    saveRecentChatForCurrentUser(currentUserRecentChatId, widget.peerFullName,
        widget.peerAvatar, messageToSend);

    saveRecentChatForPeer(peerRecentChatId);

    setState(() {
      messageTC.clear();
    });
  }

  void saveRecentChatForPeer(String peerRecentChatId) {
    String currentDateForChat = dateFormat.format(DateTime.now());
    usersDetailsRef
        .child(widget.peerId)
        .child("Recent_Chats")
        .child(peerRecentChatId)
        .set({
      "peerId": FirebaseAuth.instance.currentUser!.uid,
      "peerName": currentUserFullNameFromFirebase,
      "peerAvatar": currentUserAvatarFromFirebase,
      "peerStatus": currentUserStatus,
      "lastMessage": messageTC.text,
      "read": "false",
      "timeStamp": currentDateForChat
    });
  }

  void saveRecentChatForCurrentUser(String currentUserRecentChatId,
      String peerFullName, String peerAvatar, String message) {
    String currentDateForChat = dateFormat.format(DateTime.now());
    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("Recent_Chats")
        .child(currentUserRecentChatId)
        .set({
      "peerId": widget.peerId,
      "peerName": peerFullName,
      "peerAvatar": peerAvatar,
      "peerStatus": peerStatusFromFirebase,
      "lastMessage": message,
      "read": "true",
      "timeStamp": currentDateForChat
    });
  }

  String convertToTitleCase(String text) {
    if (text == null) {
      // return null;
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

  showNormalToastCenter(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        gravity: ToastGravity.CENTER);
  }

  showNormalToastBottom(String text) {
    Fluttertoast.showToast(
        msg: text, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
  }

  showErrorToastBottom(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: primaryColorRed);
  }

  Widget topMargin(double margin) {
    return Container(
      margin: EdgeInsets.only(top: margin),
    );
  }
}
