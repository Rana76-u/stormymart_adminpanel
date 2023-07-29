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
                    hintText: "ex: +880... ",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.onetwothree),
                    //labelText: "Semester",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
