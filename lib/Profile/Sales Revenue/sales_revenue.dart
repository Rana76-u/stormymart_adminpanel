import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesRevenue extends StatefulWidget {
  const SalesRevenue({super.key});

  @override
  State<SalesRevenue> createState() => _SalesRevenueState();
}

class _SalesRevenueState extends State<SalesRevenue> {

  bool isLoading = false;
  bool isSelectDate = false;

  bool dataLoading = false;

  String selectedTab = 'All Time';
  double totalAmount = 0.0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    //calculateTotalAmount();
    getTotalRevenue();
  }
  void updateTotalAmount() {
    setState(() {
      totalAmount;
      dataLoading = false;
    });
  }
  Future<void> getTotalRevenue() async {
    DocumentSnapshot totalSoldSnapshot = await FirebaseFirestore
        .instance
        .collection('/Admin Panel')
        .doc('Sell Data').get();
    setState(() {
      totalAmount = totalSoldSnapshot.get('totalSold').toDouble();
      dataLoading = false;
      isLoading = false;
    });
  }
  
  Future<void> calculateTotalAmount() async {
    try {
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('/Admin Panel')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (adminSnapshot.exists) {
        List<dynamic> completedOrdersReferences =
        adminSnapshot.get('Completed Orders');

        for (int index = 0; index < completedOrdersReferences.length; index++) {
          DocumentReference orderListReference = completedOrdersReferences[index];
          DocumentSnapshot orderListSnapshot =
          await orderListReference.get();

          totalAmount = totalAmount + orderListSnapshot.get('totalAmount');
        }
        setState(() {
          isLoading = false;
        });
      }
      else {
        print('Admin snapshot does not exist.');
      }
    } catch (error) {
      print('Error calculating total amount: $error');
    }
    setState(() {
      dataLoading = false;
    });
  }

  void calculateTotalAmountForDate(DateTime date) async {
    double totalAmountForDate = 0.0;

    DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('/Admin Panel')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    List<dynamic> completedOrdersReferences =
    adminSnapshot.get('Completed Orders');

    for (int index = 0; index < completedOrdersReferences.length; index++) {
      DocumentReference orderListReference =
      completedOrdersReferences[index];
      DocumentSnapshot orderListSnapshot =
          await orderListReference.get();

      if (orderListSnapshot.exists) {
        var orderListData =
        orderListSnapshot.data() as Map<String, dynamic>;

        double orderTotalAmount =
        double.parse(orderListData['totalAmount'].toString());

        String input = orderListData['time'];

        List<String> parts = input.split(' ');
        String datePart = parts[1]; // Get the date part (27/08/2023)

        List<String> dateComponents = datePart.split('/');

        int year = int.parse(dateComponents[2]);
        int month = int.parse(dateComponents[1]);
        int day = int.parse(dateComponents[0]);

        DateTime orderTime = DateTime(year, month, day);

        if (isSameDay(orderTime, date)) {
          totalAmountForDate += orderTotalAmount;
        }
      }
    }

    setState(() {
      totalAmount = totalAmountForDate;
      dataLoading = false;
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });

      setState(() {
        dataLoading = true;
      });
      selectedTab = DateFormat('EE, dd/MM/yyyy').format(selectedDate);

      //calculateTotalAmountForDate(selectedDate);
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) :
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.05,),
            //Sales Revenue
            const Text(
              'Sales Revenue',
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //All Time
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelectDate = false;
                      selectedTab = 'All Time';
                      dataLoading = true;
                      //calculateTotalAmount();
                      getTotalRevenue();
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    elevation: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'All Time',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),

                //Today
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelectDate = false;
                      selectedTab = 'Today';
                      dataLoading = true;
                      //calculateTotalAmountForDate(DateTime.now());
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    elevation: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Today',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),

                //Selected Day
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelectDate = true;
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    elevation: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Select Date',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Date Picker
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
              child: isSelectDate ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    const Text(
                      'Selected Date: ',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        color: Colors.grey.shade400,
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            '${selectedDate.toLocal()}'.split(' ')[0],
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
            ),

            //Total
            dataLoading ? const LinearProgressIndicator()
                :
            Padding(
              padding: const EdgeInsets.only(top: 15,),
                child: Text(
                'Total Revenue ($selectedTab) : $totalAmount',
                style: const TextStyle(
                    fontSize: 26,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  overflow: TextOverflow.clip
                ),
              ),
            ),

            if(selectedTab == 'Today')...[
              buildDateSpecificData(context, DateTime.now()),
            ]
            else if(selectedTab != 'All Time' || selectedTab != 'Today')...[
              buildDateSpecificData(context, selectedDate),
            ]
            else if(selectedTab == 'All Time')...[
              const SizedBox()
            ]
          ],
        ),
      ),
    );
  }

  Widget buildDateSpecificData(BuildContext context, DateTime dateTime) {
    return FutureBuilder(
      future: FirebaseFirestore
          .instance
          .collection('/Orders')
          .get(),
      builder: (context, ordersSnapshot) {
        if(ordersSnapshot.hasData){
          return ListView.builder(
            primary: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ordersSnapshot.data!.docs.length,
            itemBuilder: (context, orderUidIndex) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.5)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //User Info's
                    FutureBuilder(
                      future: FirebaseFirestore
                          .instance
                          .collection('/userData')
                          .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                          .get(),
                      builder: (context, userSnapshot) {
                        if(userSnapshot.hasData){
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Name
                                SelectableText(
                                  userSnapshot.data!.get('name'),
                                  style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17
                                  ),
                                ),
                                //Email
                                SelectableText(
                                  userSnapshot.data!.get('Email'),
                                  style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                                //Phone Number
                                SelectableText(
                                  userSnapshot.data!.get('Phone Number'),
                                  style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                                //Address1
                                SelectableText(
                                  'Address1: ${userSnapshot.data!.get('Address1')[0]}, ${userSnapshot.data!.get('Address1')[1]}',
                                  style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                                //Address2
                                SelectableText(
                                  'Address2: ${userSnapshot.data!.get('Address2')[0]}, ${userSnapshot.data!.get('Address2')[1]}',
                                  style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        else{
                          return const Text('Error Loading Data');
                        }
                      },
                    ),

                    //user's orders
                    FutureBuilder(
                      future: FirebaseFirestore
                          .instance
                          .collection('/Orders/${ordersSnapshot.data!.docs[orderUidIndex].id}/Completed Orders')
                          .get(),
                      builder: (context, pendingOrderSnapshot) {
                        if(pendingOrderSnapshot.hasData){
                          return ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingOrderSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.5),
                                    side: const BorderSide(
                                        width: 1,
                                        color: Colors.grey
                                    )
                                ),
                                child: FutureBuilder(
                                  future: FirebaseFirestore
                                      .instance
                                      .collection('/Orders/${ordersSnapshot.data!.docs[orderUidIndex].id}/Completed Orders')
                                      .doc(pendingOrderSnapshot.data!.docs[index].id)
                                      .collection('/orderLists')
                                      .get(),
                                  builder: (context, orderListSnapshot) {
                                    if(orderListSnapshot.hasData){
                                      if(DateFormat('EE, dd/MM').format(pendingOrderSnapshot.data!.docs[index].get('time').toDate())
                                          == DateFormat('EE, dd/MM').format(dateTime)){

                                            totalAmount = 0;
                                            totalAmount = totalAmount + pendingOrderSnapshot.data!.docs[index].get('total');

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            //Order items
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                //order info
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.55 - 20,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      //Order Items
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 10, left: 15),
                                                        child: Text(
                                                          "Order Items (${orderListSnapshot.data!.docs.length})",
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'Urbanist'
                                                          ),
                                                        ),
                                                      ),
                                                      //sku
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 0, left: 15),
                                                        child: SelectableText(
                                                          "sku: ${pendingOrderSnapshot.data!.docs[index].id}",
                                                          style: const TextStyle(
                                                              fontSize: 12.5,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'Urbanist',
                                                              color: Colors.grey
                                                          ),
                                                        ),
                                                      ),
                                                      //Time
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 0, left: 15),
                                                        child: Text(
                                                          "Placed on : "
                                                              "${
                                                              DateFormat('EE, dd/MM H:mm')
                                                                  .format(
                                                                  pendingOrderSnapshot
                                                                      .data!
                                                                      .docs[index]
                                                                      .get('time')
                                                                      .toDate()
                                                              )
                                                          }",
                                                          style: const TextStyle(
                                                              fontSize: 12.5,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'Urbanist',
                                                              color: Colors.grey
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            //Total
                                            const Divider(),
                                            Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Total Payable Amount : ',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Urbanist'
                                                    ),
                                                  ),

                                                  Text(
                                                    '${pendingOrderSnapshot.data!.docs[index].get('total')}',
                                                    style: const TextStyle(
                                                      //color: Colors.orange,
                                                      fontWeight: FontWeight.w800,
                                                      //fontFamily: 'Urbanist'
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                      else{
                                        return const SizedBox();
                                      }
                                    }
                                    else if(orderListSnapshot.connectionState == ConnectionState.waiting){
                                      return Center(
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width*0.4,
                                          child: const LinearProgressIndicator(),
                                        ),
                                      );
                                    }
                                    else {
                                      return const Center(
                                        child: Text(
                                          'Error Loading Data',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        }
                        else if(pendingOrderSnapshot.connectionState == ConnectionState.waiting){
                          return Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width*0.4,
                              child: const LinearProgressIndicator(),
                            ),
                          );
                        }
                        else {
                          return const Center(
                            child: Text(
                              'Error Loading Data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              );
            },
          );
        }
        else if(ordersSnapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.4,
              child: const LinearProgressIndicator(),
            ),
          );
        }
        else {
          return const Center(
            child: Text(
              'Error Loading Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }
      },
    );
  }
}
