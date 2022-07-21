// ignore_for_file: prefer_const_constructors, prefer_function_declarations_over_variables

import 'dart:io';

import 'package:alfa/Authentication/login_page.dart';
import 'package:alfa/constants.dart';
import 'package:alfa/welcome_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../BlurryDialogs/blurry_dialog.dart';
import '../BlurryDialogs/single_button_blurry_dialog.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  DatabaseReference usersDetailsRef =
      FirebaseDatabase().reference().child("Users_Details");

  bool userAvatarVisibility = true,
      uploadingProgress = false,
      profilePicAvailable = false,
      updateAccountBtnVisibility = true,
      loadingProgress = false;

  String fullNameFromFirebase = "",
      mobileNumberFromFirebase = "",
      userAvatarUrl = "";

  TextEditingController
      // fullNameTC = TextEditingController(),
      //     mobileNumberTC = TextEditingController(),
      newPasswordTC = TextEditingController(),
      confirmNewPasswordTC = TextEditingController();

  @override
  void initState() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    usersDetailsRef.keepSynced(true);

    fetchUsersDetails();
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.gruppo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColorGreen,
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: ListView(children: [
          
          GestureDetector(
              onTap: () {
                _checkInternetConnectivityForAvatar();
              },
              child: Center(
                  child: Column(
                children: [
                  Visibility(
                    visible: uploadingProgress,
                    child: const SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        color: primaryColorGreen,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: userAvatarVisibility,
                    child: userAvatarUrl != ""
                        ? CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 148, 234, 176),
                            radius: 80,
                            backgroundImage: NetworkImage(userAvatarUrl),
                          )
                        : Image.asset(
                            "images/default_avatar.png",
                            width: 100,
                            height: 100,
                          ),
                  ),
                  topMargin(4),
                  Text("Click on the image above to update your profile pic")
                ],
              ))),
          topMargin(15),
          TextFormField(
            // controller: fullNameTC,
            initialValue: fullNameFromFirebase,
            onChanged: (Value) {
              setState(() {
                fullNameFromFirebase = Value;
              });
            },
            decoration: InputDecoration(
                hintText: "Full Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(8),
          TextFormField(
            keyboardType: TextInputType.number,
            // controller: mobileNumberTC,
            initialValue: mobileNumberFromFirebase,
            onChanged: (value) {
              setState(() {
                mobileNumberFromFirebase = value;
              });
            },
            decoration: InputDecoration(
                hintText: mobileNumberFromFirebase != ""
                    ? mobileNumberFromFirebase
                    : "Mobile Number",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(8),
          TextFormField(
            obscureText: true,
            controller: newPasswordTC,
            decoration: InputDecoration(
                hintText: "New Password (Optional)",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(8),
          TextFormField(
            obscureText: true,
            controller: confirmNewPasswordTC,
            decoration: InputDecoration(
                hintText: "Confirm Password (Optional)",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(8),
          Visibility(
              visible: loadingProgress,
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(color: primaryColorGreen),
                ),
              )),
          Visibility(
              visible: updateAccountBtnVisibility,
              child: Container(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (fullNameFromFirebase == "" ||
                          mobileNumberFromFirebase == "") {
                        showErrorToastBottom("One or more fields are empty");
                      } else {
                        if (!newPasswordTC.text.isEmpty &&
                            !!confirmNewPasswordTC.text.isEmpty) {
                          if (newPasswordTC.text.length < 6 &&
                              confirmNewPasswordTC.text.length < 6) {
                            showErrorToastBottom("Password is too short");
                          } else if (confirmNewPasswordTC.text !=
                              newPasswordTC.text) {
                            /// Password doesnt mathc

                            showErrorToastBottom("Passwords do not match");
                          } else {
                            setState(() {
                              updateAccountBtnVisibility = false;
                              loadingProgress = true;
                            });

                            /// Save for new password

                            usersDetailsRef
                                .child(FirebaseAuth.instance.currentUser!.uid)
                                .set({
                              "userId": FirebaseAuth.instance.currentUser!.uid,
                              "fullName": fullNameFromFirebase,
                              "mobileNumber": mobileNumberFromFirebase,
                              "avatar": userAvatarUrl
                            });

                            // Update password

                            FirebaseAuth.instance.currentUser!
                                .updatePassword(newPasswordTC.text)
                                .then((value) {
                              setState(() {
                                updateAccountBtnVisibility = true;
                                loadingProgress = false;
                              });

                              showNormalToastBottom(
                                  "Account information successfully updated");
                            });
                          }
                        } else {
                          setState(() {
                            updateAccountBtnVisibility = false;
                            loadingProgress = true;
                          });

                          /// Save without new password

                          usersDetailsRef
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .set({
                            "userId": FirebaseAuth.instance.currentUser!.uid,
                            "fullName": fullNameFromFirebase,
                            "mobileNumber": mobileNumberFromFirebase,
                            "avatar": userAvatarUrl
                          }).then((value) {
                            setState(() {
                              updateAccountBtnVisibility = true;
                              loadingProgress = false;
                            });

                            showNormalToastBottom(
                                "Account information successfully updated");
                          });
                        }
                      }
                    },
                    child: Text("Update Account Infomation",
                        style: GoogleFonts.quicksand()),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(primaryColorGreen),
                        side: MaterialStateProperty.all(
                            BorderSide(color: Colors.transparent)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        )),
                  ))),
          topMargin(8),
          Container(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showBlurryDialog(context);
                },
                child: Text("Delete My Account Forever",
                    style: GoogleFonts.quicksand()),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(primaryColorRed),
                    side: MaterialStateProperty.all(
                        BorderSide(color: Colors.transparent)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    )),
              ))
        ]),
      ),
    );
  }

  void _checkInternetConnectivityForAvatar() async {
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      noInternetConnectionDialog(context);
    } else {
      performFirebaseStorageLogicForAvatar();
    }
  }

  void performFirebaseStorageLogicForAvatar() async {
    //  User? user = FirebaseAuth.instance.currentUser;

    // String? currentUserEmail = user!.email;

    FirebaseStorage _storage = FirebaseStorage.instance;

    //Get the file from the image picker and store it
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    //Create a reference to the location you want to upload to in firebase
    Reference reference = _storage
        .ref()
        .child("users_avatars/" + FirebaseAuth.instance.currentUser!.uid + "/");

    //Upload the file to firebase
    UploadTask uploadTask = reference.putFile(File(image!.path));

    setState(() {
      uploadingProgress = true;
      userAvatarVisibility = false;
    });

    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    String url = imageUrl.toString();

    setState(() {
      userAvatarUrl = url;

      usersDetailsRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("avatar")
          .set(userAvatarUrl)
          .whenComplete(() => {});

      uploadingProgress = false;
      userAvatarVisibility = true;
      profilePicAvailable = true;
    });
  }

  noInternetConnectionDialog(BuildContext context) {
    VoidCallback continueCallBack = () => {
          Navigator.of(context).pop(),
          // code on continue comes here
        };
    SingleBtnBlurryDialog alert = SingleBtnBlurryDialog(
        "No Internet Connection",
        "Oops! It seems you're not connected to the internet. Please kindly check your internet connection and try again.",
        continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showBlurryDialog(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback continueCallBack = () {
      // code on continue comes here

      usersDetailsRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .remove()
          .then(((value) {
        FirebaseAuth.instance.currentUser!.delete().then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => WelcomePage()));

          showNormalToastBottom(
              "Your account with ALFA has been permanently delted");
        });
      }));
    };

    BlurryDialog alert = BlurryDialog(
        "DELETE MY ACCOUNT PERMANENTYLY (FOREVER)",
        "Are you sure you want to permanently delete your account forever?\n\nWarning: You cannot undo this action",
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
}
