import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stormymart_adminpanel/Profile/Sales%20Revenue/monthly_sale.dart';
import 'package:stormymart_adminpanel/Profile/Sales%20Revenue/today_tab.dart';

class SaleRevenueTab extends StatefulWidget {
  const SaleRevenueTab({super.key});

  @override
  State<SaleRevenueTab> createState() => _SaleRevenueTabState();
}

class _SaleRevenueTabState extends State<SaleRevenueTab> {

  bool isLoading = false;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    //calculateTotalAmount();
    getTotalRevenue();
  }

  Future<void> getTotalRevenue() async {
    DocumentSnapshot totalSoldSnapshot = await FirebaseFirestore
        .instance
        .collection('/Admin Panel')
        .doc('Sell Data').get();
    setState(() {
      totalAmount = totalSoldSnapshot.get('totalSold').toDouble();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Sale Revenue',
            style: TextStyle(
                fontSize: 22,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.redAccent),
          bottom: const TabBar(
            //isScrollable: true,
            tabs: [
              Tab(text: 'All Time'),
              Tab(text: 'Today'),
              Tab(text: 'This Month'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First Tab - Pending Orders
            isLoading ? const Center(
              child: CircularProgressIndicator(),
            ) :
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

                    const Padding(
                      padding: EdgeInsets.only(top: 15,),
                      child: Text(
                        'Total Revenue (All Time) : ',
                        style: TextStyle(
                            fontSize: 26,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.clip
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.only(right: 30, top: 10),
                          child: Text(
                              '$totalAmount/-',
                            style: const TextStyle(
                                fontSize: 30,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                              color: Colors.red
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Second Tab - Processing Orders
            const TodayTab(),

            // Third Tab - Completed Orders
            const MonthlySale(),

          ],
        ),
      ),
    );
  }
}
