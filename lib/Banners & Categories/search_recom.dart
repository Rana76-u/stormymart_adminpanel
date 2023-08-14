import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EditSearchRecommendation extends StatefulWidget {
  const EditSearchRecommendation({super.key});

  @override
  State<EditSearchRecommendation> createState() => _EditSearchRecommendationState();
}

class _EditSearchRecommendationState extends State<EditSearchRecommendation> {

  List<List<dynamic>> subCategories = [];
  bool isLoading = false;
  TextEditingController addingController = TextEditingController();

  @override
  void initState() {
    isLoading = true;
    loadInfo();
    super.initState();
  }

  Future<void> loadInfo() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('/Category').doc('/Search Recommandation').get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // Iterate through each key (category)
    data.forEach((category, subcategories) {
      List<dynamic> subCategoryList = List.from(subcategories);
      subCategories.add(subCategoryList);
    });


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
                'Search Recommendations',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                ),
              ),

              const Text(
                'Swipe to Delete / Edit',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13
                ),
              ),

              //List of Categories
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subCategories.length,
                itemBuilder: (context, index) {

                  /*String title = snapshot.data!.data()!.keys.elementAt(index);
                        categories.add(title);

                        subCategories.add(snapshot.data!.get(title));*/

                  return Column(
                    children: [
                      //Whole Category
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
                                  for(int i=0;i<subCategories[index].length; i++){
                                    subCategories[index].removeAt(i);
                                  }
                                  subCategories.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),

                        //Category Names
                        child: ExpansionTile(
                          iconColor: Colors.amber,
                          textColor: Colors.amber,
                          title: TextField(
                            onSubmitted: (value) {
                              if(value.isNotEmpty){
                                setState(() {
                                  subCategories[index].removeAt(0);
                                  subCategories[index].insert(0, value);
                                });
                              }
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText: subCategories[index][0],
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
                          childrenPadding: const EdgeInsets.only(left: 60),

                          //Subcategories
                          children: List.generate( 1, (subIndex) {
                              return TextField(
                                onSubmitted: (value) {
                                  if(value.isNotEmpty){
                                    setState(() {
                                      subCategories[index].removeAt(1);
                                      subCategories[index].insert(1, value);
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    hintText: subCategories[index][1],
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
                              );
                            },
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
                                  'Add Category',
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
                                      hintText: 'Type Recommendation Here',
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
                                          subCategories.add([addingController.text,'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARkAAACzCAMAAACKPpgZAAAAA1BMVEX///+nxBvIAAAASElEQVR4nO3BAQ0AAADCoPdPbQ43oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAPA8UuAAHBsLyLAAAAAElFTkSuQmCC']);
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
                child: const Text('+ Add More Search Recommendation'),
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

                    Map<String, List<dynamic>> dataMap = {};

                    for (int i = 0; i < subCategories.length; i++) {
                      dataMap[i.toString()] = subCategories[i];
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('/Category')
                          .doc('/Search Recommandation')
                          .set(dataMap);

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
