import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stormymart_adminpanel/Banners%20&%20Categories/banners.dart';
import 'package:stormymart_adminpanel/Banners%20&%20Categories/categories.dart';
import 'package:stormymart_adminpanel/Banners%20&%20Categories/search_recom.dart';
import 'package:stormymart_adminpanel/Components/imageslider.dart';
import 'package:stormymart_adminpanel/Create%20New%20Post/newpost.dart';
import 'package:stormymart_adminpanel/Edit%20Shop/edit_shop_details.dart';

import '../Components/custom_image.dart';
import '../Product Screen/product_screen.dart';
import '../theme/color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    //Requests Permission to send notification
    requestPermission();
    getToken();
    _checkAndSaveUser();
    //initInfo();
    //_loadUserInfo();
    //_saveUserInfos();
  }

  void requestPermission() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('Permission Granted');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Granted as Provisional');
    }else{
      print('Denied');
    }
  }
  String? phoneToken = '';
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
          setState(() {
            phoneToken = token;
            print("My token is $phoneToken");
          });
          saveTokenInFirebase(token!);
        }
    );
  }
  void saveTokenInFirebase(String token) async {
    await FirebaseFirestore.instance.collection('userTokens')
        .doc(FirebaseAuth.instance.currentUser!.uid).set({
      'token': token,
    });
  }

  _checkAndSaveUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final uid = user.uid;

    final userData = await FirebaseFirestore.instance.collection('/Admin Panel').doc(uid).get();
    if (!userData.exists) {
      // Save user data if the user is new
      FirebaseFirestore.instance.collection('/Admin Panel').doc(uid).set({
        'name' : FirebaseAuth.instance.currentUser?.displayName,
        'Email': FirebaseAuth.instance.currentUser?.email,
        'Phone Number': '',
        'role': 'Seller',
        'Shop Name': '',
        'Shop Logo': '',
        'Products': FieldValue.arrayUnion([]),
        'Followers': FieldValue.arrayUnion([]),
        'Follower Number': 0,
        'shopID': FirebaseAuth.instance.currentUser!.uid
      });
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
      ) : SingleChildScrollView(
        child: FutureBuilder(
          future: FirebaseFirestore
              .instance
              .collection('/Admin Panel')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              String role = snapshot.data!.get('role');
              String shopName = snapshot.data!.get('Shop Name');
              int followerNumber = snapshot.data!.get('Follower Number');
              String shopLogo = snapshot.data!.get('Shop Logo');
              String email = snapshot.data!.get('Email');
              String phoneNumber = snapshot.data!.get('Phone Number');
              List<dynamic> productsIds = snapshot.data!.get('Products');
              return Column(
                children: [
                  //Space
                  SizedBox(height: MediaQuery.of(context).size.height*0.045,),

                  //Create post
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CreatePost(),)
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              '+ Create New Post',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.blueGrey,
                                  fontFamily: 'Urbanist'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  //Edit Category
                  if(role.contains('Admin'))...[
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          //Categories
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const EditCategories(),)
                              );
                            },
                            child: const Card(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                                  child: Text(
                                    'Edit Categories',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //Search Recommendations
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const EditSearchRecommendation(),)
                              );
                            },
                            child: const Card(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                                  child: Text(
                                    'Edit Search Recommendations',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //Banners
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const EditBanner(),)
                              );
                            },
                            child: const Card(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                                  child: Text(
                                    'Edit Banners',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],

                  //Store Info Container
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF607D8B), // Blue-Grey Color at the top
                          Color(0xFF455A64),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        //stops: [0.0, 1.0],
                        //tileMode: TileMode.clamp,
                      ),
                    ),
                    child: Row(
                      children: [
                        //Logo
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                    shopLogo == '' ? 'https://www.senbagcollege.gov.bd/midea/featuredimage/featuredimage2017-06-09-18-13-52_593ac940872ee.jpg' : shopLogo
                                )
                            ),
                          ),
                        ),
                        //Shop Info
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Shop Name
                            Text(
                              shopName == '' ? 'Not Yet Set' : shopName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Urbanist',
                                color: Colors.white
                              ),
                            ),
                            //Followers
                            Text(
                              'Follower: $followerNumber',
                              style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.white,
                                fontSize: 11
                              ),
                            ),
                            //Email
                            SelectableText(
                              email,
                              style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.white,
                                  fontSize: 11
                              ),
                            ),
                            //Phone Number
                            SelectableText(
                              phoneNumber == '' ? 'Not Yet Set' : phoneNumber,
                              style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.white,
                                  fontSize: 11
                              ),
                            ),
                          ],
                        ),
                        //Space
                        const Expanded(child: SizedBox()),
                        //Edit Button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const EditShopDetails(),)
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 35),
                            child: Icon(
                                Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const ImageSlider(),

                  //All Products Text
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'All Products',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbainst'
                      ),
                    ),
                  ),
                  //Posts
                  Expanded(
                    flex: 0,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.59,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      primary: true,
                      itemCount: productsIds.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: FirebaseFirestore.instance.collection('/Products').doc(productsIds[index]).get(),
                          builder: (context, productSnapshot) {
                            if(productSnapshot.hasData){
                              double discountCal = (productSnapshot.data!.get('price') / 100) * (100 - productSnapshot.data!.get('discount'));
                              return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => ProductScreen(productId: productSnapshot.data!.id))
                                      );
                                    },
                                    child: SizedBox(
                                      //width: 200,
                                      width: MediaQuery.of(context).size.width*0.48,
                                      height: 300,
                                      child: Stack(
                                        children: [
                                          //Pulls image from variation 1's 1st image
                                          FutureBuilder(
                                            future: FirebaseFirestore
                                                .instance
                                                .collection('/Products/${productSnapshot.data!.id}/Variations').get(),
                                            builder: (context, snapshot) {
                                              if(snapshot.hasData){
                                                String docID = snapshot.data!.docs.first.id;
                                                return FutureBuilder(
                                                  future: FirebaseFirestore
                                                      .instance
                                                      .collection('/Products/${productSnapshot.data!.id}/Variations').doc(docID).get(),
                                                  builder: (context, imageSnapshot) {
                                                    if(imageSnapshot.hasData){
                                                      return CustomImage(
                                                        imageSnapshot.data?['images'][0],
                                                        radius: 10,
                                                        width: 200,
                                                        height: 210,//210
                                                      );
                                                    }else if(imageSnapshot.connectionState == ConnectionState.waiting){
                                                      return const Center(
                                                        child: LinearProgressIndicator(),
                                                      );
                                                    }
                                                    else{
                                                      return const Center(
                                                        child: Text(
                                                          "Nothings Found",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                );
                                              }
                                              else if(snapshot.connectionState == ConnectionState.waiting){
                                                return const Center(
                                                  child: LinearProgressIndicator(),
                                                );
                                              }
                                              else{
                                                return const Center(
                                                  child: Text(
                                                    "Nothings Found",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),

                                          //Discount %Off
                                          Positioned(
                                            top: 10,
                                            left: 10,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade800,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding:   const EdgeInsets.all(7),
                                                child: Text(
                                                  'Discount: ${productSnapshot.data!.get('discount')}%',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          //Title
                                          Positioned(
                                            top: 220,
                                            left: 5,
                                            child: Text(
                                              productSnapshot.data!.get('title'),
                                              style: const TextStyle(
                                                  overflow: TextOverflow.clip,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Colors.black45//darker
                                              ),
                                            ),
                                          ),

                                          //price
                                          Positioned(
                                              top: 240,
                                              left: 5,
                                              child: Row(
                                                children: [
                                                  /*SvgPicture.asset(
                                        "assets/icons/taka.svg",
                                        width: 17,
                                        height: 17,
                                      ),*/
                                                  Text(
                                                    "Tk ${discountCal.toStringAsFixed(2)}/-",
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 16,
                                                        color: textColor
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),

                                          //Row
                                          Positioned(
                                            top: 260,
                                            left: 2,
                                            child:  Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 15,
                                                ),
                                                const SizedBox(width: 3,),
                                                //Rating
                                                Text(
                                                  productSnapshot.data!.get('rating').toString(),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Colors.grey.shade400//darker
                                                  ),
                                                ),
                                                const SizedBox(width: 20,),
                                                //Sold
                                                Text(
                                                  "${productSnapshot.data!.get('sold').toString()} Sold",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Colors.grey.shade400//darker
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              );
                            }
                            else{
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            else if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else{
              return const Center(
                child: Text('Error Loading Data'),
              );
            }
          }
        ),
      ),
    );
  }
}
