// ignore_for_file: prefer_const_constructors

import 'package:alfa/Authentication/login_page.dart';
import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  DatabaseReference usersDetailsRef =
      FirebaseDatabase().reference().child("Users_Details");

  TextEditingController fullNameTC = TextEditingController(),
      emailAddessTC = TextEditingController(),
      passwordTC = TextEditingController();

  bool termsAndConditionValue = false,
      regBtnLoadingVisible = true,
      loaderVisible = false;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  late String currentDateForPost;

  @override
  void initState() {
    // TODO: implement initState
    currentDateForPost = dateFormat.format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration", style: GoogleFonts.quicksand()),
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: Column(children: [
          TextFormField(
            cursorColor: primaryColorGreen,
            controller: fullNameTC,
            decoration: InputDecoration(
                hintText: "Full Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColorGreen))),
          ),
          topMargin(10),
          TextFormField(
            cursorColor: primaryColorGreen,
            controller: emailAddessTC,
            decoration: InputDecoration(
                hintText: "Email Address",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColorGreen))),
          ),
          topMargin(10),
          TextFormField(
            cursorColor: primaryColorGreen,
            controller: passwordTC,
            obscureText: true,
            decoration: InputDecoration(
                hintText: "Password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColorGreen))),
          ),
          topMargin(10),
          Row(
            children: [
              Checkbox(
                  activeColor: primaryColorGreen,
                  value: termsAndConditionValue,
                  onChanged: (value) {
                    setState(() {
                      termsAndConditionValue = value!;
                    });
                  }),
              Text("I agree to the terms and conditions",
                  style: GoogleFonts.quicksand())
            ],
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Stack(
                    children: [
                      Visibility(
                          visible: loaderVisible,
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              color: primaryColorGreen,
                            ),
                          )),
                      Visibility(
                        visible: regBtnLoadingVisible,
                        child: Container(
                            height: 45,
                            width: 150,
                            child: ElevatedButton(
                              child: Text("Register",
                                  style: GoogleFonts.quicksand()),
                              onPressed: () {
                                if (fullNameTC.text.isEmpty ||
                                    emailAddessTC.text.isEmpty ||
                                    passwordTC.text.isEmpty) {
                                  showErrorToastBottom(
                                      "One or more fields are empty");
                                } else if (passwordTC.text.length < 6) {
                                  showErrorToastBottom("Password is too short");
                                } else if (termsAndConditionValue == false) {
                                  showErrorToastBottom(
                                      "Accept the terms and conditions before you proceed");
                                } else {
                                  // Register new user here

                                  setState(() {
                                    regBtnLoadingVisible = false;
                                    loaderVisible = true;
                                  });

                                  FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: emailAddessTC.text,
                                          password: passwordTC.text)
                                      .then((value) async {
                                    await OneSignal.shared
                                        .setAppId(oneSignalAppID);
                                    var status =
                                        await OneSignal.shared.getDeviceState();
                                    String? tokenId = status?.userId;

                                    // Store new user details to database
                                    usersDetailsRef
                                        .child(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .set({
                                      "fullName": fullNameTC.text,
                                      "tokenId": tokenId,
                                      "status": "offline",
                                      "subscriptionType" : "FREE",
                                      "lastSeenTimeStamp":
                                          currentDateForPost + "Z"
                                    }).then((value) {
                                      // Send verification email
                                      FirebaseAuth.instance.currentUser!
                                          .sendEmailVerification()
                                          .then((value) {
                                        goToNewPage(LoginPage());
                                        showNormalToastBottom(
                                            "Verification Sent to your email at: ${emailAddessTC.text}");
                                      });

                                      setState(() {
                                        loaderVisible = false;
                                        regBtnLoadingVisible = true;
                                      });
                                    });
                                  });
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      primaryColorGreen),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)))),
                            )),
                      )
                    ],
                  )))
        ]),
      ),
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
