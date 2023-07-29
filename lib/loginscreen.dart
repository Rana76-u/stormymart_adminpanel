import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'bottom_nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String otpInput = '';

  TextEditingController uidController = TextEditingController();
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();

  final CollectionReference _staffReference =
  FirebaseFirestore.instance.collection('/Admin Panel');

  void checkUser() async{
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    //Gets the document snapshot of UID user
    var document = await _staffReference.doc(uidController.text).get();

    otpInput = otp1Controller.text + otp2Controller.text + otp3Controller.text + otp4Controller.text;

    if(document.exists){
      final DocumentSnapshot snapshot = await _staffReference.doc(uidController.text).get();
      if(snapshot.data() != null && snapshot.data().toString().contains(otpInput)){
        navigator.push(
            MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 0))
        );
        messenger.showSnackBar( const SnackBar(content: Text("Login Successful")));
      }
    }else{
      //Show Snack Bar
      messenger.showSnackBar( const SnackBar(content: Text("Not Found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              Lottie.asset('assets/lottie/login.json'),
              const Text(
                "Enter UID: ",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //UID TextField
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: TextField(
                  controller: uidController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none
                    ),
                    hintText: "223******1",
                    prefixIcon: const Icon(Icons.onetwothree),
                    filled: true,
                    //if not matched then set error text
                    //errorText: 'Error',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const Text(
                "Enter OTP: ",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //OTP Text Fields
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 15, left: 10, right: 10),
                child: Form(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 68,
                        width: 64,
                        child: TextFormField(
                          onChanged: (value){
                            if(value.length == 1){
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          onSaved: (otp1) {},
                          controller: otp1Controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            hintText: "1",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 68,
                        width: 64,
                        child: TextFormField(
                          controller: otp2Controller,
                          onChanged: (value){
                            if(value.length == 1){
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          onSaved: (otp2) {},
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            hintText: "2",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 68,
                        width: 64,
                        child: TextFormField(
                          controller: otp3Controller,
                          onChanged: (value){
                            if(value.length == 1){
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          onSaved: (otp3) {},
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            hintText: "3",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 68,
                        width: 64,
                        child: TextFormField(
                          controller: otp4Controller,
                          onChanged: (value){
                            if(value.length == 1){
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          onSaved: (otp4) {},
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            hintText: "4",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Login Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    if(uidController.text == ""){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Input UID*")));
                    }else{
                      checkUser();
                    }
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                  child: const Text("Goto Home"),
                  onPressed: (){
                    /*Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 0))
                    );*/
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}
