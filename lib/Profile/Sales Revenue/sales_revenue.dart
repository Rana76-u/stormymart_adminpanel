import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String selectedTab = 'All Time';
  double totalAmount = 0.0;
  double allTimeTotalAmount = 0.0;
  DateTime selectedDate = DateTime.now();

  List<dynamic> totals = [];
  List<dynamic> times = [];
  List<dynamic> skus = [];

  @override
  void initState() {
    super.initState();
    isLoading = true;
    //calculateTotalAmount();
    getTotalRevenue();
    getDateSpecificData();
  }

  Future<void> getTotalRevenue() async {
    DocumentSnapshot totalSoldSnapshot = await FirebaseFirestore
        .instance
        .collection('/Admin Panel')
        .doc('Sell Data').get();
    setState(() {
      allTimeTotalAmount = totalSoldSnapshot.get('totalSold').toDouble();
      totalAmount = allTimeTotalAmount;
      isLoading = false;
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
      selectedTab = DateFormat('EE, dd/MM/yyyy').format(selectedDate);

      //calculateTotalAmountForDate(selectedDate);
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> getDateSpecificData() async {
    var ordersSnapshot = await FirebaseFirestore
        .instance
        .collection('/Orders').get();

    for(int orderUidIndex=0; orderUidIndex<ordersSnapshot.docs.length; orderUidIndex++){
      var completedOrderSnapshot = await FirebaseFirestore
          .instance
          .collection('/Orders/${ordersSnapshot.docs[orderUidIndex].id}/Completed Orders')
          .get();
      for(int index=0; index<completedOrderSnapshot.docs.length; index++){
        totals.add(completedOrderSnapshot.docs[index].get('total'));
        times.add(completedOrderSnapshot.docs[index].get('time'));
        skus.add(completedOrderSnapshot.docs[index].id);
      }
    }
    setState(() {
      isLoading = false;
    });
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
            //Space
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

            //space
            const SizedBox(height: 20,),

            //Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //All Time
                GestureDetector(
                  onTap: () {
                    setState(() {
                      totalAmount = allTimeTotalAmount;
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
                      selectedDate = DateTime.now();
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
            /*dataLoading ? const LinearProgressIndicator()
                :*/
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

            selectedTab == 'All Time' ?
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.5)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totals.length,
                    itemBuilder: (context, index) {
                        totalAmount = 0;
                        totalAmount = totalAmount + totals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.5),
                              side: const BorderSide(
                                  width: 1,
                                  color: Colors.grey
                              )
                          ),
                          child: Column(
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
                                        //sku
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10, left: 15),
                                          child: SelectableText(
                                            "sku: ${skus[index]}",
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
                                                    .format(times[index].toDate()
                                                )
                                            }",
                                            style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Urbanist',
                                                color: Colors.grey
                                            ),
                                          ),
                                        ),
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
                                      'Total Amount : ',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Urbanist'
                                      ),
                                    ),

                                    Text(
                                      '${totals[index]}',
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
                          ),
                        );
                    },
                  ),
                ],
              ),
            )
                :
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.5)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totals.length,
                    itemBuilder: (context, index) {
                      if(DateFormat('EE, dd/MM').format(times[index].toDate())
                          == DateFormat('EE, dd/MM').format(selectedDate)){
                        totalAmount = 0;
                        totalAmount = totalAmount + totals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.5),
                              side: const BorderSide(
                                  width: 1,
                                  color: Colors.grey
                              )
                          ),
                          child: Column(
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
                                        //sku
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10, left: 15),
                                          child: SelectableText(
                                            "sku: ${skus[index]}",
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
                                                    .format(times[index].toDate()
                                                )
                                            }",
                                            style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Urbanist',
                                                color: Colors.grey
                                            ),
                                          ),
                                        ),
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
                                      'Total Amount : ',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Urbanist'
                                      ),
                                    ),

                                    Text(
                                      '${totals[index]}',
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
                          ),
                        );
                      }
                      else{
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
