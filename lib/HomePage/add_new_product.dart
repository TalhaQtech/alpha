import 'dart:io';

import 'package:alfa/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../BlurryDialogs/post_blurry_dialog.dart';

class AddNewProduct extends StatefulWidget {
  const AddNewProduct({Key? key}) : super(key: key);

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  DatabaseReference usersDetailsRef =
      FirebaseDatabase().reference().child("Users_Details");

  TextEditingController itemNameTC = TextEditingController(),
      itemDescTC = TextEditingController(),
      priceTC = TextEditingController(),
      locationTC = TextEditingController();

  var categoryValue = "Select Category";

  bool loaderVisibility = false, addNewProductBtn = true;

  String itemImageUrl = "",
      fullNameFromFirebase = "",
      mobileNumberFromFirebase = "",
      userAvatarUrl = "",
      selectImageVideoTitle = "Select item image";

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

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
  void initState() {
    // TODO: implement initState
    fetchUsersDetails();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add A New Product"),
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: ListView(children: [
          TextFormField(
            controller: itemNameTC,
            decoration: InputDecoration(
                hintText: "Item Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(10),
          TextFormField(
            controller: itemDescTC,
            decoration: InputDecoration(
                hintText: "Item Description",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(10),
          TextFormField(
            controller: locationTC,
            decoration: InputDecoration(
                hintText: "Location",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(10),
          TextFormField(
            controller: priceTC,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: "Item Price",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          topMargin(10),
          DropdownButton<String>(
            value: categoryValue,
            alignment: Alignment.center,
            // icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: primaryColorGreen),
            underline: Container(
              height: 2,
              color: primaryColorGreen,
            ),
            onChanged: (String? newValue) {
              setState(() {
                categoryValue = newValue!;
              });
            },
            items: <String>[
              "Select Category",
              "Jobs",
              "Services",
              "Real Estate",
              "Vehicles",
              "Property",
              "Electronics",
              "Home Furniture",
              "Sport and Babies"
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          topMargin(10),
          TextButton(
              onPressed: () {
                showPostBlurryDialog(context);
              },
              child: Text(selectImageVideoTitle,
                  style: GoogleFonts.quicksand(
                    color: Colors.grey,
                  ))),
          topMargin(10),
          Stack(
            children: [
              Visibility(
                  visible: loaderVisibility,
                  // ignore: prefer_const_constructors
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    // ignore: prefer_const_constructors
                    child: Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              color: primaryColorGreen,
                            ))),
                  )),
              Visibility(
                  visible: addNewProductBtn,
                  child: Container(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text("Publish Item Now",
                            style: GoogleFonts.quicksand()),
                        onPressed: () {
                          if (itemNameTC.text.isEmpty ||
                              itemDescTC.text.isEmpty ||
                              priceTC.text.isEmpty ||
                              locationTC.text.isEmpty) {
                            showErrorToastBottom(
                                "One or more fields are emptyu");
                          } else if (categoryValue == "Select Category") {
                            showErrorToastBottom("Please select item category");
                          } else if (itemImageUrl == "") {
                            showErrorToastBottom(
                                "Please select item image/video");
                          } else {
                            setState(() {
                              addNewProductBtn = false;
                              loaderVisibility = true;
                            });

                            DatabaseReference postsRef =
                                FirebaseDatabase().reference().child("Posts");

                            String postId = postsRef.push().key;

                            postsRef.child(postId).set({
                              "postId": postId,
                              "itemName": itemNameTC.text,
                              "itemDesc": itemDescTC.text,
                              "itemImage": itemImageUrl,
                              "price": priceTC.text,
                              "location": locationTC.text,
                              "category": categoryValue,
                              "sellerId":
                                  FirebaseAuth.instance.currentUser!.uid,
                              "sellerName": fullNameFromFirebase,
                              "sellerImage": userAvatarUrl,
                              "sellerContactNo": mobileNumberFromFirebase,
                              "dislikesCount": 0
                            }).then((value) {
                              showNormalToastBottom("Successful");
                              setState(() {
                                addNewProductBtn = true;
                                loaderVisibility = false;
                              });
                            });
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(primaryColorGreen),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)))),
                      ))),
            ],
          )
        ]),
      ),
    );
  }

  showPostBlurryDialog(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    VoidCallback imageCallBack = () {
      Navigator.of(context).pop();
      // code on continue comes here

      performFirebaseStorageLogicForImagePost();
    };

    // ignore: prefer_function_declarations_over_variables
    VoidCallback videoCallBack = () {
      Navigator.of(context).pop();
      // code on continue comes here

    
      //   performFirebaseStorageLogicForVideoPost();
    };

    PostsBlurryDialog alert = PostsBlurryDialog(
        "Graphic Upload",
        "Please select your image cover",
        imageCallBack,
        videoCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void performFirebaseStorageLogicForVideoPost() async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    //Get the file from the image picker and store it
    final PickedFile? image =
        await ImagePicker().getVideo(source: ImageSource.gallery);

    //Create a reference to the location you want to upload to in firebase
    Reference reference = _storage.ref().child("videos/" + "$timeStamp" + "/");

    //Upload the file to firebase
    UploadTask uploadTask = reference.putFile(File(image!.path));

    showLoaderDialog(context);
    // setState(() {
    //   uploadingProgress = true;
    //   userAvatar = false;
    // });

    String videoUrl = await (await uploadTask).ref.getDownloadURL();
    String url = videoUrl.toString();

    String currentDateForPost = dateFormat.format(DateTime.now());

    setState(() {
      videoUrl = url;
      itemImageUrl = videoUrl;

      selectImageVideoTitle = "Successfully Uploaded!";
      Navigator.pop(context);
    });
  }

  void performFirebaseStorageLogicForImagePost() async {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    //Get the file from the image picker and store it
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    //Create a reference to the location you want to upload to in firebase
    Reference reference = _storage.ref().child("images/" + "$timeStamp" + "/");

    //Upload the file to firebase
    UploadTask uploadTask = reference.putFile(File(image!.path));

    showLoaderDialog(context);
    // setState(() {
    //   uploadingProgress = true;
    //   userAvatar = false;
    // });

    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    String url = imageUrl.toString();

    String currentDateForPost = dateFormat.format(DateTime.now());

    setState(() {
      imageUrl = url;
      itemImageUrl = imageUrl;
      selectImageVideoTitle = "Successfully Uploaded!";
      Navigator.pop(context);
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: primaryColorGreen,
          ),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Uploading... Please wait.")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
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
}
