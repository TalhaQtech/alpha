// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:alfa/Models/notifications.dart';
import 'package:alfa/Orders/orders_page.dart';
import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  DatabaseReference notificationsRef =
      FirebaseDatabase().reference().child("Notifications");

  List<Notifications> notificationsList = [], sortList = [];

  String notificationsUrl =
      "https://alfa-e718f-default-rtdb.firebaseio.com/Notifications.json?";

  late Notifications notifications;

  fetchNotifications() async {
    notificationsRef.onValue.listen((event) {
      // ignore: non_constant_identifier_names
      var KEYS = event.snapshot.value.keys;
      // ignore: non_constant_identifier_names
      var DATA = event.snapshot.value;

      notificationsList.clear();

      for (var individualKey in KEYS) {
        notifications = Notifications(
            DATA[individualKey]["senderId"],
            DATA[individualKey]["senderName"],
            DATA[individualKey]["receiverId"],
            DATA[individualKey]["receiverName"],
            DATA[individualKey]["title"],
            DATA[individualKey]["description"],
            DATA[individualKey]["date"],
            DATA[individualKey]["time"],
            DATA[individualKey]["read"]);

        setState(() {
          //  postsList.add(posts);
          notificationsList.insert(0, notifications);

          sortList = notificationsList.reversed
              .where((element) =>
                  element.receiverId == FirebaseAuth.instance.currentUser!.uid)
              .toList();
        });
      }
    });
  }

  @override
  void initState() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    notificationsRef.keepSynced(true);
    fetchNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: sortList.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications,
                    size: 80,
                    color: Color.fromARGB(255, 157, 211, 159),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                  ),
                  Text("Your notication box is empty")
                ],
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: sortList.length,
                itemBuilder: ((context, index) {
                  return notificationsUI(
                    sortList[index].senderId,
                    sortList[index].senderName,
                    sortList[index].receiverId,
                    sortList[index].receiverName,
                    sortList[index].title,
                    sortList[index].description,
                    sortList[index].date,
                    sortList[index].time,
                    sortList[index].read,
                  );
                })),
      ),
    );
  }

  Widget notificationsUI(
      String senderId,
      String senderName,
      String receiverId,
      String receiverName,
      String title,
      String description,
      String date,
      String time,
      bool read) {
    return GestureDetector(
        onTap: () {
          goToNewPage(OrderPage());
        },
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 22,
              ),
              Container(
                margin: EdgeInsets.only(left: 4),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      // fontWeight:
                      //     read != true ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                  ),
                  Text(
                    "$date at $time",
                    style: TextStyle(fontSize: 12),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                  ),
                  Text(
                    description,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                  ),
                  Divider(
                    color: Colors.grey,
                  )
                ],
              ))
            ],
          ),
        ));
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
