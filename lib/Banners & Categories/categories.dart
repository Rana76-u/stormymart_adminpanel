import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EditCategories extends StatefulWidget {
  const EditCategories({super.key});

  @override
  State<EditCategories> createState() => _EditCategoriesState();
}

class _EditCategoriesState extends State<EditCategories> {

  List<dynamic> categories = [];
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
    await FirebaseFirestore.instance.collection('/Category').doc('/Drawer').get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // Convert map keys to a list of categories
    List<String> categoryList = data.keys.toList();
    categories.addAll(categoryList);

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
                'Categories',
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

              //List of Categories
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
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
                                  categories.removeAt(index);
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
                                  categories.removeAt(index);
                                  categories.insert(index, value);
                                });
                              }
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText: categories[index],
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
                          children: List.generate(
                            subCategories[index].length,
                                (subIndex) {
                              return Slidable(
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
                                          subCategories[index].removeAt(subIndex);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  onSubmitted: (value) {
                                    if(value.isNotEmpty){
                                      setState(() {
                                        subCategories[index].removeAt(subIndex);
                                        subCategories[index].insert(subIndex, value);
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: subCategories[index][subIndex],
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
                              );
                            },
                          ),
                        ),
                      ),

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
                                      Text(
                                          'Add Subcategory to "${categories[index]}"',
                                        style: const TextStyle(
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
                                            hintText: 'Type Subcategory Here',
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
                                              setState(() {
                                                Navigator.of(context).pop();
                                                subCategories[index].add(addingController.text);
                                                addingController.clear();
                                              });
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
                        child: Text('+ Add More into "${categories[index]}"'),
                      )
                    ],
                  );
                },
              ),

              const Divider(),

              //Add Categories
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
                                      hintText: 'Type Category Here',
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
                                          categories.add(addingController.text);
                                          subCategories.add(['item']);
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
                child: const Text('+ Add More Categories'),
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

                    for (int i = 0; i < categories.length; i++) {
                      dataMap[categories[i]] = subCategories[i];
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('/Category')
                          .doc('/Drawer')
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
