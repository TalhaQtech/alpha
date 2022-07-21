import 'package:alfa/Orders/buying_page.dart';
import 'package:alfa/Orders/selling_page.dart';
import 'package:alfa/constants.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin{

 late TabController tabController;

 @override
  void initState() {
   
   tabController = TabController(length: 2, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        backgroundColor: primaryColorGreen,
        bottom: TabBar(
           indicator: BoxDecoration(),
          controller: tabController,
          labelColor: Colors.white,
       
          // ignore: prefer_const_literals_to_create_immutables
          tabs: [
          // ignore: prefer_const_constructors
          Tab(
            text: "Buying",
          ),
          // ignore: prefer_const_constructors
          Tab(
            text: "Selling",
          )
        ]),
      ),

      body: SafeArea(child: TabBarView(controller: tabController,
      
      children: [

        BuyingPage(),
        SellingPage()

      ],
      ))
    );
  }
}
