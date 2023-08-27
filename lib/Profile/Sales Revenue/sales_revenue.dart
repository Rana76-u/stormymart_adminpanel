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
    calculateTotalAmount();
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

      calculateTotalAmountForDate(selectedDate);
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
                      calculateTotalAmount();
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
                      calculateTotalAmountForDate(DateTime.now());
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
                : Padding(
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
          ],
        ),
      ),
    );
  }
}
