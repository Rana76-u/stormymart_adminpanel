import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'Components/auth_service.dart';
import 'bottom_nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String otpInput = '';
  bool isLoading = false;

  TextEditingController uidController = TextEditingController();
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();

  final CollectionReference _staffReference =
  FirebaseFirestore.instance.collection('/Admin Panel');

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: isLoading ?
        const Center(
          child: CircularProgressIndicator(),
        )
            :
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.03),

              Lottie.asset('assets/lottie/login.json'),

              const Expanded(child: SizedBox()),

              //Google
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width*0.45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                    onPressed: () async{
                      setState(() {
                        isLoading = true;
                      });

                      //await Authservice().signInWithGoogle();
                      Authservice().signInWithGoogle().then((_) {
                        setState(() {
                          isLoading = false;
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 0),)
                          );
                        });
                      }).catchError((error) {
                        // Handle any error that occurred during sign-in
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error: $error')
                            )
                        );
                        setState(() {
                          isLoading = false;
                        });
                      });

                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.transit_enterexit),
                        Text(
                          'Login using Google',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.bold,
                              fontSize: 13
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
