import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stormymart_adminpanel/Profile/Chat%20Screen/chat_screen.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              "Chats",
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold
            ),
          ),
          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 60.2,
          toolbarOpacity: 0.8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25)),
          ),
          elevation: 0.00,
          backgroundColor: Colors.greenAccent[400],
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance.collection('/messages').get(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  String uid = snapshot.data!.docs[index].id;
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection('/userData').doc(uid).get(),
                      builder: (context, userSnapshot) {
                        if(userSnapshot.hasData){
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(userId: uid),
                                )
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    //user image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                          userSnapshot.data!.get('imageURL'),
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),

                                    //Space
                                    const SizedBox(width: 10,),

                                    //Name & Message
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //name
                                        Text(
                                          userSnapshot.data!.get('name'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Urbanist',
                                            overflow: TextOverflow.ellipsis
                                          ),
                                        ),

                                        //new message : isSeen
                                        FutureBuilder(
                                          future: FirebaseFirestore
                                              .instance
                                              .collection('/messages')
                                              .doc(uid)
                                              .get(),
                                          builder: (context, isSeenSnapshot) {
                                            if(isSeenSnapshot.hasData){
                                              bool isSeen = isSeenSnapshot.data!.get('isSeen');
                                              return Text(
                                                isSeen ? '. . .'
                                                    :
                                                    'New Messages • ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            }
                                            else{
                                              return const Center(
                                                child: Text('Loading Data'),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),

                                    //Space
                                    const Expanded(child: SizedBox()),

                                    //icon
                                    const Icon(Icons.arrow_forward_ios_rounded)
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        else if(userSnapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        else{
                          return const Center(
                            child: Text('User Not Found'),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }
            else if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else{
              return const Center(
                child: Text('No Conversation Yet'),
              );
            }
          },
        ),
      ),
    );
  }
}
