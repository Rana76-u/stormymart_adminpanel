import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileTop extends StatefulWidget {
  const ProfileTop({super.key});

  @override
  State<ProfileTop> createState() => _ProfileTopState();
}

class _ProfileTopState extends State<ProfileTop> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.05,),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Profile Photo
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        FirebaseAuth.instance.currentUser!.photoURL.toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  //Texts
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser!.displayName.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis
                          ),
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser!.email.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
