import 'package:flutter/material.dart';

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

  int sizeSelected = -1;

  List<dynamic> sizes = [];

  Color _cardColor(int i) {
    if (sizeSelected == i) {
      return Colors.green;
    }
    else {
      return Colors.white;
    }
  }

  void addToSizeWidget() {


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  keyboardType: TextInputType.number,
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
                  keyboardType: TextInputType.number,
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
                      keyboardType: TextInputType.number,
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
                        color: _cardColor(index),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)
                        ),//CircleBorder()
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                            child: Text(
                              sizes[index],
                              style: TextStyle(
                                color: sizeSelected == index
                                    ? Colors.white
                                    : Colors.black,
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
          ),
        ),
      ),
    );
  }
}
