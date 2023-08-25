import 'package:flutter/material.dart';
import 'package:stormymart_adminpanel/Profile/Processing%20Orders/listofprocessingorders.dart';

class ProcessingOrders extends StatefulWidget {
  const ProcessingOrders({super.key});

  @override
  State<ProcessingOrders> createState() => _ProcessingOrdersState();
}

class _ProcessingOrdersState extends State<ProcessingOrders> {
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
                    'Processing Orders',
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
              const ListOfProcessingOrders(),

              const SizedBox(height: 200,),
            ],
          ),
        ),
      ),
    );
  }
}
