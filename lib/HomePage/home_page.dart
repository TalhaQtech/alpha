// ignore_for_file: prefer_const_constructors
// import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:alfa/Chats/recent_chats.dart';
import 'package:alfa/HomePage/add_new_product.dart';
import 'package:alfa/HomePage/posts_details_page.dart';
import 'package:alfa/InfoPages/contact_us_page.dart';
import 'package:alfa/Models/posts.dart';
import 'package:alfa/Notifications/notifications_page.dart';
import 'package:alfa/Orders/orders_page.dart';
import 'package:alfa/Profile/profile_page.dart';
import 'package:alfa/Subscriptions/subscriptions_page.dart';
import 'package:alfa/constants.dart';
import 'package:alfa/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../BlurryDialogs/blurry_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  DatabaseReference usersDetailsRef =
          FirebaseDatabase().reference().child("Users_Details"),
      postsRef = FirebaseDatabase().reference().child("Posts");

  TextEditingController searchTC = TextEditingController();

  List<Posts> postsList = [], searchLists = [];

  late Posts posts;

  final numberFormatter = NumberFormat("#,##0.00", "en_US");

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

          searchLists = postsList;
        });
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    updateUserToken();
    postsRef.keepSynced(true);
    fetchPosts();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String currentDateForPost = dateFormat.format(DateTime.now());

    if (state == AppLifecycleState.resumed) {
      /// Set status to online
      usersDetailsRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("status")
          .set("online")
          .whenComplete(() {
        /// Update last seen
        usersDetailsRef
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("lastSeenTimeStamp")
            .set(currentDateForPost + "Z");
      });
    } else {
      /// Set status to offline
      usersDetailsRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("status")
          .set("offline")
          .whenComplete(() {
        /// Update last seen
        usersDetailsRef
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("lastSeenTimeStamp")
            .set(currentDateForPost + "Z");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: primaryColorGreen,
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                goToNewPage(NotificationsPage());
              },
              child: Icon(Icons.notifications_outlined),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(child: Image.asset("images/logo.png")),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
              onTap: () {
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.home_outlined,
                color: primaryColorGreen,
              ),
              title: Text(
                "Home",
                style: GoogleFonts.quicksand(
                    color: primaryColorGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 19),
              )),
          ListTile(
              onTap: () {
                goToNewPage(RecentChats());
              },
              leading: Icon(
                Icons.chat_outlined,
                color: primaryColorGreen,
              ),
              title: Text(
                "Chats",
                style: GoogleFonts.quicksand(
                    color: primaryColorGreen, fontSize: 19),
              )),
          ListTile(
              onTap: () {
                goToNewPage(OrderPage());
              },
              leading: Icon(
                Icons.inventory_2_outlined,
                color: primaryColorGreen,
              ),
              title: Text(
                "Orders",
                style: GoogleFonts.quicksand(
                    color: primaryColorGreen, fontSize: 19),
              )),
          ListTile(
              onTap: () {
                goToNewPage(ProfilePage());
              },
              leading: Icon(
                Icons.contacts_outlined,
                color: primaryColorGreen,
              ),
              title: Text(
                "My Profile",
                style: GoogleFonts.quicksand(
                    color: primaryColorGreen, fontSize: 19),
              )),
          ListTile(
              onTap: () {
                goToNewPage(SubscriptionsPage());
              },
              leading: Icon(
                Icons.card_membership_outlined,
                color: primaryColorGreen,
              ),
              title: Text(
                "Subscriptions",
                style: GoogleFonts.quicksand(
                    color: primaryColorGreen, fontSize: 19),
              )),
          ListTile(
              onTap: () {
                goToNewPage(ContactUsPage());
              },
              leading: Icon(
                Icons.contact_phone_outlined,
                color: primaryColorGreen,
              ),
              title: Text(
                "Contact Us",
                style: GoogleFonts.quicksand(
                    color: primaryColorGreen, fontSize: 19),
              )),
          ListTile(
              onTap: () {
                showBlurryDialog(context);
              },
              leading: Icon(
                Icons.logout_outlined,
                color: primaryColorGreen,
              ),
              title: Text(
                "Sign out",
                style: GoogleFonts.quicksand(
                    color: primaryColorGreen, fontSize: 19),
              )),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          goToNewPage(AddNewProduct());
        },
        label: Text("Create A Product To Sell"),
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        // height: 45,
        margin: EdgeInsets.only(top: 12, bottom: 12, left: 7, right: 7),

        child: ListView(children: [
          Container(
            height: 45,
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey)),
            child: Row(children: [
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: TextFormField(
                        onChanged: (value) {
                          searchLists = postsList.where((element) {
                            return element.itemName
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                          setState(() {});
                        },
                        cursorColor: primaryColorGreen,
                        decoration: InputDecoration(
                            hintText: "Search Posts...",
                            hintStyle: GoogleFonts.quicksand(),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            // ignore: prefer_const_constructors
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                      ))),
              Container(
                margin: EdgeInsets.only(left: 4),
              ),
              Icon(
                Icons.search_outlined,
                color: Colors.grey,
              )
            ]),
          ),
          topMargin(20),

          postsList.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Text("No posts to show",
                            style: GoogleFonts.quicksand()))
                  ],
                )
              : GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: ((context, index) {
                    return postsUI(
                        searchLists[index].postId,
                        searchLists[index].itemName,
                        searchLists[index].itemDesc,
                        searchLists[index].itemImage,
                        searchLists[index].price,
                        searchLists[index].location,
                        searchLists[index].category,
                        searchLists[index].sellerId,
                        searchLists[index].sellerName,
                        searchLists[index].sellerImage,
                        searchLists[index].sellerContactNo,
                        searchLists[index].dislikesCount);
                  }),
                  itemCount: searchLists.length,
                )

          //  ListView.builder(
          //   shrinkWrap: true,
          //   itemBuilder: ((context, index) {
          //     return postsUI(
          //         postsList[index].postId,
          //         postsList[index].itemName,
          //         postsList[index].itemDesc,
          //         postsList[index].itemImage,
          //         postsList[index].price,
          //         postsList[index].location,
          //         postsList[index].category,
          //         postsList[index].sellerId,
          //         postsList[index].sellerName,
          //         postsList[index].sellerImage,
          //         postsList[index].sellerContactNo,
          //         postsList[index].dislikesCount);
          //   }),
          //   itemCount: postsList.length,
          // )
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

  showBlurryDialog(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback continueCallBack = () async {
      Navigator.of(context).pop();
      EasyLoading.show();

      await usersDetailsRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("status")
          .set("offline")
          .then((value) {
        FirebaseAuth.instance.signOut().then((value) {
          goToNewPage(WelcomePage());
        });
      });
    };

    BlurryDialog alert = BlurryDialog(
        "Sign out", "Are you sure you want to sign out now?", continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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

  void updateUserToken() async {
    await OneSignal.shared.setAppId(oneSignalAppID);
    var status = await OneSignal.shared.getDeviceState();
    String? tokenId = status?.userId;

    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("tokenId")
        .set(tokenId);
  }
}
