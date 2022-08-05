// ignore_for_file: prefer_const_constructors

import 'package:alfa/Authentication/login_page.dart';
import 'package:alfa/Authentication/registration_page.dart';
import 'package:alfa/Profile/profile_page.dart';
import 'package:alfa/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'HomePage/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
  }) : super(key: key);

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: user != null ? HomePage() : WelcomePage(),
    );
  }
}
