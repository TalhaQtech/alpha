// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:alfa/InfoPages/contact_us_page.dart';
import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Models/subscription.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  DatabaseReference usersDetailsRef =
          FirebaseDatabase().reference().child("Users_Details"),
      subscriptonRef = FirebaseDatabase().reference().child("Subscriptions");

  int timeStamp = DateTime.now().millisecondsSinceEpoch;
  final plugin = PaystackPlugin();

  String subscriptionType = "";

  List<Subscription> subList = [];
  late Subscription subscription;

  fetchSubscription() async {
    subscriptonRef.onValue.listen((event) {
      // ignore: non_constant_identifier_names
      var KEYS = event.snapshot.value.keys;
      // ignore: non_constant_identifier_names
      var DATA = event.snapshot.value;

      subList.clear();

      for (var individualKey in KEYS) {
        subscription = Subscription(
          DATA[individualKey]["subId"],
          DATA[individualKey]["amount"],
          DATA[individualKey]["shortDesc"],
        );

        setState(() {
          //  postsList.add(posts);
          subList.insert(0, subscription);

          // searchLists = postsList;
        });
      }
    });
  }

  @override
  void initState() {
    plugin.initialize(publicKey: payStackPublicKey);

    usersDetailsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("subscriptionType")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          subscriptionType = event.snapshot.value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 12, right: 12, top: 50, bottom: 12),
        child: Column(children: [
          Text(
            "SUBSCRIPTIONS",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          topMargin(10),
          Text(
            "Current Plan",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          topMargin(5),
          Text(
            subscriptionType,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          topMargin(25),
          subList.isEmpty
              ? Center(
                  child: Text("No available data to show"),
                )
              : GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: ((context, index) {
                    return SubUI(
                      subList[index].subId,
                      subList[index].amount,
                      subList[index].shortDesc,
                    );
                  }),
                  itemCount: subList.length,
                ),
          topMargin(10),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("CONTACT SUPPORT FOR FURTHER INQUIRIES",
                        style: GoogleFonts.quicksand(color: primaryColorGreen)),
                    onPressed: () {
                      goToNewPage(ContactUsPage());
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        side: MaterialStateProperty.all(
                            BorderSide(color: primaryColorGreen)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)))),
                  )),
            ),
          )
        ]),
      ),
    );
  }

  Widget SubUI(String subId, String amount, String shortDesc) {
    return GestureDetector(
        onTap: () {
          redirectUserToPayStack(int.parse(amount), shortDesc);
        },
        child: Container(
          width: 180,
          height: 180,
          child: Card(
            // color: Color(0xFFE0DEDE),
            shadowColor: Color(0xFFE0DEDE),
            elevation: 5,
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.transparent)),
            child: Container(
              margin: EdgeInsets.all(5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GH₵" + amount,
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    topMargin(10),
                    Text(
                      shortDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    )
                  ]),
            ),
          ),
        ));
  }

  redirectUserToPayStack(int price, String type) async {
    int amountToCharge = (price * 100);

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
      usersDetailsRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("subscriptionType")
          .set(type)
          .then((value) {
        showNormalToastBottom("Subscription Successful");
      });
    } else {
      /// UNSUCCESSFUL
      showErrorToastBottom("Payment is Unsuccessful, Please Try again!");
    }
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
