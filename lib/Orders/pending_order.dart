import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stormymart_adminpanel/Components/notification_sender.dart';
import 'package:stormymart_adminpanel/Profile/Chat%20Screen/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PendingOrders extends StatefulWidget {
  const PendingOrders({super.key});

  @override
  State<PendingOrders> createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> {

  bool isLoading = false;
  List<String> docIds = [];
  String randomID = '';
  String randomOrderListDocID = '';
  String token = '';

  @override
  void initState() {
    isLoading = true;
    fetchDocIds();
    super.initState();
  }

  //For to check if the product is listed or not by matching productID
  Future<void> fetchDocIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/Products').get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      docIds.add(documentSnapshot.id);
    }
    setState(() {
      isLoading = false;
    });
  }

  void generateRandomID() {
    Random random = Random();
    const String chars = "0123456789abcdefghijklmnopqrstuvwxyz";

    for (int i = 0; i < 20; i++) {
      randomID += chars[random.nextInt(chars.length)];
    }
  }

  void generateRandomOrderListDocID() {
    Random random = Random();
    const String chars = "0123456789abcdefghijklmnopqrstuvwxyz";

    for (int i = 0; i < 20; i++) {
      randomOrderListDocID += chars[random.nextInt(chars.length)];
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading ?
    const Center(
      child: CircularProgressIndicator(),
    ) :
    FutureBuilder(
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
              return FutureBuilder(
                future: FirebaseFirestore
                    .instance
                    .collection('/Orders')
                    .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                    .collection('Pending Orders').get(),
                builder: (context, checkPendingOrderSnapshot) {

                  var checker = checkPendingOrderSnapshot.data?.docs.isNotEmpty;

                  if(checker == true){
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.5)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          //User Info's
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //info
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
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
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                      onTap: () async {
                                                        final Uri launchUri = Uri(
                                                          scheme: 'tel',
                                                          path: userSnapshot.data!.get('Phone Number'),
                                                        );
                                                        await launchUrl(launchUri);
                                                      },
                                                      child: const Icon(
                                                        Icons.call,
                                                        size: 20,
                                                      )
                                                  ),
                                                  SelectableText(
                                                    userSnapshot.data!.get('Phone Number'),
                                                    style: const TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12
                                                    ),
                                                  ),
                                                ],
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
                                          //copy
                                          GestureDetector(
                                            onTap: () async {
                                              final messenger = ScaffoldMessenger.of(context);

                                              await Clipboard.setData(ClipboardData(
                                                  text: '${userSnapshot.data!.get('name')}\n'
                                                  '${userSnapshot.data!.get('Email')}\n'
                                                  '${userSnapshot.data!.get('Phone Number')}\n'
                                                  'Address1: ${userSnapshot.data!.get('Address1')[0]}, ${userSnapshot.data!.get('Address1')[1]}\n'
                                                  'Address2: ${userSnapshot.data!.get('Address2')[0]}, ${userSnapshot.data!.get('Address2')[1]}\n'
                                              ));

                                              const snackBar = SnackBar(
                                                content: Text('Copied to Clipboard'),
                                              );
                                              messenger.showSnackBar(snackBar);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.only(left: 20),
                                              child: Icon(
                                                Icons.copy,
                                                color: Colors.grey,
                                              ),
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
                              //message
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    ChatScreen(userId: ordersSnapshot.data!.docs[orderUidIndex].id),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(
                                      Icons.message_rounded,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //user's orders
                          FutureBuilder(
                            future: FirebaseFirestore
                                .instance
                                .collection('/Orders/${ordersSnapshot.data!.docs[orderUidIndex].id}/Pending Orders')
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
                                            .collection('/Orders/${ordersSnapshot.data!.docs[orderUidIndex].id}/Pending Orders')
                                            .doc(pendingOrderSnapshot.data!.docs[index].id)
                                            .collection('/orderLists')
                                            .get(),
                                        builder: (context, orderListSnapshot) {
                                          if(orderListSnapshot.hasData){
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                //Order items info
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
                                                          /*Padding(
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
                                                    ),*/
                                                          //Time
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 0, left: 15),
                                                            child: Text(
                                                              "Placed on : ${
                                                                  DateFormat('EE, dd/MM H:mm')
                                                                      .format(pendingOrderSnapshot.data!.docs[index].get('time').toDate())
                                                              }",
                                                              style: const TextStyle(
                                                                  fontSize: 12.5,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily: 'Urbanist',
                                                                  color: Colors.grey
                                                              ),
                                                            ),
                                                          ),
                                                          //Location
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 0, left: 15),
                                                            child: SelectableText(
                                                              "Delivery Address : ${pendingOrderSnapshot.data!.docs[index].get('deliveryLocation')}",
                                                              style: const TextStyle(
                                                                fontSize: 12.5,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: 'Urbanist',
                                                              ),
                                                            ),
                                                          ),
                                                          //Coin
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 0, left: 15),
                                                            child: Text(
                                                              "Coin Used : ${pendingOrderSnapshot.data!.docs[index].get('usedCoin')}",
                                                              style: const TextStyle(
                                                                  fontSize: 12.5,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily: 'Urbanist',
                                                                  color: Colors.grey
                                                              ),
                                                            ),
                                                          ),
                                                          //Promo Code
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 0, left: 15),
                                                            child: Text(
                                                              "Promo Code : ${pendingOrderSnapshot.data!.docs[index].get('usedPromoCode')}",
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
                                                    //Add to Processing Button
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width*0.45 - 20,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10),
                                                        child: TextButton(
                                                          onPressed: () async {

                                                            setState(() {
                                                              isLoading = true;
                                                            });

                                                            generateRandomID();

                                                            //Order necessary details
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection('Orders')
                                                                .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                                                                .collection('Processing Orders').doc(randomID).set({
                                                              'usedPromoCode': pendingOrderSnapshot.data!.docs[index].get('usedPromoCode'),
                                                              'usedCoin': pendingOrderSnapshot.data!.docs[index].get('usedCoin'),
                                                              'total' : pendingOrderSnapshot.data!.docs[index].get('total'),
                                                              'time' : pendingOrderSnapshot.data!.docs[index].get('time'),
                                                              'deliveryLocation': pendingOrderSnapshot.data!.docs[index].get('deliveryLocation'),
                                                            });

                                                            //upload Each Order Details
                                                            for (int i=0; i<orderListSnapshot.data!.docs.length; i++) {
                                                              //For every Cart item
                                                              generateRandomOrderListDocID();
                                                              // add them into Order list
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection('Orders')
                                                                  .doc(ordersSnapshot.data!.docs[orderUidIndex].id) //Problem was here
                                                                  .collection('Processing Orders')
                                                                  .doc(randomID)
                                                                  .collection('orderLists')
                                                                  .doc(randomOrderListDocID)
                                                                  .set({
                                                                'productId' : orderListSnapshot.data!.docs[i].get('productId'),
                                                                'quantity' : orderListSnapshot.data!.docs[i].get('quantity'),
                                                                'selectedSize' : orderListSnapshot.data!.docs[i].get('selectedSize'),
                                                                'variant' : orderListSnapshot.data!.docs[i].get('variant'),
                                                              });
                                                            }

                                                            //Delete from Pending order
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection('Orders')
                                                                .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                                                                .collection('Pending Orders')
                                                                .doc(pendingOrderSnapshot.data!.docs[index].id).delete();

                                                            // Delete the subCollection 'orderLists'
                                                            FirebaseFirestore.instance
                                                                .collection('Orders')
                                                                .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                                                                .collection('Pending Orders')
                                                                .doc(pendingOrderSnapshot.data!.docs[index].id)
                                                                .collection('orderLists')
                                                                .get()
                                                                .then((querySnapshot) {
                                                              querySnapshot.docs.forEach((doc) {
                                                                doc.reference.delete();
                                                              });
                                                            });

                                                            //Send Push Notification
                                                            final tokenSnapshot = await FirebaseFirestore.instance.collection('userTokens')
                                                                .doc(ordersSnapshot.data!.docs[orderUidIndex].id).get();

                                                            token = tokenSnapshot.get('token');

                                                            await SendNotification.toSpecific(
                                                                "Order Update",
                                                                'Your Order Started Processing',
                                                                token,
                                                                'BottomBar(bottomIndex: 3)'
                                                            );
                                                            //-------------------------------------

                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.done_all_rounded,
                                                                size: 12,
                                                              ),
                                                              Text(
                                                                ' Add to Processing',
                                                                style: TextStyle(
                                                                    fontSize: 12
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                //item list
                                                if(orderListSnapshot.data!.docs.isNotEmpty)...[
                                                  ListView.separated(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: orderListSnapshot.data!.docs.length,
                                                    separatorBuilder: (context, index) {
                                                      return const Divider();
                                                    },
                                                    itemBuilder: (context, index) {
                                                      return Slidable(
                                                        /*endActionPane: ActionPane(
                                                          motion: const BehindMotion(),
                                                          children: [
                                                            SlidableAction(
                                                              backgroundColor: Colors.redAccent.withAlpha(60),
                                                              icon: Icons.cancel_rounded,
                                                              label: 'Cancel Order',
                                                              autoClose: true,
                                                              borderRadius: BorderRadius.circular(15),
                                                              spacing: 5,
                                                              foregroundColor: Colors.redAccent,
                                                              padding: const EdgeInsets.all(10),
                                                              onPressed: (context) async {
                                                                /*deleteDocument(index);
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 2),)
                                );*/
                                                              },
                                                            ),
                                                          ],
                                                        ),*/
                                                        child: SizedBox(
                                                            width: double.infinity,
                                                            child: (!docIds.contains(orderListSnapshot.data!.docs[index].get('productId'))) ?
                                                            const Center(
                                                              child: Text(
                                                                'Item Got Deleted',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.grey
                                                                ),
                                                              ),
                                                            )
                                                                :
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(3.5),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.grey.shade200,
                                                                  borderRadius: BorderRadius.circular(15.0),
                                                                ),
                                                                child: Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [

                                                                    //Image
                                                                    SizedBox(
                                                                      height: 80,
                                                                      width: 80,
                                                                      child: FutureBuilder(
                                                                        future: FirebaseFirestore.instance
                                                                            .collection('/Products/${orderListSnapshot.data!.docs[index].get('productId')}/Variations')
                                                                            .doc(orderListSnapshot.data!.docs[index].get('variant'))
                                                                            .get(),
                                                                        builder: (context, imageSnapshot) {
                                                                          if(imageSnapshot.hasData){
                                                                            return Padding(
                                                                              padding: const EdgeInsets.only(right: 3, left: 0),
                                                                              child: Container(
                                                                                width: 80,//150, 0.40 - 25
                                                                                height: 80, //137
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
                                                                    ),

                                                                    //Texts
                                                                    FutureBuilder(
                                                                      future: FirebaseFirestore.instance
                                                                          .collection('/Products')
                                                                          .doc(orderListSnapshot.data!.docs[index].get('productId'))
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
                                                                                Text(
                                                                                  titleSnapshot.data!.get('title'),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),

                                                                                //Price
                                                                                Text(
                                                                                  'Price: ${titleSnapshot.data!.get('price')} BDT',
                                                                                  style: const TextStyle(
                                                                                      fontSize: 13,
                                                                                      color: Colors.black54,
                                                                                      fontWeight: FontWeight.bold
                                                                                  ),
                                                                                ),

                                                                                //Size
                                                                                Text(
                                                                                  'Size: ${orderListSnapshot.data!.docs[index].get('selectedSize')}',
                                                                                  style: const TextStyle(
                                                                                      fontSize: 12,
                                                                                      color: Colors.black54
                                                                                  ),
                                                                                ),

                                                                                //Variant
                                                                                Text(
                                                                                  'Variant: ${orderListSnapshot.data!.docs[index].get('variant')}',
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(
                                                                                      fontSize: 12,
                                                                                      color: Colors.black54
                                                                                  ),
                                                                                ),

                                                                                //Quantity
                                                                                Text(
                                                                                  'Quantity: ${orderListSnapshot.data!.docs[index].get('quantity')}',
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(
                                                                                      fontSize: 12,
                                                                                      color: Colors.black54
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
                                                                ),
                                                              ),
                                                            )
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ]
                                                else...[
                                                  const Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(bottom: 10),
                                                      child: Text(
                                                        'Nothing to Show',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontFamily: 'Urbanist'
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
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
                  }
                  else{
                    return const SizedBox();
                  }
                },
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
