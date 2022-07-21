// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:alfa/Models/posts.dart';
import 'package:alfa/Notifications/notifications_page.dart';
import 'package:alfa/Profile/edit_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../HomePage/posts_details_page.dart';
import '../InfoPages/contact_us_page.dart';
import '../constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseReference postsRef = FirebaseDatabase().reference().child("Posts");
  DatabaseReference usersDetailsRef =
      FirebaseDatabase().reference().child("Users_Details");
  List<Posts> postsList = [], sortPostList = [];

  var postsUrl = "https://alfa-e718f-default-rtdb.firebaseio.com/Posts.json?";

  late Posts posts;

  final numberFormatter = NumberFormat("#,##0.00", "en_US");

  String fullNameFromFirebase = "",
      userAvatarUrl = "",
      defaultAvatarFromFirebaseStorage =
          "https://firebasestorage.googleapis.com/v0/b/alfa-e718f.appspot.com/o/default_images%2Fdefault_avatar.png?alt=media&token=bdd51c63-438e-4621-88ca-f47c29b5bb4e";

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

    /// Fetch user avatar from firebase

    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("avatar")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          userAvatarUrl = event.snapshot.value;
        });
      }
    });
  }

  fetchPosts() async {
    postsRef.onValue.listen((event) {
      // ignore: non_constant_identifier_names
      var KEYS = event.snapshot.value.keys;
      // ignore: non_constant_identifier_names
      var DATA = event.snapshot.value;

      postsList.clear();

      for (var individualKey in KEYS) {
        posts = Posts(
          DATA[individualKey]["postId"],
          DATA[individualKey]["itemName"],
          DATA[individualKey]["itemDesc"],
          DATA[individualKey]["itemImage"],
          DATA[individualKey]["price"],
          DATA[individualKey]["location"],
          DATA[individualKey]["category"],
          DATA[individualKey]["sellerId"],
          DATA[individualKey]["sellerName"],
          DATA[individualKey]["sellerImage"],
          DATA[individualKey]["sellerContactNo"],
          DATA[individualKey]["dislikesCount"],
        );

        setState(() {
          //  postsList.add(posts);
          postsList.insert(0, posts);

          sortPostList = postsList.where((element) {
            return element.sellerId == FirebaseAuth.instance.currentUser!.uid;
          }).toList();
        });
      }
    });
  }

  @override
  void initState() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    usersDetailsRef.keepSynced(true);
    postsRef.keepSynced(true);

    fetchUsersDetails();
    fetchPosts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(12),
        child: ListView(children: [
          Container(
              width: double.infinity,
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 200,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 145, 196, 146),
                        image: DecorationImage(
                            image: userAvatarUrl != ""
                                ? NetworkImage(userAvatarUrl)
                                : NetworkImage(
                                    defaultAvatarFromFirebaseStorage),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullNameFromFirebase,
                        style: GoogleFonts.gruppo(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      topMargin(4),
                      Text(
                        "${FirebaseAuth.instance.currentUser!.email}",
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: 6),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        share(
                                            "Hello, there",
                                            "I am active on ALFA. Join me there",
                                            "https://alfa.com");
                                      },
                                      label: Text(
                                        "Share",
                                        style: GoogleFonts.quicksand(
                                            color: primaryColorGreen,
                                            fontSize: 12),
                                      ),
                                      icon: Icon(
                                        Icons.share_outlined,
                                        color: primaryColorGreen,
                                        size: 15,
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: BorderSide(
                                                  color: primaryColorGreen),
                                            ),
                                          )),
                                    )),
                                Expanded(
                                    child: ElevatedButton.icon(
                                  onPressed: () {
                                    goToNewPage(ContactUsPage());
                                  },
                                  label: Text(
                                    "Support",
                                    style: GoogleFonts.quicksand(
                                        color: primaryColorGreen, fontSize: 12),
                                  ),
                                  icon: Icon(
                                    Icons.help_outline,
                                    color: primaryColorGreen,
                                    size: 15,
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: BorderSide(
                                                  color: primaryColorGreen)))),
                                ))
                              ]),
                          topMargin(2),
                          Container(
                            width: 200,
                            // height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                goToNewPage(EditProfilePage());
                              },
                              icon: Icon(Icons.edit_outlined),
                              label: Text("Edit Profile"),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      primaryColorGreen),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)))),
                            ),
                          )
                        ],
                      ))
                    ],
                  ))
                ],
              )),
          topMargin(40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "POSTS",
                style: GoogleFonts.gruppo(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  goToNewPage(NotificationsPage());
                },
                child: Icon(
                  Icons.notifications_outlined,
                  color: Color.fromARGB(255, 82, 82, 82),
                ),
              )
            ],
          ),
          topMargin(8),
          Divider(
            color: Colors.grey,
          ),
          topMargin(10),
          sortPostList.isEmpty
              ? Container(
                  margin: EdgeInsets.only(top: 140),
                  child: Column(
                    children: [
                      Icon(
                        Icons.feed_outlined,
                        size: 60,
                        color: Color.fromARGB(255, 157, 211, 159),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                      ),
                      Text("No available posts to show at the moment")
                    ],
                  ))
              : GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: ((context, index) {
                    return postsUI(
                        sortPostList[index].postId,
                        sortPostList[index].itemName,
                        sortPostList[index].itemDesc,
                        sortPostList[index].itemImage,
                        sortPostList[index].price,
                        sortPostList[index].location,
                        sortPostList[index].category,
                        sortPostList[index].sellerId,
                        sortPostList[index].sellerName,
                        sortPostList[index].sellerImage,
                        sortPostList[index].sellerContactNo,
                        sortPostList[index].dislikesCount);
                  }),
                  itemCount: sortPostList.length,
                )
        ]),
      ),
    );
  }

  Widget postsUI(
      String postId,
      String itemName,
      String itemDesc,
      String itemImage,
      String price,
      String location,
      String category,
      String sellerId,
      String sellerName,
      String sellerImage,
      String sellerContactNo,
      int dislikesCount) {
    return GestureDetector(
        onTap: () {
          goToNewPage(PostDetailsPage(
              postId,
              itemName,
              itemDesc,
              itemImage,
              price,
              location,
              category,
              sellerId,
              sellerName,
              sellerImage,
              sellerContactNo,
              dislikesCount));
        },
        child: Container(
          height: 300,
          margin: EdgeInsets.only(bottom: 5),
          child: Card(
              elevation: 4,
              shadowColor: primaryColorGreen,
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent)),
              child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
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
                      topMargin(7),
                      Container(
                          margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                          child: Text(
                            itemName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      topMargin(3),
                      Container(
                        margin: EdgeInsets.only(top: 2, left: 5, right: 5),
                        child: Text(
                            "GH₵" + numberFormatter.format(int.parse(price))),
                      ),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 5, left: 5, right: 5, bottom: 5),
                            child: Text(
                              category,
                              style: TextStyle(
                                  color: primaryColorRed, fontSize: 12),
                            )),
                      ))
                    ]),
              )),
        ));
  }

  Future<void> share(
    String title,
    text,
    url,
  ) async {
    await FlutterShare.share(
        title: title,
        text: text,
        linkUrl: url,
        chooserTitle: 'Share to friends');
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
