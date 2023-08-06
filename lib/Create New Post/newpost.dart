import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:stormymart_adminpanel/bottom_nav_bar.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController variantNameController = TextEditingController();
  TextEditingController keywordController = TextEditingController();

  int sizeSelected = -1;
  String randomID = '';

  List<dynamic> sizes = [];
  List<dynamic> keywords = [];

  bool isPosting = false;
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> images = [];
  List<String> imageLinks = [];
  List<String> savedVariantNames = [];
  List<List<XFile>> savedVariantImages = [];

  void generateRandomID() {
    Random random = Random();
    const String chars = "0123456789abcdefghijklmnopqrstuvwxyz";

    for (int i = 0; i < 20; i++) {
      randomID += chars[random.nextInt(chars.length)];
    }
  }

  Future<void> uploadInfo() async {
    await FirebaseFirestore.instance.collection('/Products').doc(randomID).set({
      'title': titleController.text,
      'price': double.parse(priceController.text),
      'discount': discountController.text.isNotEmpty ? double.parse(discountController.text) : 0.0,
      'description': descriptionController.text,
      'size': FieldValue.arrayUnion(sizes),
      'keywords': FieldValue.arrayUnion(keywords),
      'rating': 0.0,
      'sold': 0,
    });
  }

  Future<void> _uploadImages(int variantNumber) async {
    final messenger = ScaffoldMessenger.of(context);
    for (int i = 0; i < savedVariantImages[variantNumber].length; i++) {
      File compressedFile = await _compressImage(File(savedVariantImages[variantNumber][i].path));
      Reference ref = FirebaseStorage
          .instance
          .ref()
          .child('Product Photos/$randomID/${DateTime.now().millisecondsSinceEpoch}'); //DateTime.now().millisecondsSinceEpoch
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

  Future<void> postVariants() async {
    for(int index = 0; index < savedVariantNames.length; index++){

      await _uploadImages(index);

      await FirebaseFirestore
          .instance
          .collection('/Products')
          .doc(randomID)
          .collection('/Variations')
          .doc(savedVariantNames[index])
          .set({
        'images': FieldValue.arrayUnion(imageLinks)
      });

      imageLinks.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isPosting ? const Center(
        child: CircularProgressIndicator(),
      ) :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Space
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),

              //Top Row
              Row(
                children: [
                  //Arrow Button
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10, top: 7, bottom: 6),
                      child: Icon(
                        Icons.arrow_back,
                      ),
                    ),
                  ),

                  SizedBox(width: MediaQuery.of(context).size.width*0.23,),

                  const Text(
                    'Create Post',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 30,),

              const Text("Product Title *"),
              SizedBox(
                height: 70,
                child: TextField(
                  controller: titleController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      //borderSide: BorderSide.none,
                    ),
                    hintText: "Macbook pro . . . ",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.abc),
                    //labelText: "Semester",
                  ),
                ),
              ),

              const Text("Price *"),
              SizedBox(
                height: 70,
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    hintText: "1520/-",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.onetwothree),
                    //labelText: "Semester",
                  ),
                ),
              ),

              const Text("Discount"),
              SizedBox(
                height: 70,
                child: TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    hintText: "16%",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.onetwothree),
                    //labelText: "Semester",
                  ),
                ),
              ),

              const Text("Description"),
              SizedBox(
                height: 70,
                child: TextField(
                  controller: descriptionController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      //borderSide: BorderSide.none,
                    ),
                    hintText: "Product Details . . . ",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.abc),
                    //labelText: "Semester",
                  ),
                ),
              ),

              const Text("Add Sizes"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                    width: MediaQuery.of(context).size.width*0.66,
                    child: TextField(
                      controller: sizeController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          //borderSide: BorderSide.none,
                        ),
                        hintText: "XXL",
                        hintStyle: const TextStyle(
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(Icons.abc),
                        //labelText: "Semester",
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.32-30,
                    child: ElevatedButton(onPressed: () {
                      sizes.add(sizeController.text);

                      setState(() {
                        sizeController.clear();
                      });
                    },
                        child: const Text('Add Size')
                    ),
                  )
                ],
              ),

              //Show Sizes
              if(sizes.isEmpty)...[const SizedBox()]
              else...[
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: sizes.length,
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
                                          sizes.removeAt(index);
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
                          setState(() {
                            sizeSelected = index;
                          });
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)
                          ),//CircleBorder()
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                              child: Text(
                                sizes[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],

              //Add Keywords
              const Text("Add Keyword"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                    width: MediaQuery.of(context).size.width*0.66,
                    child: TextField(
                      controller: keywordController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          //borderSide: BorderSide.none,
                        ),
                        hintText: "Click add after each keyword",
                        hintStyle: const TextStyle(
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(Icons.abc),
                        //labelText: "Semester",
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.32-30,
                    child: ElevatedButton(onPressed: () {
                      keywords.add(keywordController.text);

                      setState(() {
                        keywordController.clear();
                      });
                    },
                        child: const Text('Add Keyword')
                    ),
                  )
                ],
              ),

              //Show Keywords
              if(keywords.isEmpty)...[const SizedBox()]
              else...[
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: keywords.length,
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
                                          keywords.removeAt(index);
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
                          setState(() {
                            sizeSelected = index;
                          });
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)
                          ),//CircleBorder()
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                              child: Text(
                                keywords[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],

              //Show Saved Variants
              ListView.builder(
                itemCount: savedVariantNames.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if(savedVariantNames.isNotEmpty){
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const BehindMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.redAccent.withAlpha(60),
                            icon: Icons.delete,
                            label: 'Delete',
                            autoClose: true,
                            borderRadius: BorderRadius.circular(15),
                            spacing: 5,
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.all(10),
                            onPressed: (context) async {
                              setState(() {
                                savedVariantNames.removeAt(index);
                                savedVariantImages.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "' ${savedVariantNames[index]} '",
                                style: const TextStyle(
                                    fontFamily: 'Urbanist'
                                ),
                              ),

                              const SizedBox(height: 5,),

                              //Show Picked Images
                              SizedBox(
                                height: 80,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  itemCount: savedVariantImages[index].length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, imageIndex) {
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
                                              File(savedVariantImages[index][imageIndex].path),
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
                        ),
                      ),
                    );
                  }
                  else if(savedVariantNames.isEmpty){
                    const SizedBox();
                  }
                  return null;
                },
              ),


              //Variant Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text("Variant Name"),
                      SizedBox(
                        height: 70,
                        child: TextField(
                          controller: variantNameController,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              //borderSide: BorderSide.none,
                            ),
                            hintText: "Slim Fit . . . ",
                            hintStyle: const TextStyle(
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(Icons.abc),
                            //labelText: "Semester",
                          ),
                        ),
                      ),

                      //Image Picker
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 100,
                            child: ElevatedButton(
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
                      //Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text('Save And Add more variant'),
                          onPressed: () async {
                            if(variantNameController.text == ''){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Input Variant Name'))
                              );
                            }else if(images.isEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Select at least one image'))
                              );
                            }
                            else{
                              setState(() {
                                savedVariantNames.add(variantNameController.text);
                                savedVariantImages.add(List.from(images));

                                variantNameController.clear();
                                images.clear();
                              });
                            }
                          },
                        ),
                      )
                    ],
                  ),
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
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    if(titleController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Title Missing')
                          )
                      );
                    }
                    else if(priceController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Price Missing')
                          )
                      );
                    }
                    else if(savedVariantNames.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Add at least one variant')
                          )
                      );
                    }
                    else{
                      setState(() {
                        isPosting = true;
                      });

                      generateRandomID();

                      await uploadInfo();

                      await postVariants();

                      setState(() {
                        isPosting = false;

                        navigator.push(
                          MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 0),)
                        );
                      });
                    }
                  },
                  child: const Text(
                    'Post',
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
