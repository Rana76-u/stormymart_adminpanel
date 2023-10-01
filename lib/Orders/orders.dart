import 'package:flutter/material.dart';
import 'package:stormymart_adminpanel/Orders/completed_orders.dart';
import 'package:stormymart_adminpanel/Orders/pending_order.dart';
import 'package:stormymart_adminpanel/Orders/processing_orders.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'All Orders',
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold
              ),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Processing'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // First Tab - Pending Orders
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      /*Row(
                        children: [
                          //Arrow
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 3),)
                              );
                            },
                            child: const Icon(
                                Icons.arrow_back_rounded
                            ),
                          ),

                          const Expanded(child: SizedBox()),
                          const Text(
                            'My Orders',
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 5,),

                      //Pending Order
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 15),
                        child: Text(
                          "• Pending Order",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist'
                          ),
                        ),
                      ),*/

                      //PendingOrders,
                      const PendingOrders(),

                      const SizedBox(height: 200,),
                    ],
                  ),
                ),
              ),

              // Second Tab - Processing Orders
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      /*Row(
                        children: [
                          //Arrow
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 3),)
                              );
                            },
                            child: const Icon(
                                Icons.arrow_back_rounded
                            ),
                          ),

                          const Expanded(child: SizedBox()),
                          const Text(
                            'My Orders',
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 5,),

                      //Pending Order
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 15),
                        child: Text(
                          "• Pending Order",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist'
                          ),
                        ),
                      ),*/

                      //PendingOrders,
                      const ProcessingOrders(),

                      const SizedBox(height: 200,),
                    ],
                  ),
                ),
              ),

              // Third Tab - Completed Orders
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      /*Row(
                        children: [
                          //Arrow
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 3),)
                              );
                            },
                            child: const Icon(
                                Icons.arrow_back_rounded
                            ),
                          ),

                          const Expanded(child: SizedBox()),
                          const Text(
                            'My Orders',
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 5,),

                      //Pending Order
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 15),
                        child: Text(
                          "• Pending Order",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist'
                          ),
                        ),
                      ),*/

                      //PendingOrders,
                      const CompletedOrders(),

                      const SizedBox(height: 200,),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
