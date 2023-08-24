import 'package:flutter/material.dart';
import 'package:stormymart_adminpanel/Pending%20Orders/listoforders.dart';

import 'orders(unused).dart';

class PendingOrders extends StatefulWidget {
  const PendingOrders({super.key});

  @override
  State<PendingOrders> createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),
              const Row(
                children: [
                  Text(
                    'Pending Orders',
                    style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 5,),

              //PendingOrders,
              //const Orders(),
              const ListOfOrders(),

              const SizedBox(height: 200,),
            ],
          ),
        ),
      ),
    );
  }
}
