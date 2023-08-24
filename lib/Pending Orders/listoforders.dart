import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListOfOrders extends StatefulWidget {
  const ListOfOrders({super.key});

  @override
  State<ListOfOrders> createState() => _ListOfOrdersState();
}

class _ListOfOrdersState extends State<ListOfOrders> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('/Admin Panel')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, adminSnapshot) {
        if(adminSnapshot.hasData){

          List<dynamic> pendingOrdersReferences = adminSnapshot.data!.get('Pending Orders') ;
          String uid = '';

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingOrdersReferences.length,
            itemBuilder: (context, index) {

              //Finds the uid
              String inputString = pendingOrdersReferences[index].toString();
              int startIndex = inputString.indexOf('Orders/') + 'Orders/'.length;
              int endIndex = inputString.indexOf('/Pending Orders');
              uid = inputString.substring(startIndex, endIndex);

              DocumentReference orderListReference = pendingOrdersReferences[index];
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
                          //User Info's
                          FutureBuilder(
                            future: FirebaseFirestore
                                .instance
                                .collection('/userData')
                                .doc(uid)
                                .get(),
                            builder: (context, userSnapshot) {
                              if(userSnapshot.hasData){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
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
                                    ),
                                     Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: TextButton(
                                        onPressed: () async {

                                          //Change the reference location
                                          String inputString = pendingOrdersReferences[index].toString();
                                          String result = inputString.replaceAll('Pending Orders', 'Processing');

                                          //Set new reference
                                          DocumentReference orderProcessingReference =
                                              FirebaseFirestore.instance.doc(result);

                                          //Transfer data into new location
                                          await orderProcessingReference.set({
                                            'productId': orderListData['productId'],
                                            'quantity': orderListData['quantity'],
                                            'selectedSize': orderListData['selectedSize'],
                                            'variant': orderListData['variant']
                                          });

                                          //Add new reference location into Seller's 'Processing' Array
                                          await FirebaseFirestore.instance
                                              .collection('/Admin Panel')
                                              .doc(FirebaseAuth.instance.currentUser!.uid)
                                              .set({
                                            'Processing': FieldValue.arrayUnion([orderProcessingReference])
                                          }, SetOptions(merge: true));

                                          //Delete from Seller's Pending Orders array
                                          await FirebaseFirestore.instance
                                              .collection('/Admin Panel')
                                              .doc(FirebaseAuth.instance.currentUser!.uid)
                                              .set({
                                            'Pending Orders': FieldValue.arrayRemove([orderProcessingReference])
                                          }, SetOptions(merge: true));

                                          //Delete from pending order location
                                          int startIndex = inputString.indexOf('orderLists/') + 'orderLists/'.length;
                                          int endIndex = inputString.length;
                                          String orderListDocID = inputString.substring(startIndex, endIndex);

                                          // Extract the until Pending Orders
                                          int endIndexForPath = inputString.indexOf('orderLists/') + 'orderLists/'.length;
                                          String trimmedPath = inputString.substring(0, endIndexForPath);
                                          
                                          await FirebaseFirestore
                                              .instance
                                              .collection(trimmedPath)
                                              .doc(orderListDocID).delete();

                                          setState(() {

                                          });
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.done_all_rounded,
                                              size: 12,
                                            ),
                                            Text(
                                                ' Processing',
                                              style: TextStyle(
                                                fontSize: 12
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }
                              else{
                                return const Text('Error Loading Data');
                              }
                            },
                          ),

                          //Order
                          Row(
                            children: [

                              //Image
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('/Products/${orderListData['productId']}/Variations')
                                    .doc(orderListData['variant'])
                                    .get(),
                                builder: (context, imageSnapshot) {
                                  if(imageSnapshot.hasData){
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12, left: 12),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width*0.40 - 25,//150,
                                        height: 137,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 4,
                                                color: Colors.transparent
                                            ),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child:  Image.network(
                                            imageSnapshot.data!.get('images')[0],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  else if(imageSnapshot.connectionState == ConnectionState.waiting){
                                    return Center(
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width*0.4,
                                        child: const LinearProgressIndicator(),
                                      ),
                                    );
                                  }
                                  else if(!imageSnapshot.data!.exists){
                                    print('not exists');
                                    return const Text('Data not Found');
                                  }
                                  else {
                                    return const Center(
                                      child: Text(
                                        'Error Loading Image',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),

                              //Texts
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('/Products')
                                    .doc(orderListData['productId'])
                                    .get(),
                                builder: (context, titleSnapshot) {
                                  if(titleSnapshot.hasData){
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width*0.48,//200,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          //Title
                                          Padding(
                                            padding: const EdgeInsets.only(top: 25),
                                            child: Text(
                                              titleSnapshot.data!.get('title'),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          //Price
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: Text(
                                              'Price: ${titleSnapshot.data!.get('price')} BDT',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),

                                          //Size
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: Text(
                                              'Size: ${orderListData['selectedSize']}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54
                                              ),
                                            ),
                                          ),

                                          //Variant
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              'Variant: ${orderListData['variant']}',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54
                                              ),
                                            ),
                                          ),

                                          //Quantity
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              'Quantity: ${orderListData['quantity']}',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54
                                              ),
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

                            ],
                          )
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
