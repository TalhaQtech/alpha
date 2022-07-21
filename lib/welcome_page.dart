import 'package:alfa/Authentication/login_page.dart';
import 'package:alfa/Authentication/registration_page.dart';
import 'package:alfa/constants.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/logo.png",
              // width: 200,
              // height: 200,
            ),
            topMargin(20),

           Container(

             width: double.infinity,
             height: 45,

             child:  ElevatedButton(onPressed: (){

               Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
             }, child: Text("Login"),
             
             style: ButtonStyle(

               backgroundColor:MaterialStateProperty.all(primaryColorGreen),

               shape: MaterialStateProperty.all(
                 RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(9)
                 )
               )
             ),
             ),
           ),

           topMargin(10),

           Container(

             width: double.infinity,
             height: 45,

             child:  ElevatedButton(onPressed: (){

               Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
             }, child: Text("New Account Registration"),
             
             style: ButtonStyle(

               backgroundColor:MaterialStateProperty.all(primaryColorRed),

               shape: MaterialStateProperty.all(
                 RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(9)
                 )
               )
             ),
             ),
           )
          ],
        ),
      ),
    );
  }

  Widget topMargin(double margin) {
    return Container(
      margin: EdgeInsets.only(top: margin),
    );
  }
}
