import 'dart:convert';

import 'package:alfa/BlurryDialogs/blurry_dialog.dart';
import 'package:alfa/Chats/chat_page.dart';
import 'package:alfa/HomePage/home_page.dart';
import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:intl/locale.dart';

class PostDetailsPage extends StatefulWidget {
  String postId,
      itemName,
      itemDesc,
      itemImage,
      price,
      location,
      category,
      sellerId,
      sellerName,
      sellerImage,
      sellerContactNo;
  int dislikesCount;

  PostDetailsPage(
      this.postId,
      this.itemName,
      this.itemDesc,
      this.itemImage,
      this.price,
      this.location,
      this.category,
      this.sellerId,
      this.sellerName,
      this.sellerImage,
      this.sellerContactNo,
      this.dislikesCount);

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  

  DatabaseReference usersDetailsRef =
          FirebaseDatabase().reference().child("Users_Details"),
      postsRef = FirebaseDatabase().reference().child("Posts"),
      ordersRef = FirebaseDatabase().reference().child("Orders");

  int timeStamp = DateTime.now().millisecondsSinceEpoch,
      dislikeCountFromFirebase = 0;

  final numberFormatter = NumberFormat("#,##0.00", "en_US");

  String fullNameFromFirebase = "",
      mobileNumberFromFirebase = "",
      currentUserAvatarFromFirebase = "",
      peerUserTokenIdFromFirebase = "";

  bool orderBtn = true, loaderProgress = false;

  DateTime currentDateTime = DateTime.now();
  DateFormat dateFormat = DateFormat("dd MMM, yyyy");
  DateFormat timeFormat = DateFormat("hh:mm a");

  final plugin = PaystackPlugin();

  late String currentUserRecentChatId, peerRecentChatId, sellerStatus;

  fetchUsersDetails() {
    /// Fetch User full name

    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("fullName")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          fullNameFromFirebase = event.snapshot.value;
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

    /// Fetch User mobile number

    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("mobileNumber")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          mobileNumberFromFirebase = event.snapshot.value;
        });
      }
    });

    /// Fetch token id from firebase
    usersDetailsRef
        .child(widget.sellerId)
        .child("tokenId")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        peerUserTokenIdFromFirebase = event.snapshot.value;
      }
    });

    /// Fetch user avatar from firebase

    // usersDetailsRef
    //     .child(FirebaseAuth.instance.currentUser!.uid)
    //     .child("avatar")
    //     .onValue
    //     .listen((event) {
    //   if (event.snapshot.value != null) {
    //     setState(() {
    //       userAvatarUrl = event.snapshot.value;
    //     });
    //   }
    // });
  }

  @override
  void initState() {
    plugin.initialize(publicKey: payStackPublicKey);

    currentUserRecentChatId =
        FirebaseAuth.instance.currentUser!.uid + "-" + widget.sellerId;
    peerRecentChatId =
        widget.sellerId + "-" + FirebaseAuth.instance.currentUser!.uid;

    fetchUsersDetails();

    /// Fetch post dislike count
    postsRef
        .child(widget.postId)
        .child("dislikesCount")
        .onValue
        .listen((event) {
      setState(() {
        dislikeCountFromFirebase = event.snapshot.value;
      });
    });

    /// Fetch seller status
    usersDetailsRef
        .child(widget.sellerId)
        .child("status")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          sellerStatus = event.snapshot.value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 145, 196, 146),
                image: DecorationImage(
                    image: NetworkImage(widget.itemImage), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12)),
          ),
          topMargin(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.itemName.toUpperCase(),
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  topMargin(4),
                  Text(
                    "GH₵" + numberFormatter.format(int.parse(widget.price)),
                    style: GoogleFonts.quicksand(fontSize: 17),
                  ),
                  topMargin(15),
                  Text(widget.itemDesc),
                ],
              )),
              FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 123, 204, 126),
                onPressed: () {
                  int dislikeToSave = dislikeCountFromFirebase + 1;

                  postsRef
                      .child(widget.postId)
                      .child("dislikesCount")
                      .set(dislikeToSave)
                      .then((value) {
                    showNormalToastBottom("Item Disliked");
                  });
                },
                child: Icon(Icons.thumb_down),
              )
            ],
          ),
          topMargin(5),
          Divider(
            color: Colors.grey,
          ),
          topMargin(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(widget.location, textAlign: TextAlign.center),
                  topMargin(5),
                  Text(
                    "Location",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  )
                ],
              ),
              Column(
                children: [
                  Text(widget.category, textAlign: TextAlign.center),
                  topMargin(5),
                  Text("Category",
                      style: TextStyle(fontSize: 16, color: Colors.black))
                ],
              ),
              Column(
                children: [
                  Text(
                    widget.sellerName,
                    textAlign: TextAlign.center,
                  ),
                  topMargin(5),
                  Text("Seller Name",
                      style: TextStyle(fontSize: 16, color: Colors.black))
                ],
              ),
            ],
          ),
          topMargin(10),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                        visible: loaderProgress,
                        // ignore: prefer_const_constructors
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                              color: primaryColorGreen),
                        )),
                    Visibility(
                      visible: orderBtn,
                      child: Expanded(
                          child: Container(
                              height: 45,
                              width: double.infinity,
                              child: ElevatedButton(
                                child: Text(
                                    widget.sellerId ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                        ? "Delete Order"
                                        : "Place Order Now",
                                    style: GoogleFonts.quicksand()),
                                onPressed: () {
                                   
                                  widget.sellerId ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? showDeletePostBlurryDialog(
                                          context, widget.postId)
                                      : showConfirmOrderBlurryDialog(context);
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        widget.sellerId ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? primaryColorRed
                                            : primaryColorGreen),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)))),
                              ))),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: widget.sellerId ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? 0
                              : 8),
                    ),
                    Visibility(
                        visible: widget.sellerId ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? false
                            : true,
                        child: FloatingActionButton(
                          backgroundColor: Color.fromARGB(255, 123, 204, 126),
                          heroTag: "chat",
                          onPressed: () {
                            goToNewPage(ChatPage(
                                widget.sellerId,
                                widget.sellerName,
                                widget.sellerImage,
                              
                                currentUserRecentChatId));
                          },
                          child: Icon(Icons.chat_outlined),
                        ))
                  ]),
            ),
          )
        ]),
      ),
    );
  }

  addToNotificationsList(String senderId, senderName, receiverId, receiverName,
      title, description) async {
    String notifUrl =
        "https://alfa-e718f-default-rtdb.firebaseio.com/Notifications.json";

    var response = await http.post(Uri.parse(notifUrl),
        body: json.encode({
          "senderId": senderId,
          "senderName": senderName,
          "receiverId": receiverId,
          "receiverName": receiverName,
          "title": title,
          "description": description,
          "date": dateFormat.format(currentDateTime),
          "time": timeFormat.format(currentDateTime),
        }));

    if (response.statusCode == 200) {
      setState(() {
        sendNotification(
            [peerUserTokenIdFromFirebase],
            "$fullNameFromFirebase just placed an order now for " +
                widget.itemName,
            "New Order Alert");
        showNormalToastBottom("Order Successfully Placed");

        orderBtn = true;
        loaderProgress = false;
      });
    }
  }

  redirectUserToPayStack() async {
    int amountToCharge = (int.parse(widget.price) * 100);

    /// Test
    // updateRecordsAfterPayment(amount, month);
    /// Test

    Charge charge = Charge()
      ..amount = amountToCharge
      ..reference = "$timeStamp"
      ..locale = "en_GH"
      ..currency = "GH₵"
      //..accessCode = "0peioxfhpn"
      ..email = FirebaseAuth.instance.currentUser!.email;
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );

    if (response.status == true) {
      /// Payment is successful
      saveNewToOrderToDatabase();
    } else {
      /// UNSUCCESSFUL
      showErrorToastBottom("Payment is Unsuccessful, Please Try again!");
    }
  }

  saveNewToOrderToDatabase() {
    setState(() {
      orderBtn = false;
      loaderProgress = true;
    });

    String orderId = ordersRef.push().key;

    ordersRef.child(orderId).set({
      "orderId": orderId,
      "itemName": widget.itemName,
      "itemDesc": widget.itemDesc,
      "itemImage": widget.itemImage,
      "category": widget.category,
      "price": widget.price,
      "sellerId": widget.sellerId,
      "sellerName": widget.sellerName,
      "sellerNumber": widget.sellerContactNo,
      "buyerId": FirebaseAuth.instance.currentUser!.uid,
      "buyerName": fullNameFromFirebase,
      "buyerNumber": mobileNumberFromFirebase,
      "completedStatus": false
    }).then((value) {
      addToNotificationsList(
          FirebaseAuth.instance.currentUser!.uid,
          fullNameFromFirebase,
          widget.sellerId,
          widget.sellerName,
          "New Order Alert",
          "$fullNameFromFirebase just placed an order now for " +
              widget.itemName);
    });
  }

  showConfirmOrderBlurryDialog(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback continueCallBack = () {
      Navigator.of(context).pop();
      // code on continue comes here

      redirectUserToPayStack();
    };

    BlurryDialog alert = BlurryDialog(
        "Confirm Order",
        "You are about to order for ${widget.itemName} at"
            " the rate of \$${numberFormatter.format(int.parse(widget.price))} from ${widget.sellerName}.\n\n"
            "Are you sure you want to proceed?",
        continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeletePostBlurryDialog(BuildContext context, String orderId) {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback continueCallBack = () {
      Navigator.of(context).pop();
      // code on continue comes here

      // showNormalToastBottom(orderId);
      setState(() {
        orderBtn = false;
        loaderProgress = true;
      });
      postsRef.child(orderId).remove().then((value) {
        showNormalToastBottom("Deleted!");
        goToNewPage(HomePage());
        setState(() {
          orderBtn = true;
          loaderProgress = false;
        });
      });
    };

    BlurryDialog alert = BlurryDialog(
        "Delete Order",
        "You are about to delete ${widget.itemName} now. Proceed?",
        continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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

  goToNewPage(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }
}
