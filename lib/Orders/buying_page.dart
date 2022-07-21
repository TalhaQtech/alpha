// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:alfa/Models/orders.dart';
import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../BlurryDialogs/blurry_dialog.dart';
import '../Chats/chat_page.dart';

class BuyingPage extends StatefulWidget {
  const BuyingPage({Key? key}) : super(key: key);

  @override
  State<BuyingPage> createState() => _BuyingPageState();
}

class _BuyingPageState extends State<BuyingPage> {
  DatabaseReference ordersRef = FirebaseDatabase().reference().child("Orders");

  List<Orders> ordersList = [], sortedList = [];

  var ordersUrl = "https://alfa-e718f-default-rtdb.firebaseio.com/Orders.json?";

  final numberFormatter = NumberFormat("#,##0.00", "en_US");

  DateTime currentDateTime = DateTime.now();
  DateFormat dateFormat = DateFormat("dd MMM, yyyy");
  DateFormat timeFormat = DateFormat("hh:mm a");

  bool cancelBtn = true, loadingProgress = false;

  late Orders orders;

  fetchOrders() async {
    ordersRef.onValue.listen((event) {
      // ignore: non_constant_identifier_names
      var KEYS = event.snapshot.value.keys;
      // ignore: non_constant_identifier_names
      var DATA = event.snapshot.value;

      ordersList.clear();

      for (var individualKey in KEYS) {
        orders = Orders(
            DATA[individualKey]["orderId"],
            DATA[individualKey]["itemName"],
            DATA[individualKey]["itemDesc"],
            DATA[individualKey]["itemImage"],
            DATA[individualKey]["category"],
            DATA[individualKey]["price"],
            DATA[individualKey]["sellerId"],
            DATA[individualKey]["sellerName"],
            DATA[individualKey]["sellerNumber"],
            DATA[individualKey]["buyerId"],
            DATA[individualKey]["buyerName"],
            DATA[individualKey]["buyerNumber"],
            DATA[individualKey]["completedStatus"]);

        setState(() {
          //  postsList.add(posts);
          ordersList.insert(0, orders);

          sortedList = ordersList.reversed.where((element) {
            return element.buyerId == FirebaseAuth.instance.currentUser!.uid;
          }).toList();
        });
      }
    });
  }

  @override
  void initState() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    ordersRef.keepSynced(true);
    fetchOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(9),
        child: sortedList.isEmpty
            ? Column(
             mainAxisAlignment: MainAxisAlignment.center,
             // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                  Icons.inventory_2_outlined,
                  size: 50,
                  color: Color.fromARGB(255, 122, 208, 124),
                ),
                ),
                topMargin(10),
                Text("You do not have any buying history at the moment")
              ])
            : ListView.builder(
                itemCount: sortedList.length,
                itemBuilder: ((context, index) {
                  return ordersUI(
                      sortedList[index].orderId,
                      sortedList[index].itemName,
                      sortedList[index].itemDesc,
                      sortedList[index].itemImage,
                      sortedList[index].category,
                      sortedList[index].price,
                      sortedList[index].sellerId,
                      sortedList[index].sellerName,
                      sortedList[index].sellerNumber,
                      sortedList[index].buyerId,
                      sortedList[index].buyerName,
                      sortedList[index].buyerNumber,
                      sortedList[index].completedStatus);
                })),
      ),
    );
  }

  Widget ordersUI(
      String orderId,
      String itemName,
      String itemDesc,
      String itemImage,
      String category,
      String price,
      String sellerId,
      String sellerName,
      String sellerNumber,
      String buyerId,
      String buyerName,
      String buyerNumber,
      bool completedStatus) {
    return GestureDetector(
        onTap: () {
          
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Card(
              elevation: 4,
              shadowColor: primaryColorGreen,
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)),
              child: Container(
                margin: EdgeInsets.all(6),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 4),
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 145, 196, 146),
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(itemImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              topMargin(3),
                              Text(
                                "\$" +
                                    numberFormatter.format(
                                      int.parse(price),
                                    ),
                                style: TextStyle(fontSize: 19),
                              ),
                            ],
                          ),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: Stack(
                                    children: [
                                      Visibility(
                                          visible: completedStatus == true
                                              ? false
                                              : true,
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: FloatingActionButton(
                                              heroTag: "done",
                                              onPressed: () {
                                                showCompletionDialog(
                                                  context,
                                                  orderId,
                                                  completedStatus,
                                                );
                                              },
                                              child: Icon(Icons.done),
                                              backgroundColor: Color.fromARGB(
                                                  255, 136, 214, 139),
                                            ),
                                          )),
                                      Visibility(
                                        visible: completedStatus,
                                        child: Container(
                                          margin: EdgeInsets.all(4),
                                          width: 80,
                                          height: 20,
                                          color: Color.fromARGB(
                                              255, 122, 189, 124),
                                          child: Center(
                                              child: Text(
                                            "Completed",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          )),
                                        ),
                                      ),
                                    ],
                                  )))
                        ],
                      ),
                      topMargin(4),
                      Divider(
                        color: Colors.grey,
                      ),
                      topMargin(3),
                      Text(
                        "Seller Name: $sellerName",
                        // ignore: prefer_const_constructors
                        style: TextStyle(fontSize: 15),
                      ),
                      topMargin(3),
                      Text(
                        "Seller Number: $sellerNumber",
                        // ignore: prefer_const_constructors
                        style: TextStyle(fontSize: 15),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // TextButton(
                          //     onPressed: () {

                                
                          //     },
                          //     child: Text(
                          //       "Chat with Seller",
                          //       style: TextStyle(color: primaryColorGreen),
                          //     )),
                       Expanded(child:  Align(
                          
                          alignment: Alignment.bottomRight,
                          child: Stack(
                            children: [
                              Visibility(
                                  visible: loadingProgress,
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: primaryColorRed,
                                    ),
                                  )),
                              Visibility(
                                  visible: cancelBtn == true
                                      ? (completedStatus == true ? false : true)
                                      : cancelBtn,
                                  child: TextButton(
                                      onPressed: () {
                                        showCancelBlurryDialog(
                                            context,
                                            orderId,
                                            buyerId,
                                            buyerName,
                                            sellerId,
                                            sellerName,
                                            "Order Cancellation for '$itemName'",
                                            "$buyerName has just canceled this order. Thank you.");
                                      },
                                      child: Text(
                                        "Cancel Order",
                                        style: TextStyle(color: Colors.red),
                                      )))
                            ],
                          )))
                        ],
                      )
                    ]),
              )),
        ));
  }

  showCompletionDialog(
      BuildContext context, String orderId, bool completedStatus) async {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback continueCallBack = () async {
      Navigator.of(context).pop();
      // code on continue comes here

      showNormalToastBottom("Loading... please wait");

      String orderUrl =
          "https://alfa-e718f-default-rtdb.firebaseio.com/Orders/$orderId/completedStatus.json";

      var response =
          await http.put(Uri.parse(orderUrl), body: (true.toString()));

      if (response.statusCode == 200) {
        setState(() {
          showNormalToastBottom("Successful");
        });
      } else {
        showErrorToastBottom("Error completing order. please try again" +
            "${response.statusCode}");
      }
    };

    BlurryDialog alert = BlurryDialog(
        "Complete Order", "Mark this order as completed?", continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showCancelBlurryDialog(BuildContext context, orderId, senderId, senderName,
      receiverId, receiverName, title, description) {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback continueCallBack = () async {
      Navigator.of(context).pop();
      // code on continue comes here

      setState(() {
        cancelBtn = false;
        loadingProgress = true;
      });

      var orderToDeleteUrl =
          "https://alfa-e718f-default-rtdb.firebaseio.com/Orders/$orderId.json?";

      var response = await http.delete(Uri.parse(orderToDeleteUrl));

      if (response.statusCode == 200) {
        addToNotificationsList(
            senderId, senderName, receiverId, receiverName, title, description);
      } else {
        showErrorToastBottom("Error canceling order. please try again");
      }
    };

    BlurryDialog alert = BlurryDialog("Cancel Order",
        "Are you sure you want to cancel this order now?", continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
          "read": false
        }));

    if (response.statusCode == 200) {
      setState(() {
        showNormalToastBottom("Successfully Canceled");

        cancelBtn = true;
        loadingProgress = false;
      });
    }
  }

  Widget topMargin(double margin) {
    return Container(
      margin: EdgeInsets.only(top: margin),
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

  goToNewPage(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }
}
