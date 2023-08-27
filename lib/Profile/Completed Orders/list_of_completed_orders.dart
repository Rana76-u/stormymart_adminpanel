import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListOfCompletedOrders extends StatefulWidget {
  const ListOfCompletedOrders({super.key});

  @override
  State<ListOfCompletedOrders> createState() => _ListOfCompletedOrdersState();
}

class _ListOfCompletedOrdersState extends State<ListOfCompletedOrders> {
  bool isLoading = false;

  double allTotalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(
      child: CircularProgressIndicator(),
    )
        :
    FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('/Admin Panel')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, adminSnapshot) {
        if(adminSnapshot.hasData){

          List<dynamic> completedOrdersReferences = adminSnapshot.data!.get('Completed Orders');
          String uid = '';

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedOrdersReferences.length,
            itemBuilder: (context, index) {

              //Finds the uid
              String inputString = completedOrdersReferences[index].toString();
              int startIndex = inputString.indexOf('Orders/') + 'Orders/'.length;
              int endIndex = inputString.indexOf('/Complete');
              uid = inputString.substring(startIndex, endIndex);

              DocumentReference orderListReference = completedOrdersReferences[index];
              return FutureBuilder<DocumentSnapshot>(
                future: orderListReference.get(),
                builder: (context, orderListSnapshot) {
                  if (!orderListSnapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var orderListData = orderListSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 3, right: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Order
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('/Products')
                                .doc(orderListData['productId'])
                                .get(),
                            builder: (context, titleSnapshot) {
                              if(titleSnapshot.hasData){
                                return Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //title
                                      Text(
                                        titleSnapshot.data!.get('title'),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.clip
                                        ),
                                      ),
                                      //size
                                      Text(
                                        'Size: ${orderListData['selectedSize']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey,
                                            overflow: TextOverflow.clip
                                        ),
                                      ),
                                      //variant
                                      Text(
                                        'Variant: ${orderListData['variant']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey,
                                            overflow: TextOverflow.clip
                                        ),
                                      ),
                                      //quantity
                                      Text(
                                        'Quantity: ${orderListData['quantity']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey,
                                            overflow: TextOverflow.clip
                                        ),
                                      ),
                                      //totalAmount
                                      Text(
                                        'Total Amount: ${orderListData['totalAmount']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey,
                                            overflow: TextOverflow.clip
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              else if(titleSnapshot.connectionState == ConnectionState.waiting){
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

                          //User Info's
                          FutureBuilder(
                            future: FirebaseFirestore
                                .instance
                                .collection('/userData')
                                .doc(uid)
                                .get(),
                            builder: (context, userSnapshot) {
                              if(userSnapshot.hasData){
                                return Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4,),
                                      //Name
                                      SelectableText(
                                        'To: ${userSnapshot.data!.get('name')} , ${userSnapshot.data!.get('Phone Number')} ',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: Colors.grey.shade600,
                                            overflow: TextOverflow.clip
                                        ),
                                      ),
                                      //time
                                      Text(
                                        'at ${orderListData['time']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            overflow: TextOverflow.clip
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
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
        else if(adminSnapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        else{
          return const Center(
            child: Text('Error Loading Data'),
          );
        }
      },
    );
  }
}
