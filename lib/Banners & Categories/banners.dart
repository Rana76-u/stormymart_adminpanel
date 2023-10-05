import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';

class EditBanner extends StatefulWidget {
  const EditBanner({super.key});

  @override
  State<EditBanner> createState() => _EditBannerState();
}

class _EditBannerState extends State<EditBanner> {

  String randomID = '';
  bool isLoading = false;
  XFile? image;
  String imageLink = '';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
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
        .child('Banners/$randomID'); //DateTime.now().millisecondsSinceEpoch
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
      return File('${file.path}_compressed.jpg')..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 80));
    }
    else {
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
      body: isLoading ?
      const Center(
        child: CircularProgressIndicator(),
      )
          :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              //Space
              SizedBox(height: MediaQuery.of(context).size.height*0.065,),

              //Top Text
              const Text(
                'Banners',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                ),
              ),
              const Text(
                'Swipe to Delete',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13
                ),
              ),

              //Space
              const SizedBox(height: 5,),

              //Upload image
              GestureDetector(
                onTap: () {
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
                          // The "Gallery" button
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
                          // The "Cancel" button
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
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,//150, 0.38
                  height: 181,
                  child: Stack(
                    children: [
                      //Image
                      if(image != null)...[
                        Positioned(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                File(image!.path),
                                fit: BoxFit.cover,
                              )
                          ),
                        ),
                      ]
                      else...[
                        const SizedBox()
                      ],

                      //black overlay
                      Positioned(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              height: 181,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.black.withOpacity(0.3),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 83),
                                child: Text(
                                  'Click to Upload Image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {

                    if(image != null){
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        await _uploadImages();

                        await FirebaseFirestore
                            .instance
                            .collection('/Banners')
                            .doc().set({
                          'image': imageLink,
                        });

                      } catch (error) {
                        print('Error uploading data: $error');
                      }


                      setState(() {
                        isLoading = false;
                        image = null;
                        imageLink = '';
                        randomID = '';
                      });
                    }

                  },
                  child: const Text('Upload'),
                ),
              ),

              const Divider(),

              //List of Banners
              FutureBuilder(
                future: FirebaseFirestore.instance.collection('/Banners').get(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Slidable(
                                endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  children: [
                                    const SizedBox(width: 5,),
                                    //Delete
                                    SlidableAction(
                                      backgroundColor: Colors.redAccent.withAlpha(60),
                                      icon: Icons.delete,
                                      label: 'Delete',
                                      autoClose: true,
                                      borderRadius: BorderRadius.circular(15),
                                      spacing: 5,
                                      foregroundColor: Colors.redAccent,
                                      onPressed: (context) async {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        await deleteImage(snapshot.data!.docs[index].get('image'));

                                        await FirebaseFirestore
                                            .instance
                                            .collection('/Banners')
                                            .doc(snapshot.data!.docs[index].id)
                                            .delete();

                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                //Image Links
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    snapshot.data!.docs[index].get('image'),
                                    fit: BoxFit.cover,
                                    height: 170,
                                    width: double.infinity,
                                  ),
                                )
                            ),

                            const SizedBox(height: 5,)
                          ],
                        );
                      },
                    );
                  }
                  else if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width*0.4,
                        child: const LinearProgressIndicator(),
                      ),
                    );
                  }
                  else {
                    return const Center(
                      child: Text(
                        'Error Loading Data'
                      )
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
