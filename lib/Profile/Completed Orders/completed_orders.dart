import 'package:flutter/material.dart';
import 'list_of_completed_orders.dart';

class CompletedOrders extends StatefulWidget {
  const CompletedOrders({super.key});

  @override
  State<CompletedOrders> createState() => _CompletedOrdersState();
}

class _CompletedOrdersState extends State<CompletedOrders> {
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
              const Column(
                children: [
                  Text(
                    'Completed Orders',
                    style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5,),

              const ListOfCompletedOrders(),

              const SizedBox(height: 200,),
            ],
          ),
        ),
      ),
    );
  }
}
