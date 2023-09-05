import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ProcessingOrders extends StatefulWidget {
  const ProcessingOrders({super.key});

  @override
  State<ProcessingOrders> createState() => _ProcessingOrdersState();
}

class _ProcessingOrdersState extends State<ProcessingOrders> {

  bool isLoading = false;
  List<String> docIds = [];
  String randomID = '';
  String randomOrderListDocID = '';

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
                          .collection('/Orders/${ordersSnapshot.data!.docs[orderUidIndex].id}/Processing Orders')
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
                                      .collection('/Orders/${ordersSnapshot.data!.docs[orderUidIndex].id}/Processing Orders')
                                      .doc(pendingOrderSnapshot.data!.docs[index].id)
                                      .collection('/orderLists')
                                      .get(),
                                  builder: (context, orderListSnapshot) {
                                    if(orderListSnapshot.hasData){
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
                                                        "Placed on : ${pendingOrderSnapshot.data!.docs[index].get('time')}",
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
                                              //Completed Button
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width*0.45 - 20,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: TextButton(
                                                    /*onPressed: () async {

                                    setState(() {
                                      isLoading = true;
                                    });

                                    //Change the reference location
                                    String inputString = pendingOrdersReferences[index].toString();
                                    String filter1 = inputString.replaceAll('DocumentReference<Map<String, dynamic>>(', '');
                                    String filter2 = filter1.replaceAll(')', '');
                                    String result = filter2.replaceAll('Pending Orders', 'Processing');

                                    //Set new reference
                                    DocumentReference orderProcessingReference =
                                    FirebaseFirestore.instance.doc(result);

                                    //Transfer data into new location - 'Processing'
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
                                    DocumentReference pendingOrdersRef =
                                    FirebaseFirestore.instance.doc(filter2);
                                    await FirebaseFirestore.instance
                                        .collection('/Admin Panel')
                                        .doc(FirebaseAuth.instance.currentUser!.uid)
                                        .set({
                                      'Pending Orders': FieldValue.arrayRemove([pendingOrdersRef])
                                    }, SetOptions(merge: true));

                                    //Delete from pending order location
                                    int startIndex = inputString.indexOf('orderLists/') + 'orderLists/'.length;
                                    int endIndex = inputString.length;
                                    String filter3 = inputString.substring(startIndex, endIndex);
                                    String orderListDocID = filter3.replaceAll(')', '');

                                    int endIndexForPath = filter2.indexOf('orderLists/') + 'orderLists/'.length;
                                    String trimmedPath = filter2.substring(0, endIndexForPath);

                                    await FirebaseFirestore
                                        .instance
                                        .collection(trimmedPath)
                                        .doc(orderListDocID).delete();

                                    setState(() {
                                      isLoading = false;
                                      /*ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Marked As Processing\n'
                                                                'Find all processing orders at Profile'
                                                        )
                                                    )
                                                );*/
                                    });
                                  },*/
                                                    onPressed: () async {

                                                      generateRandomID();

                                                      //Order necessary details
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('Orders')
                                                          .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                                                          .collection('Completed Orders').doc(randomID).set({
                                                        'usedPromoCode': pendingOrderSnapshot.data!.docs[index].get('usedPromoCode'),
                                                        'usedCoin': pendingOrderSnapshot.data!.docs[index].get('usedCoin'),
                                                        'total' : pendingOrderSnapshot.data!.docs[index].get('total'),
                                                        'time' : pendingOrderSnapshot.data!.docs[index].get('time'),
                                                      });

                                                      //upload Each Order Details
                                                      for (int i=0; i<orderListSnapshot.data!.docs.length; i++) {
                                                        //For every Cart item
                                                        generateRandomOrderListDocID();
                                                        // add them into Order list
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('Orders')
                                                            .doc(FirebaseAuth.instance.currentUser!.uid)
                                                            .collection('Completed Orders')
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

                                                      //Delete from Processing order
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('Orders')
                                                          .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                                                          .collection('Processing Orders')
                                                          .doc(pendingOrderSnapshot.data!.docs[index].id).delete();

                                                      // Delete the subcollection 'orderLists'
                                                      await FirebaseFirestore.instance
                                                          .collection('Orders')
                                                          .doc(ordersSnapshot.data!.docs[orderUidIndex].id)
                                                          .collection('Processing Orders')
                                                          .doc(pendingOrderSnapshot.data!.docs[index].id)
                                                          .collection('orderLists')
                                                          .get()
                                                          .then((querySnapshot) {
                                                        querySnapshot.docs.forEach((doc) {
                                                          doc.reference.delete();
                                                        });
                                                      });

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
                                                          ' Add to Completed',
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
                                                  endActionPane: ActionPane(
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
                                                  ),
                                                  child: SizedBox(
                                                      height: 170,
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
                                                          : Row(
                                                        children: [

                                                          //Image
                                                          FutureBuilder(
                                                            future: FirebaseFirestore.instance
                                                                .collection('/Products/${orderListSnapshot.data!.docs[index].get('productId')}/Variations')
                                                                .doc(orderListSnapshot.data!.docs[index].get('variant'))
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
                                                                          'Size: ${orderListSnapshot.data!.docs[index].get('selectedSize')}',
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
                                                                          'Variant: ${orderListSnapshot.data!.docs[index].get('variant')}',
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
                                                                          'Quantity: ${orderListSnapshot.data!.docs[index].get('quantity')}',
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
                                                              }else if(titleSnapshot.connectionState == ConnectionState.waiting){
                                                                return Center(
                                                                  child: SizedBox(
                                                                    width: MediaQuery.of(context).size.width*0.4,
                                                                    child: const LinearProgressIndicator(),
                                                                  ),
                                                                );
                                                              }else {
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
                                                  ),
                                                );
                                              },
                                            ),
                                          ]else...[
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
                          /*return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "Pending Order (${snapshot.data!.docs.length})",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist'
                    ),
                  ),
                ),
                if(snapshot.data!.docs.isNotEmpty)...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemBuilder: (context, index) {
                      return Slidable(
                        endActionPane: ActionPane(
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
                        ),
                        child: SizedBox(
                          height: 170,
                          width: double.infinity,
                          child: Row(
                            children: [
                              //Image
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('/Products/${snapshot.data!.docs[index].get('productId')}/Variations')
                                    .doc(snapshot.data!.docs[index].get('variant'))
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
                                  }else if(imageSnapshot.connectionState == ConnectionState.waiting){
                                    return Center(
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width*0.4,
                                        child: const LinearProgressIndicator(),
                                      ),
                                    );
                                  }else {
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
                                    .doc(snapshot.data!.docs[index].get('productId'))
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
                                              'Size: ${snapshot.data!.docs[index].get('selectedSize')}',
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
                                              'Variant: ${snapshot.data!.docs[index].get('variant')}',
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
                                              'Quantity: ${snapshot.data!.docs[index].get('quantity')}',
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
                                  }else if(snapshot.connectionState == ConnectionState.waiting){
                                    return Center(
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width*0.4,
                                        child: const LinearProgressIndicator(),
                                      ),
                                    );
                                  }else {
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
                      );
                    },
                  )
                ]else...[
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
                ]
            ],
          );*/
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
