import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stormymart_adminpanel/Components/notification_sender.dart';
import 'package:stormymart_adminpanel/bottom_nav_bar.dart';

class NotificationCreator extends StatefulWidget {
  const NotificationCreator({super.key});

  @override
  State<NotificationCreator> createState() => _NotificationCreatorState();
}

class _NotificationCreatorState extends State<NotificationCreator> {

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ?
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.4,
          child: const LinearProgressIndicator(),
        ),
      )
      :
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.04,),

            //text
            const Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text(
                'Send Notification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 10,),

            //Type in title*
            Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: textWidget('Type in Title*')
            ),
            //title text field
            SizedBox(
              height: 60,
              child: TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder:  OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  prefixIcon: const Icon(
                    Icons.store,
                    color: Colors.green,
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                  labelText: "Enter Title",
                  labelStyle: const TextStyle(
                      color: Colors.green,
                      fontSize: 14
                  ),
                ),
                cursorColor: Colors.green,
              ),
            ),

            //Type in Body*
            Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: textWidget('Type in Body*')
            ),
            //Body text field
            SizedBox(
              height: 60,
              child: TextFormField(
                controller: bodyController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder:  OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  prefixIcon: const Icon(
                    Icons.store,
                    color: Colors.green,
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                  labelText: "Enter Body",
                  labelStyle: const TextStyle(
                      color: Colors.green,
                      fontSize: 14
                  ),
                ),
                cursorColor: Colors.green,
              ),
            ),

            const SizedBox(height: 10,),

            //Send Button
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    if(titleController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(content: Text(
                            'Title is missing',
                          ))
                      );
                    }
                    else if(bodyController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(content: Text(
                            'Body is missing',
                          ))
                      );
                    }
                    else{

                      setState(() {
                        isLoading = true;
                      });

                      //Send Notification
                      await SendNotification.toAll(titleController.text, bodyController.text, 'null');

                      Get.to(
                          BottomBar(bottomIndex: 0),
                          transition: Transition.rightToLeft
                      );

                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.deepOrangeAccent
                    ),
                    elevation:MaterialStateProperty.resolveWith<double>(
                          (Set<MaterialState> states) {
                        return 10.0;
                      },
                    ),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        )
                    ),
                  ),
                  child: const Text(
                    'Send',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white
                    ),
                  )
              ),
            ),

            //Space
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }

  Widget textWidget(String text){
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            overflow: TextOverflow.clip
        ),
      ),
    );
  }
}
