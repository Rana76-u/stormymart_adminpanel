import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {

  bool isLoading = false;
  List<String> docIds = [];
  List<String> pendingOrdersDocIds = [];

  @override
  void initState() {
    isLoading = true;
    fetchDocIds();
    super.initState();
  }

  //Doc Id's of all Product
  Future<void> fetchDocIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/Products').get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      docIds.add(documentSnapshot.id);
    }
    fetchPendingOrdersDocIds();
  }

  //Doc Id's of all Pending orders
  Future<void> fetchPendingOrdersDocIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/Orders').get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      pendingOrdersDocIds.add(documentSnapshot.id);
    }
    setState(() {
      isLoading = false;
    });
    print(pendingOrdersDocIds);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    const Center(
      child: CircularProgressIndicator(),
    ) :
    ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingOrdersDocIds.length,
      itemBuilder: (context, pendingOrdersDocIdsIndex) {
        if(pendingOrdersDocIds.isNotEmpty){
          return Column(
            children: [
              FutureBuilder(
                future: FirebaseFirestore
                    .instance
                    .collection('/userData')
                    .doc(pendingOrdersDocIds[pendingOrdersDocIdsIndex])
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
                                'Address1: ${userSnapshot.data!.get('Address2')[0]}, ${userSnapshot.data!.get('Address2')[1]}',
                                style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        )
                      ],
                    );
                  }else{
                    return const Text('Error Loading Data');
                  }
                },
              ),
              FutureBuilder(
                future: FirebaseFirestore
                    .instance
                    .collection('/Orders/${pendingOrdersDocIds[pendingOrdersDocIdsIndex]}/Pending Orders')
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.5)
                          ),
                          child: FutureBuilder(
                            future: FirebaseFirestore
                                .instance
                                .collection('/Orders/${pendingOrdersDocIds[pendingOrdersDocIdsIndex]}/Pending Orders')
                                .doc(pendingOrderSnapshot.data!.docs[index].id)
                                .collection('/orderLists')
                                .get(),
                            builder: (context, orderListSnapshot) {
                              if(orderListSnapshot.hasData){
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Order items
                                    Column(
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
                  }else if(pendingOrderSnapshot.connectionState == ConnectionState.waiting){
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

              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey.shade500,
                ),
              )
            ],
          );
        }
        else{
          return const Center(
            child: Text('No Pending Orders'),
          );
        }
      },
    );
  }
}
