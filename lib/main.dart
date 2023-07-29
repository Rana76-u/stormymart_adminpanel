import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stormymart_adminpanel/firebase_options.dart';
import 'package:stormymart_adminpanel/loginscreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),//LockScreen
    );
  }
}