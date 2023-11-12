import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:stormymart_adminpanel/Edit%20Post/edit_post.dart';
import 'package:stormymart_adminpanel/bottom_nav_bar.dart';

import '../../Components/image_viewer.dart';
import '../theme/color.dart';

class ProductScreen extends StatefulWidget {
  final String productId;

  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String variationDocID = '';
  String imageSliderDocID = '';
  int quantity = 1;
  int variationCount = 0;
  int clickedIndex = 0;
  List<dynamic> sizes = [];
  List<dynamic> keywords = [];

  bool variationWarning = false;
  bool sizeWarning = false;
  bool isLoading = false;

  void checkLength() async {
    String id = widget.productId.toString().trim();
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('/Products/$id/Variations')
        .get();

    variationCount = snapshot.docs.length;
    imageSliderDocID = snapshot.docs.first.id;
  }

  @override
  void initState() {
    super.initState();
    checkLength();
  }

  int sizeSelected = -1;
  Color _cardColor(int i) {
    if (sizeSelected == i) {
      return Colors.green;
    }
    else {
      return Colors.white;
    }
  }

  int variationSelected = -1;
  Color _variationCardColor(int i) {
    if (variationSelected == i) {
      return Colors.green;
    }
    else {
      return Colors.blueGrey;
    }
  }

  Future<void> deleteInfo() async {
    final mainDocumentRef =
    FirebaseFirestore.instance.collection('/Products').doc(widget.productId);

    // Delete the sub-collections recursively
    await deleteCollection();

    // Delete the main document
    await mainDocumentRef.delete();
  }

  Future<void> deleteInfoAtAdmin() async {
    await FirebaseFirestore.instance.collection('/Admin Panel')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'Products': FieldValue.arrayRemove([widget.productId]),
    }, SetOptions(merge: true));
  }

  Future<void> deleteCollection() async {
    // Get a reference to the collection
    CollectionReference variationsCollection =
    FirebaseFirestore
        .instance
        .collection('/Products/${widget.productId}/Variations');

    // Get all documents from the collection
    QuerySnapshot querySnapshot = await variationsCollection.get();

    // Loop through the documents and delete them one by one
    for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }

    print("Collection deleted successfully.");
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    String id = widget.productId.toString().trim();
    List<SizedBox> sizeWidget = [];
    return Scaffold(
      backgroundColor: appBgColor,
      body: isLoading ?
      const Center(
        child: CircularProgressIndicator(),
      )
          :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: FutureBuilder (
            future: FirebaseFirestore.instance
                .collection('Products')
                .doc(id)
                .get()
                .then((value) => value),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                var price = snapshot.data!.get('price');
                var discount = snapshot.data!.get('discount');
                double discountCal = (price / 100) * (100 - discount);
                var rating = snapshot.data!.get('rating');
                var sold = snapshot.data!.get('sold');

                //SIZE LIST
                sizes = snapshot.data!.get('size');
                keywords = snapshot.data!.get('keywords');
                //List<SizedBox> sizeWidget = [];
                if(sizeWidget.isEmpty){
                  for (int i = 0; i < sizes.length; i++) {
                    sizeWidget.add(
                      SizedBox(
                        height: 45,
                        width: 45,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              sizeSelected = i;
                              sizeWarning = false;
                            });
                          },
                          child: Card(
                            color: sizeWarning == false ? _cardColor(i) : Colors.red,
                            shape: const CircleBorder(),
                            child: Center(
                              child: Text(
                                sizes[i],
                                style: TextStyle(
                                  color: sizeSelected == i || sizeWarning
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Space From TOP
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Arrow Button
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 10, top: 7, bottom: 6),
                            child: Icon(
                              Icons.arrow_back,
                            ),
                          ),
                        ),

                        //Dot Button
                        PopupMenuButton(
                          // add icon, by default "3 dot" icon
                          // icon: Icon(Icons.book)
                            itemBuilder: (context){
                              return [
                                const PopupMenuItem<int>(
                                  value: 0,
                                  child: Text("Edit"),
                                ),

                                const PopupMenuItem<int>(
                                  value: 1,
                                  child: Text("Delete"),
                                ),
                              ];
                            },
                            onSelected:(value){
                              if(value == 0){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => EditPost(productID: widget.productId),)
                                );
                              }else if(value == 1){
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return  AlertDialog(
                                      title: const Text('Please Confirm'),
                                      content: const Text('Are you sure you want to delete this item?'),
                                      actions: [
                                        // The "Yes" button
                                        TextButton(
                                            onPressed: () async {
                                              final navigator = Navigator.of(context);

                                              setState(() {
                                                isLoading = true;
                                              });

                                              await deleteInfo();

                                              await deleteInfoAtAdmin();

                                              setState(() {
                                                isLoading = false;

                                                navigator.push(
                                                    MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 0),)
                                                );
                                              });
                                            },
                                            child: const Text('Yes')),
                                        TextButton(
                                            onPressed: () {
                                              // Close the dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('No'))
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                        ),
                      ],
                    ),

                    //ImageSlider
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('Products/$id/Variations')
                          .doc(imageSliderDocID)
                          .get()
                          .then((value) => value),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          List<dynamic> images =
                          snapshot.data!.get('images');
                          return images.isNotEmpty ?
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: ImageSlideshow(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.42,//0.45
                                  initialPage: 0,
                                  indicatorColor: Colors.amber,
                                  indicatorBackgroundColor: Colors.grey,
                                  onPageChanged: (value) {},
                                  autoPlayInterval: 7000,
                                  isLoop: true,
                                  children:
                                  List.generate(images.length, (index) {
                                    return GestureDetector(
                                      onTap: (){
                                        /*showImageViewer(
                                                  context,
                                                  NetworkImage(images[index]),
                                                  swipeDismissible: true,
                                                  doubleTapZoomable: true
                                              );*/
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => ImageViewerScreen(imageUrl: images[index],),)
                                        );
                                      },
                                      child: Image.network(
                                        images[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  })),
                            ),
                          ) :  Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  'https://cdn.dribbble.com/users/256646/screenshots/17751098/media/768417cc4f382d6171053ad620bc3c3b.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),

                    //Variation Name & Images
                    SizedBox(
                      height: 130, //112
                      width: double.infinity,
                      child: ListView.builder(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: variationCount,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                            future: FirebaseFirestore
                                .instance
                                .collection('/Products/$id/Variations')
                                .get()
                                .then((value) => value),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                variationDocID = snapshot.data!.docs[index].id;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Name
                                    Container(
                                      margin: const EdgeInsets.only(top: 5, left: 11),
                                      width: 70,
                                      child: Text(
                                        //snapshot.data!.docs[index].id,
                                        variationDocID,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                    //image
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          variationSelected = index;
                                          imageSliderDocID = snapshot.data!.docs[index].id;
                                          variationWarning = false;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 5,left: 10, right: 15, bottom: 15),
                                        width: 70,//200
                                        height: 70,//136.5

                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: variationWarning == false ?
                                              _variationCardColor(index) : Colors.red,
                                              width: 2,//5
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection('/Products/$id/Variations')
                                              .doc(variationDocID) //place String value of selected variation
                                              .get()
                                              .then((value) => value),
                                          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                            if (snapshot.hasData) {
                                              List<dynamic> images =
                                              snapshot.data!.get('images');
                                              return ImageSlideshow(
                                                  width: 200, //double.infinity,
                                                  height: 300, //MediaQuery.of(context).size.height * 0.45,
                                                  initialPage: 0,
                                                  indicatorColor: Colors.amber,
                                                  indicatorBackgroundColor: Colors.grey,
                                                  onPageChanged: (value) {},
                                                  autoPlayInterval: 3500,
                                                  isLoop: true,
                                                  children: List.generate(images.length, (index) {
                                                    return Image.network(
                                                      images[index],
                                                    );
                                                  }));
                                            } else {
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return const Text(
                                  'No Variations',
                                  style: TextStyle(color: Colors.grey),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Discount
                        if(discount != 0)...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade800,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding:   const EdgeInsets.all(10),
                              child: Text(
                                'Discount: $discount%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 10,),
                        //wishlist
                        /*GestureDetector(
                                onTap: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  await FirebaseFirestore
                                      .instance
                                      .collection('/userData')
                                      .doc(FirebaseAuth.instance.currentUser!.uid).update({
                                    'wishlist': FieldValue.arrayUnion([id])
                                  });

                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text('Item added to Wishlist')
                                    )
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Padding(
                                    padding:   EdgeInsets.all(7),
                                    child: Text(
                                      '+ wishlist',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                      ],
                    ),

                    //Title
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 5, left: 0, right: 5),
                      child: Text(
                        snapshot.data!.get('title'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade700
                        ),
                      ),
                    ),

                    //Price
                    Row(
                      children: [
                        Text(
                          "BDT ${discountCal.toStringAsFixed(0)}/-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21.5,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "of ${price.toString()}/-",
                          style: const TextStyle(
                            //fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.lineThrough
                          ),
                        ),
                      ],
                    ),

                    //Rating & Sold
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 15,
                          ),
                          const SizedBox(width: 3,),
                          //Rating
                          Text(
                            rating.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey.shade600//darker
                            ),
                          ),
                          const SizedBox(width: 20,),
                          //Sold
                          Text(
                            "${sold.toString()} Sold",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey.shade600//darker
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        snapshot.data!.get('description'),
                        style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),

                    //Show Sizes
                    if(sizes.isEmpty)...[const SizedBox()]
                    else...[
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: sizes.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return  AlertDialog(
                                      title: const Text('Please Confirm'),
                                      content: const Text('Are you sure you want to delete this item?'),
                                      actions: [
                                        // The "Yes" button
                                        TextButton(
                                            onPressed: () {
                                              // Remove the box
                                              setState(() {
                                                sizes.removeAt(index);
                                              });

                                              // Close the dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Yes')),
                                        TextButton(
                                            onPressed: () {
                                              // Close the dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('No'))
                                      ],
                                    );
                                  },
                                );
                                setState(() {
                                  sizeSelected = index;
                                });
                              },
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)
                                ),//CircleBorder()
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                                    child: Text(
                                      sizes[index],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],

                    // Quantity
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: Text(
                        'Select Quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 39,//42
                      width: MediaQuery.of(context).size.width * 0.41,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                // Decrement quantity
                                setState(() {
                                  if (quantity != 1) {
                                    quantity--;
                                  }
                                });
                              },
                            ),
                            Text(quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                // Increment quantity
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Show Keywords
                    const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: Text(
                        'Keywords',
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    if(keywords.isEmpty)...[const SizedBox()]
                    else...[
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: keywords.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return  AlertDialog(
                                      title: const Text('Please Confirm'),
                                      content: const Text('Are you sure you want to delete this item?'),
                                      actions: [
                                        // The "Yes" button
                                        TextButton(
                                            onPressed: () {
                                              // Remove the box
                                              setState(() {
                                                keywords.removeAt(index);
                                              });

                                              // Close the dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Yes')),
                                        TextButton(
                                            onPressed: () {
                                              // Close the dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('No'))
                                      ],
                                    );
                                  },
                                );
                                setState(() {
                                  sizeSelected = index;
                                });
                              },
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)
                                ),//CircleBorder()
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                                    child: Text(
                                      keywords[index],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],

                    //Space At the BOTTOM
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                );
              }
              else {
                return Center(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.45,),
                      const CircularProgressIndicator(),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
