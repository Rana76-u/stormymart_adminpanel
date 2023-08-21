import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EditBanner extends StatefulWidget {
  const EditBanner({super.key});

  @override
  State<EditBanner> createState() => _EditBannerState();
}

class _EditBannerState extends State<EditBanner> {

  List<dynamic> banners = [];
  bool isLoading = false;
  TextEditingController addingController = TextEditingController();

  @override
  void initState() {
    isLoading = true;
    loadInfo();
    super.initState();
  }

  Future<void> loadInfo() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('/Banners').get();

    final docs = snapshot.docs;

    for(int i=0; i<docs.length; i++){
      banners.add(snapshot.docs[i].get('image'));
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) : SingleChildScrollView(
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

              //List of Banners
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: banners.length,
                itemBuilder: (context, index) {

                  /*String title = snapshot.data!.data()!.keys.elementAt(index);
                        categories.add(title);

                        subCategories.add(snapshot.data!.get(title));*/

                  return Column(
                    children: [
                      Slidable(
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
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
                                  banners.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),

                        //Image Links
                        child: TextField(
                          onSubmitted: (value) {
                            if(value.isNotEmpty){
                              setState(() {
                                banners.removeAt(index);
                                banners.insert(index, value);
                              });
                            }
                          },
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: banners[index],
                              prefixIcon: const Icon(Icons.edit),
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF212121),
                              ),
                              enabled: true
                          ),
                        ),
                      ),


                    ],
                  );
                },
              ),

              const Divider(),

              //Add More Categories
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                      shape: const RoundedRectangleBorder( // <-- SEE HERE
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(22.0),
                        ),
                      ),
                      context: context,
                      builder: (BuildContext context){
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.55, //420
                            child: Column(
                              children: [
                                const SizedBox(height: 25,),
                                const Text(
                                  'Add Image Links',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Urbanist'
                                  ),
                                ),

                                TextField(
                                  controller: addingController,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                      //border: InputBorder.none,
                                      //focusedBorder: InputBorder.none,
                                      //enabledBorder: InputBorder.none,
                                      hintText: 'Type/Paste Image Link Here',
                                      prefixIcon: Icon(Icons.edit),
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      labelStyle: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF212121),
                                      ),
                                      enabled: true
                                  ),
                                ),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        if(addingController.text.isNotEmpty){
                                          banners.add(addingController.text);
                                          addingController.clear();
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Text('Add')
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  );
                },
                child: const Text('+ Add More Banners'),
              ),

              const SizedBox(height: 50,),

              //Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      // Delete all existing documents in the 'Banners' collection
                      QuerySnapshot existingBanners = await FirebaseFirestore.instance.collection('Banners').get();
                      for (DocumentSnapshot document in existingBanners.docs) {
                        await document.reference.delete();
                      }

                      for(int i=0; i<banners.length; i++){
                        await FirebaseFirestore.instance
                            .collection('/Banners')
                            .doc()
                            .set({
                          'image': banners[i],
                          'description' : ''
                        });
                      }

                    } catch (error) {
                      print('Error uploading data: $error');
                    }


                    setState(() {
                      isLoading = false;
                    });

                  },
                  child: const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
