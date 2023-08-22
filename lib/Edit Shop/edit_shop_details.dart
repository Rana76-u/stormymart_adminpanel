import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../bottom_nav_bar.dart';

class EditShopDetails extends StatefulWidget {
  const EditShopDetails({super.key});

  @override
  State<EditShopDetails> createState() => _EditShopDetailsState();
}

class _EditShopDetailsState extends State<EditShopDetails> {
  bool isPosting = false;

  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> images = [];
  List<String> imageLinks = [];
  List<dynamic> existingImages = [];
  List<dynamic> removeExistingImages = [];

  List<XFile> logo = [];
  String logoUrl = '';

  String currentShopLogo = '';
  TextEditingController shopNameController = TextEditingController();
  TextEditingController shopLogoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phnController = TextEditingController();

  @override
  void initState() {
    isPosting = true;
    getInfo();
    super.initState();
  }

  void getInfo() async {
    DocumentSnapshot snapshot =
    await FirebaseFirestore
        .instance
        .collection('/Admin Panel')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    shopNameController.text = snapshot.get('Shop Name');
    emailController.text = snapshot.get('Email');
    phnController.text = snapshot.get('Phone Number').toString();
    currentShopLogo = snapshot.get('Shop Logo');
    existingImages.addAll(snapshot.get('Banners'));
    
    setState(() {
      isPosting = false;
    });
  }

  Future<void> uploadInfo() async {
    await _uploadImages();

    await FirebaseFirestore
        .instance
        .collection('/Admin Panel')
        .doc(FirebaseAuth.instance.currentUser!.uid).update({
      'Shop Name': shopNameController.text,
      'Email': emailController.text,
      'Phone Number': phnController.text,
    });

    if(logoUrl.isNotEmpty){
      await FirebaseFirestore
          .instance
          .collection('/Admin Panel')
          .doc(FirebaseAuth.instance.currentUser!.uid).update({
        'Shop Logo': logoUrl,
      });
    }

    if(removeExistingImages.isNotEmpty){
      //Removes from Database
      await FirebaseFirestore
          .instance
          .collection('/Admin Panel')
          .doc(FirebaseAuth.instance.currentUser!.uid).update({
        'Banners': FieldValue.arrayRemove(removeExistingImages),
      });
      //Removes from Storage
      for(int i=0;i<removeExistingImages.length; i++){
        try {
          // Create a Firebase Storage reference from the image URL
          Reference storageReference = FirebaseStorage.instance.refFromURL(removeExistingImages[i]);

          // Delete the image
          await storageReference.delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
    }

    if(imageLinks.isNotEmpty){
      await FirebaseFirestore
          .instance
          .collection('/Admin Panel')
          .doc(FirebaseAuth.instance.currentUser!.uid).update({
        'Banners': FieldValue.arrayUnion(imageLinks),
      });
    }
  }

  Future<void> _uploadImages() async {
    final messenger = ScaffoldMessenger.of(context);

    //Upload Banner
    for (int i = 0; i < images.length; i++) {
      File compressedFile = await _compressImage(File(images[i].path));
      Reference ref = FirebaseStorage
          .instance
          .ref()
          .child('Shop Media/${FirebaseAuth.instance.currentUser!.uid}/Banner/${DateTime.now().millisecondsSinceEpoch}'); //DateTime.now().millisecondsSinceEpoch
      UploadTask uploadTask = ref.putFile(compressedFile);
      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        String downloadURL = await snapshot.ref.getDownloadURL();
        imageLinks.add(downloadURL);
      } else {
        messenger.showSnackBar(SnackBar(content: Text('An Error Occurred\n${snapshot.state}')));
        return;
      }
    }

    //Upload Logo
    if(logo.isNotEmpty){
      File compressedFile = await _compressImage(File(logo[0].path));
      Reference ref = FirebaseStorage
          .instance
          .ref()
          .child('Shop Media/${FirebaseAuth.instance.currentUser!.uid}/Logo/${DateTime.now().millisecondsSinceEpoch}'); //DateTime.now().millisecondsSinceEpoch
      UploadTask uploadTask = ref.putFile(compressedFile);
      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        String downloadURL = await snapshot.ref.getDownloadURL();
        logoUrl = downloadURL.toString();

        //Delete the Previous logo
        await deleteImage(currentShopLogo);
      } else {
        messenger.showSnackBar(SnackBar(content: Text('An Error Occurred\n${snapshot.state}')));
        return;
      }
    }
  }

  Future<File> _compressImage(File file) async {
    img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image != null) {
      img.Image compressedImage = img.copyResize(image, width: 1024);
      return File('${file.path}_compressed.jpg')..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 50));
    } else {
      return file;
    }
  }



  Future<void> deleteImage(String imageUrl) async {
    try {
      // Create a Firebase Storage reference from the image URL
      Reference storageReference = FirebaseStorage.instance.refFromURL(imageUrl);

      // Delete the image
      await storageReference.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isPosting ? const Center(
        child: CircularProgressIndicator(),
      )
          :
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50,),
              //Top Text
                const Center(
                child: Text(
                  'Edit Shop Details',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                  ),
                ),
              ),

                buildText('Shop Name'),
                TextFormField(
                controller: shopNameController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.store,
                    color: Colors.green,
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                  labelText: "Enter your Shop Name",
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                cursorColor: Colors.green,
              ),

                buildText('Email'),
                TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.green,
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                  labelText: "Enter Email For Your Shop",
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                cursorColor: Colors.green,
              ),

                buildText('Phone Number'),
                TextFormField(
                controller: phnController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: Colors.green,
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                  labelText: "Enter Phone Number For Your Shop",
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                cursorColor: Colors.green,
              ),

                buildText('Shop Logo'),
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Pick
                  SizedBox(
                    height: 80,
                    width: 100,
                    child: TextButton(
                      onPressed: () async {

                        List<XFile> tempSelected = await _imagePicker.pickMultiImage();

                        logo.insert(0, tempSelected[0]);

                        setState(() {});
                      },
                      child: const Text(
                        'Pick\nLogo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),

                  //space
                  const SizedBox(width: 10,),

                  //Show Picked Logo
                  if(logo.isNotEmpty)...[
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: 100,//200
                          height: 100,//136.5

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(logo[0].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                  else...[
                    const SizedBox()
                  ]
                ],
              ),

                buildText('Banners'),
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Pick
                  SizedBox(
                    height: 80,
                    width: 100,
                    child: TextButton(
                      onPressed: () async {
                        //final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
                        List<XFile> tempSelected = await _imagePicker.pickMultiImage();

                        for(int i=0; i<tempSelected.length; i++){
                          images.add(tempSelected[i]);
                        }
                        setState(() {});
                      },
                      child: const Text(
                        'Pick\nImage',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),

                  //space
                  const SizedBox(width: 10,),

                  //Show Picked Images
                  SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width - 165,
                    child: ListView.builder(
                      itemCount: images.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return  AlertDialog(
                                  title: const Text('Please Confirm'),
                                  content: const Text('Are you sure you want to delete this item?'),
                                  actions: [
                                    // The "Yes" button
                                    TextButton(
                                        onPressed: () {
                                          // Remove the box
                                          setState(() {
                                            images.removeAt(index);
                                          });

                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Yes')),
                                    TextButton(
                                        onPressed: () {
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'))
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: SizedBox(
                              width: 100,//200
                              height: 100,//136.5

                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(images[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

                const SizedBox(height: 10,),

                //Show Existing Images
                SizedBox(
                height: 80,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: existingImages.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return  AlertDialog(
                              title: const Text('Please Confirm'),
                              content: const Text('Are you sure you want to delete this item?'),
                              actions: [
                                // The "Yes" button
                                TextButton(
                                    onPressed: () {
                                      // Remove the box
                                      setState(() {
                                        removeExistingImages.add(existingImages[index]);
                                        existingImages.removeAt(index);
                                      });

                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Yes')),
                                TextButton(
                                    onPressed: () {
                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('No'))
                              ],
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          width: 100,//200
                          height: 100,//136.5

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              existingImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

                //Space
                const SizedBox(
                height: 20,
              ),

                //Post Button
                SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    if(shopNameController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Shop Name Missing')
                          )
                      );
                    }
                    else if(emailController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Email Missing')
                          )
                      );
                    }
                    else if(phnController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Phone Number Missing')
                          )
                      );
                    }
                    else{
                      setState(() {
                        isPosting = true;
                      });

                      await uploadInfo();

                      setState(() {
                        isPosting = false;

                        navigator.push(
                            MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 0),)
                        );
                      });
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              //Space
              const SizedBox(
                height: 200,
              )
            ],
          ),
        ),
      ),
    );
  }
}


Widget buildText(String text) => Padding(
  padding: const EdgeInsets.only(top: 20, bottom: 5),
  child:   Text(
      text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontFamily: 'Urbanist'
    ),
  ),
);