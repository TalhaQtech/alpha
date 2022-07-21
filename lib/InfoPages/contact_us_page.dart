import 'package:alfa/constants.dart';
import 'package:contactus/contactus.dart';
import 'package:flutter/material.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 119, 179, 121),
      appBar: AppBar(
        title: Text("Contact Us"),
        backgroundColor: primaryColorGreen,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 22),
        child: ContactUs(
       // logo: AssetImage('images/logo.png'),
        email: 'info@alfa.com',
        companyName: 'ALFA',
        phoneNumber: '+12345',
        dividerThickness: 2,
        website: 'https://alfa.com',
        //githubUserName: 'AbhishekDoshi26',
        linkedinURL: 'https://www.linkedin.com/in/alfa/',
        tagLine: 'Contact us anytime & anyday',
        twitterHandle: 'alfa123',
        instagram: 'alfa123',
        cardColor: Colors.white,
        companyColor: primaryColorGreen,
        taglineColor: primaryColorGreen,
        textColor: Colors.black,
        
      )),
    );
  }
}
