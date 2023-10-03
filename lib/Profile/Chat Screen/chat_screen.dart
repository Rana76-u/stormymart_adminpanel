import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stormymart_adminpanel/Components/image_viewer.dart';
import 'package:image/image.dart' as img;
import 'package:stormymart_adminpanel/Components/notification_sender.dart';
import '../../Components/custom_image.dart';

class ChatScreen extends StatefulWidget {
  //final String sellerId;
  final String userId;
  final String? productId;

  const ChatScreen({
    super.key,
    //required this.sellerId,
    required this.userId,
    this.productId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  //FirebaseAuth.User? _user;
  //String uid = '';
  String userName = '';
  String userPhotoUrl = '';
  bool isLoading = false;
  String randomID = '';
  String token = '';

  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;
  String? imageLink;
  bool isSending = false;

  @override
  void initState() {
    isLoading = true;
    setIsSeen();
    super.initState();
    //_getUser();
  }

  void generateRandomID() {
    Random random = Random();
    const String chars = "0123456789";

    for (int i = 0; i < 10; i++) {
      randomID += chars[random.nextInt(chars.length)];
    }
  }

  Future<void> _uploadImages() async {
    final messenger = ScaffoldMessenger.of(context);

    generateRandomID();

    File compressedFile = await _compressImage(File(image!.path));
    Reference ref = FirebaseStorage
        .instance
        .ref()
        .child('Chat Media/$randomID'); //DateTime.now().millisecondsSinceEpoch
    UploadTask uploadTask = ref.putFile(compressedFile);
    TaskSnapshot snapshot = await uploadTask;
    if (snapshot.state == TaskState.success) {
      String downloadURL = await snapshot.ref.getDownloadURL();
      imageLink = downloadURL;
    } else {
      messenger.showSnackBar(SnackBar(content: Text('An Error Occurred\n${snapshot.state}')));
      return;
    }
  }

  Future<File> _compressImage(File file) async {
    img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image != null) {
      img.Image compressedImage = img.copyResize(image, width: 1024);
      return File('${file.path}_compressed.jpg')..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 70));
    }
    else {
      return file;
    }
  }

  /*void _getUser() async {
    uid = _auth.currentUser!.uid;
  }*/

  Future<void> setIsSeen() async {
    await _firestore
      .collection('messages')
      .doc(widget.userId). set({
    'isSeen': true
  });
    await loadUserData();
  }

  Future<void> loadUserData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore
        .instance
        .collection('/userData')
        .doc(widget.userId)
        .get();
    userName = snapshot.get('name');
    userPhotoUrl = snapshot.get('imageURL');

    setState(() {
      isLoading = false;
    });
  }

  void _sendMessage(String text) async {

      await _firestore
          .collection('messages')
          .doc(widget.userId)
          .collection('message').add({
        'text': text,
        'senderId': 'seller',
        //'receiverId': widget.sellerId,
        'productId': widget.productId ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

    _messageController.clear();

      //Send Push Notification
      final tokenSnapshot = await FirebaseFirestore.instance.collection('userTokens')
          .doc(widget.userId).get();

      token = tokenSnapshot.get('token');

      await SendNotification.toSpecific(
          "Seller Messaged You",
          text,
          token,
          'BottomBar(bottomIndex: 2)'
      );
    //-------------------------------------
  }

  void _sendImage() async {
    await _uploadImages();

    await _firestore
        .collection('messages')
        .doc(widget.userId)
        .collection('message').add({
      'text': imageLink,
      'senderId': 'seller',
      //'receiverId': widget.sellerId,
      'productId': widget.productId ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    //Send Push Notification
    final tokenSnapshot = await FirebaseFirestore.instance.collection('userTokens')
        .doc(widget.userId).get();

    token = tokenSnapshot.get('token');

    await SendNotification.toSpecific(
        "Seller Sent An Image",
        '',
        token,
        'BottomBar(bottomIndex: 2)'
    );
    //-------------------------------------

    setState(() {
      image = null;
      imageLink = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat with '$userName'",
          style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis
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
      body: isLoading ? const Center(
        child: CircularProgressIndicator(),
      )
          :
      Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('messages')
                  .doc(widget.userId)
                  .collection('message')
              //.where('senderId', whereIn: [uid, widget.sellerId])
              //.where('receiverId', whereIn: [uid, widget.sellerId])
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                List<DocumentSnapshot> messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message['text'];
                  final messageSender = message['senderId'];
                  final messageTime = message['timestamp'];
                  final messageProductId = message['productId'];
                  final messageWidget = MessageWidget(
                    text: messageText,
                    isMe: messageSender == 'seller',
                    timestamp: messageTime,
                    productId: messageProductId,
                    userName: userName,
                    userPhoto: userPhotoUrl,
                  );
                  messageWidgets.add(messageWidget);
                }
                return ListView(
                  controller: _scrollController,
                  children: messageWidgets,
                );
              },
            ),
          ),

          //Typing Doc
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 12),
            child: Row(
              children: <Widget>[
                //TextBox
                image != null ?
                Expanded(
                  child: Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width*0.45,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200
                      ),
                      child: Row(
                        children: [
                          //Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                                File(image!.path)
                            ),
                          ),

                          //Space
                          const SizedBox(width: 5,),

                          //Cancel Icon
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                image = null;
                              });
                            },
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      )
                  ),
                )
                    :
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      maxHeight: 150,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey.shade200
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 5),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          autofocus: true,
                          maxLines: null,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              hintText: ' Aa . . .',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                              ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //Space
                const SizedBox(width: 5,),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey.shade200,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () {
                      // Pick Image
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Pick Image From'),
                            content: const Text('Choose One'),
                            actions: [
                              // The "Camera" button
                              TextButton(
                                  onPressed: () async {
                                    image = await _imagePicker.pickImage(source: ImageSource.camera);
                                    setState(() {
                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: const Text('Camera')),
                              TextButton(
                                  onPressed: () async {
                                    image = await _imagePicker.pickImage(source: ImageSource.gallery);
                                    setState(() {
                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: const Text('Gallery')
                              ),
                              TextButton(
                                  onPressed: () {
                                    // Close the dialog
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel')
                              ),
                            ],
                          );
                        },
                      );

                      // Show Image
                      // Compress Image
                      // Send Image
                    },
                  ),
                ),

                //Space
                const SizedBox(width: 5,),

                //Send Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey.shade200,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blueGrey,
                    ),
                    onPressed: (){

                      setState(() {
                        isSending = true;
                      });

                      if(image != null){
                        _sendImage();
                      }
                      else{
                        if (_messageController.text.isNotEmpty) {
                          _sendMessage(_messageController.text);
                        }
                      }

                      setState(() {
                        isSending = false;
                      });
                    },
                  ),
                ),

                isSending ?
                    const LinearProgressIndicator()
                    :
                    const SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isMe;
  final Timestamp timestamp;
  final String productId;
  final String userName;
  final String userPhoto;

  const MessageWidget({
    super.key,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.productId,
    required this.userName,
    required this.userPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        //TimeStamp
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            DateFormat('EE, dd/MM H:mm').format(timestamp.toDate()).toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                color: Colors.grey
            ),
          ),
        ),

        //Product Information
        productId != '' ?
        isMe ?
        Row(
          children: [
            //Space
            const SizedBox(width: 15,),

            //product info
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  //Pulls image from variation 1's 1st image
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FutureBuilder(
                      future: FirebaseFirestore
                          .instance
                          .collection('/Products/$productId/Variations').get(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          String docID = snapshot.data!.docs.first.id;
                          return FutureBuilder(
                            future: FirebaseFirestore
                                .instance
                                .collection('/Products/$productId/Variations').doc(docID).get(),
                            builder: (context, imageSnapshot) {
                              if(imageSnapshot.hasData){
                                return CustomImage(
                                  imageSnapshot.data?['images'][0],
                                  radius: 10,
                                  width: 200,
                                  height: 210,//210
                                );
                              }
                              else if(imageSnapshot.connectionState == ConnectionState.waiting){
                                return const Center(
                                  child: LinearProgressIndicator(),
                                );
                              }
                              else{
                                return const Center(
                                  child: Text(
                                    "Nothings Found",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                        else if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: LinearProgressIndicator(),
                          );
                        }
                        else{
                          return const Center(
                            child: Text(
                              "Nothings Found",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  //title, price
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width*0.4,
                    child: FutureBuilder(
                      future: FirebaseFirestore
                          .instance
                          .collection('/Products')
                          .doc(productId)
                          .get(),
                      builder: (context, productSnapshot) {
                        if(productSnapshot.hasData){
                          String title = productSnapshot.data!.get('title') ?? '';
                          String price = productSnapshot.data!.get('price').toString();
                          return Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //title
                                Text(
                                  title,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      fontFamily: 'Urbanist',
                                      color: Colors.black
                                  ),
                                ),
                                //price
                                Text(
                                  'Price: $price',
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      fontFamily: 'Urbanist',
                                      color: Colors.black
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        else if(productSnapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: LinearProgressIndicator(),
                          );
                        }
                        else{
                          return const Center(
                            child: Text('Error Loading Data'),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const Expanded(child: SizedBox()),
          ],
        )
            :
        Row(
          children: [
            const Expanded(child: SizedBox()),

            //product info
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  //Pulls image from variation 1's 1st image
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FutureBuilder(
                      future: FirebaseFirestore
                          .instance
                          .collection('/Products/$productId/Variations').get(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          String docID = snapshot.data!.docs.first.id;
                          return FutureBuilder(
                            future: FirebaseFirestore
                                .instance
                                .collection('/Products/$productId/Variations').doc(docID).get(),
                            builder: (context, imageSnapshot) {
                              if(imageSnapshot.hasData){
                                return CustomImage(
                                  imageSnapshot.data?['images'][0],
                                  radius: 10,
                                  width: 200,
                                  height: 210,//210
                                );
                              }
                              else if(imageSnapshot.connectionState == ConnectionState.waiting){
                                return const Center(
                                  child: LinearProgressIndicator(),
                                );
                              }
                              else{
                                return const Center(
                                  child: Text(
                                    "Nothings Found",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                        else if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: LinearProgressIndicator(),
                          );
                        }
                        else{
                          return const Center(
                            child: Text(
                              "Nothings Found",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  //title, price
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width*0.4,
                    child: FutureBuilder(
                      future: FirebaseFirestore
                          .instance
                          .collection('/Products')
                          .doc(productId)
                          .get(),
                      builder: (context, productSnapshot) {
                        if(productSnapshot.hasData){
                          String title = productSnapshot.data!.get('title') ?? '';
                          String price = productSnapshot.data!.get('price').toString();
                          return Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //title
                                Text(
                                  title,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      fontFamily: 'Urbanist',
                                      color: Colors.black
                                  ),
                                ),
                                //price
                                Text(
                                  'Price: $price',
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      fontFamily: 'Urbanist',
                                      color: Colors.black
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        else if(productSnapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: LinearProgressIndicator(),
                          );
                        }
                        else{
                          return const Center(
                            child: Text('Error Loading Data'),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15,),
          ],
        )
            :
        const SizedBox(),

        isMe ? Row(
          children: [
            //Store Icon
            Container(
              padding: const EdgeInsets.all(8.0),
              //margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: const Icon(
                Icons.store,
                color: Colors.grey,
                size: 16,
              ),
            ),

            //Text Container
            text.contains('http') ?
            //Image
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ImageViewerScreen(imageUrl: text,),)
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width*0.55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      text,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
                :
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15.0),
              ),
              width: MediaQuery.of(context).size.width*0.55,
              child: Text(
                text,
                style:TextStyle(
                    color:isMe?Colors.white:Colors.black,
                    fontWeight:FontWeight.bold,
                    fontFamily:'Urbanist',
                    overflow:TextOverflow.clip,
                    letterSpacing:0.3
                ),
              ),
            ),

            //Space from left
            const Expanded(child: SizedBox()),
          ],
        )
            :
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //Space from left
            const Expanded(child: SizedBox()),

            //Text/image Container
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //user name
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 10),
                  child: Text(
                    userName,
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey
                    ),
                  ),
                ),

                //message
                text.contains('http') ?
                    //Image
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ImageViewerScreen(imageUrl: text,),)
                    );
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.55,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        text,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                :
                    //text
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                  width: MediaQuery.of(context).size.width*0.55,
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                        overflow: TextOverflow.clip,
                        letterSpacing: 0.3
                    ),
                  ),
                ),
              ],
            ),

            //user image
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 8, bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  userPhoto,
                  height: 18,
                  width: 18,
                )
              ),
            )
          ],
        )
        ,
      ],
    );
  }
}
