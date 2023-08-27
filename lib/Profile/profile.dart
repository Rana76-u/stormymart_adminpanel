import 'package:flutter/material.dart';
import 'package:stormymart_adminpanel/Profile/Completed%20Orders/completed_orders.dart';
import 'package:stormymart_adminpanel/Profile/Processing%20Orders/processing_orders.dart';
import 'package:stormymart_adminpanel/Profile/Sales%20Revenue/sales_revenue.dart';
import 'package:stormymart_adminpanel/Profile/profile_top.dart';
import 'package:stormymart_adminpanel/loginscreen.dart';
import '../Components/auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileTop(),

            //Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  //Buttons
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Processing Orders
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ProcessingOrders(),)
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20, top: 10),
                              child: Row(
                                children: [
                                  //Bike Icon
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                      color: Colors.amber,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.delivery_dining_outlined, color: Colors.white, size: 22,),
                                    ),
                                  ),
                                  //Text
                                  const Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      'Processing Orders',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.5,
                                          fontFamily: 'Urbanist'
                                      ),
                                    ),
                                  ),

                                  const Spacer(),
                                  //Forward button
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Completed Orders
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const CompletedOrders(),)
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  //Bike Icon
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                      color: Color(0xFFFB8500),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.track_changes_outlined, color: Colors.white, size: 22,),
                                    ),
                                  ),
                                  //Blood Donation Posts
                                  const Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      'Completed Orders',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.5,
                                          fontFamily: 'Urbanist'
                                      ),
                                    ),
                                  ),

                                  const Spacer(),
                                  //Forward button
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Sales Revenue
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SalesRevenue(),)
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  //Bike Icon
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                      color: Colors.redAccent,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.add_chart_rounded, color: Colors.white, size: 22,),
                                    ),
                                  ),
                                  //Blood Donation Posts
                                  const Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      'Sales Revenue',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.5,
                                          fontFamily: 'Urbanist'
                                      ),
                                    ),
                                  ),

                                  const Spacer(),
                                  //Forward button
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Returns
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                //Bike Icon
                                Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                    color: Color(0xff023047),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.keyboard_return, color: Colors.white, size: 22,),
                                  ),
                                ),
                                //Blood Donation Posts
                                const Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text(
                                    'Returns',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.5,
                                        fontFamily: 'Urbanist'
                                    ),
                                  ),
                                ),

                                const Spacer(),
                                //Forward button
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        try{
                          Authservice().signOut();
                          setState(() {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const LoginScreen(),)
                            );
                          });
                        }catch(error){
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $error')
                              )
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,//MaterialStateProperty.all(Colors.grey.shade200),
                        elevation: 0.0,
                      ),
                      child: const Text(
                        "Log out",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
