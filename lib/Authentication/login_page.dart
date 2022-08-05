// ignore_for_file: prefer_const_constructors, prefer_function_declarations_over_variables

import 'package:alfa/HomePage/home_page.dart';
import 'package:alfa/Profile/profile_page.dart';
import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../BlurryDialogs/blurry_dialog.dart';
import '../BlurryDialogs/single_button_blurry_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController emailAddessTC = TextEditingController(),
      passwordTC = TextEditingController();

  bool termsAndConditionValue = false,
      loginBtnVisibility = true,
      loaderVisibility = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: GoogleFonts.quicksand(),
        ),
        centerTitle: true,
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset("images/logo.png"),
            topMargin(10),
            TextFormField(
              cursorColor: primaryColorGreen,
              controller: emailAddessTC,
              decoration: InputDecoration(
                  hintText: "Email Address",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColorGreen))),
            ),
            topMargin(10),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  if (emailAddessTC.text.isEmpty) {
                    showErrorToastBottom(
                        "Enter your email address to continue");
                  } else {
                    showBlurryDialog(context);
                  }
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            topMargin(10),
            Stack(
              children: [
                Visibility(
                    visible: loaderVisibility,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: primaryColorGreen,
                      ),
                    )),
                Visibility(
                    visible: loginBtnVisibility,
                    child: Container(
                        height: 45,
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text("Login", style: GoogleFonts.quicksand()),
                          onPressed: () async {
                            if (emailAddessTC.text.isEmpty ||
                                passwordTC.text.isEmpty) {
                              showErrorToastBottom(
                                  "One or more fields are empty");
                            } else if (passwordTC.text.length < 6) {
                              showErrorToastBottom("Password is too short");
                            } else {
                              setState(() {
                                loginBtnVisibility = false;
                                loaderVisibility = true;
                              });

                              // Register new user here
                              EasyLoading.show();
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: emailAddessTC.text.trim(),
                                      password: passwordTC.text.trim())
                                  .catchError((error) {
                                showNormalToastBottom(error.toString());

                                setState(() {
                                  loginBtnVisibility = true;
                                  loaderVisibility = false;
                                });
                              }).then((value) async {
                                try {
                                  if (FirebaseAuth
                                      .instance.currentUser!.emailVerified) {
                                    // Go to Home Page

                                    await goToNewPage(HomePage());
                                    showNormalToastBottom(
                                        "Successfully Loged In");
                                    EasyLoading.dismiss();

                                    setState(() {
                                      loginBtnVisibility = true;
                                      loaderVisibility = false;
                                    });
                                  } else {
                                    /// TEMPORARY >>> REMOVE!!!
                                    //  goToNewPage(HomePage());
                                    setState(() {
                                      loginBtnVisibility = true;
                                      loaderVisibility = false;
                                    });

                                    showNormalToastBottom(
                                        "Your email is not verified. Check your mail box to verify");
                                  }
                                } catch (error) {
                                  if (error.toString() ==
                                      'ERROR_WRONG_PASSWORD') {
                                    showErrorToastBottom(
                                        "Incorrect email and password combinations");
                                  }
                                }
                              });
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(primaryColorGreen),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)))),
                        ))),
              ],
            )
          ]),
        ),
      ),
    );
  }

  showBlurryDialog(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback continueCallBack = () => {
          // code on continue comes here

          FirebaseAuth.instance
              .sendPasswordResetEmail(email: emailAddessTC.text)
              .whenComplete(() {
            Navigator.of(context).pop();
            showSingleBtnBlurryDialog(context);
          })
        };

    String emailAddress = emailAddessTC.text;
    BlurryDialog alert = BlurryDialog(
        "Recover Password",
        "Email: $emailAddress\nWe'll send you a recovery email shortly. Proceed?",
        continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showSingleBtnBlurryDialog(BuildContext context) {
    VoidCallback continueCallBack = () => {
          Navigator.of(context).pop(),
          // code on continue comes here
        };
    SingleBtnBlurryDialog alert = SingleBtnBlurryDialog(
        "Sent",
        "Please check your email. We just sent you a password recovery link.",
        continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => widget));
  }
}
