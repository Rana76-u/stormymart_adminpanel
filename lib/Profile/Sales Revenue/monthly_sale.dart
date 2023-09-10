import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlySale extends StatefulWidget {
  const MonthlySale({super.key});

  @override
  State<MonthlySale> createState() => _MonthlySaleState();
}

class _MonthlySaleState extends State<MonthlySale> {

  bool isLoading = false;
  double totalAmount = 0.0;

  List<dynamic> totals = [];
  List<dynamic> times = [];
  List<dynamic> skus = [];

  @override
  void initState() {
    super.initState();
    isLoading = true;
    //calculateTotalAmount();
    getMonthlySales();
  }


  Future<void> getMonthlySales() async {
    var now = DateTime.now();
    var startOfMonth = DateTime(now.year, now.month, 1);
    var endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

    var ordersSnapshot = await FirebaseFirestore.instance.collection('/Orders').get();

    for (int orderUidIndex = 0; orderUidIndex < ordersSnapshot.docs.length; orderUidIndex++) {
      var completedOrderSnapshot = await FirebaseFirestore
          .instance
          .collection('/Orders/${ordersSnapshot.docs[orderUidIndex].id}/Completed Orders')
          .where('time', isGreaterThanOrEqualTo: startOfMonth)
          .where('time', isLessThanOrEqualTo: endOfMonth)
          .get();

      for (int index = 0; index < completedOrderSnapshot.docs.length; index++) {
        totals.add(completedOrderSnapshot.docs[index].get('total'));
        times.add(completedOrderSnapshot.docs[index].get('time'));
        skus.add(completedOrderSnapshot.docs[index].id);
        totalAmount = totalAmount + totals[index];
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

            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, bottom: 15),
              child: Text(
                'Total Revenue (${DateFormat('MMM').format(DateTime.now())}) : $totalAmount',
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
