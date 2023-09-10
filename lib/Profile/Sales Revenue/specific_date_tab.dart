import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpecificDateTab extends StatefulWidget {
  const SpecificDateTab({super.key});

  @override
  State<SpecificDateTab> createState() => _SpecificDateTabState();
}

class _SpecificDateTabState extends State<SpecificDateTab> {

  DateTime selectedDate = DateTime.now();

  bool isLoading = false;
  double totalAmount = 0.0;

  List<dynamic> totals = [];
  List<dynamic> times = [];
  List<dynamic> skus = [];

  @override
  void initState() {
    getDateSpecificData();
    super.initState();
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
        getDateSpecificData();
      });
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> getDateSpecificData() async {
    totals.clear();
    times.clear();
    skus.clear();
    totalAmount = 0.0;

    var ordersSnapshot = await FirebaseFirestore
        .instance
        .collection('/Orders').get();

    for(int orderUidIndex=0; orderUidIndex<ordersSnapshot.docs.length; orderUidIndex++){
      var completedOrderSnapshot = await FirebaseFirestore
          .instance
          .collection('/Orders/${ordersSnapshot.docs[orderUidIndex].id}/Completed Orders')
          .get();

      for(int index=0; index<completedOrderSnapshot.docs.length; index++){
        if(
        DateFormat('EE, dd/MM').format(completedOrderSnapshot.docs[index].get('time').toDate())
            == DateFormat('EE, dd/MM').format(selectedDate)
        ){
          totals.add(completedOrderSnapshot.docs[index].get('total'));
          times.add(completedOrderSnapshot.docs[index].get('time'));
          skus.add(completedOrderSnapshot.docs[index].id);
          totalAmount = totalAmount + totals[index];
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.02,),

            // Date Picker
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Padding(
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
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, bottom: 15),
              child: Text(
                'Total Revenue (${DateFormat('EE, dd/MM').format(selectedDate)}) : $totalAmount',
                style: const TextStyle(
                    fontSize: 26,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.clip
                ),
              ),
            ),

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
            ),

            const SizedBox(height: 200,),
          ],
        ),
      ),
    );
  }
}
