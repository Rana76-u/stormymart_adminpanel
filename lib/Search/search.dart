import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../Components/custom_image.dart';
import '../Product Screen/product_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final double _minRating = 0;
  final double _maxRating = 5;
  double _selectedMinRating = 0.0;
  double _selectedMaxRating = 0.0;


  final double _minPrice = 0;
  final double _maxPrice = 1000000;
  double _selectedMinPrice = 0.0;
  double _selectedMaxPrice = 0.0;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Create a text controller and reference it
  final TextEditingController _searchController = TextEditingController();
  String searchedText = '';

  // A list to hold the search results
  List<DocumentSnapshot> _searchResults = [];

  // A flag to determine if the search has completed
  bool _isSearching = false;
  bool isTyping = false;
  bool isFilterOpen = false;

  void performSearch(String searchItem, {double? minPrice, double? maxPrice, double? minRating}) async {
    // Get a reference to the products collection
    var ref = FirebaseFirestore.instance.collection('/Products');
    // Convert the search query to uppercase
    searchItem = searchItem.toUpperCase();
    // Build a query for title filtering
    var titleQuery = ref.where('title', isGreaterThanOrEqualTo: searchItem);

    var titleSnapshot = await titleQuery.get();
    var titleDocs = titleSnapshot.docs;

    // Apply price and rating filtering on the title filtered documents
    var filteredDocs = titleDocs.where((doc) {
      var data = doc.data();
      var price = data['price'].toDouble();
      var rating = data['rating'].toDouble();
      return (minPrice == null || price >= minPrice) &&
          (maxPrice == null || price <= maxPrice) &&
          (minRating == null || rating >= minRating) &&
          data['Shop ID'] == FirebaseAuth.instance.currentUser!.uid;
    }).toList();

    // Update the search results
    setState(() {
      _searchResults = filteredDocs;
      _isSearching = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Space From Top
            SizedBox(
              height: MediaQuery.of(context).size.height*0.04,
            ),
            //Page title
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Search Your Store",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist'
                ),
              ),
            ),

            // A text field for the user to enter their search query
            Card(
              elevation: 6,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.9 - 24,
                    child: TextField(
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                            fontFamily: 'Urbanist'
                        ),
                        prefixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).unfocus();
                                _searchController.clear();
                                isTyping = false;
                                isFilterOpen = false;
                              });
                            },
                            child: const Icon(Icons.arrow_back_rounded)
                        ),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              if(_searchController.text != ''){
                                setState(() {
                                  _isSearching = true;
                                  performSearch(_searchController.text);
                                  isTyping = false;
                                });
                              }
                            },
                            child: const Icon(
                              Icons.search_rounded,
                            )
                        ),
                      ),
                      controller: _searchController,
                      onChanged: (value) {
                        // Start the search when the user enters a value in the text field
                        setState(() {
                          isTyping = true;
                          searchedText = _searchController.text;
                          isFilterOpen = false;
                          _selectedMinPrice = 0;
                          _selectedMaxPrice = 1000000;
                          _selectedMinRating = 0;
                          _selectedMaxRating = 5;
                        });
                        // Perform the search
                        performSearch(value);
                      },
                      onSubmitted: (value) {
                        setState(() {
                          _isSearching = true;
                          performSearch(value);
                          isTyping = false;
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFilterOpen = true;
                      });
                    },
                    child: Icon(
                        Icons.filter_alt_outlined,
                      color: _focusNode.hasFocus ? Colors.blue : Colors.grey ,
                    ),
                  )
                ],
              ),
            ),
            // A loading indicator while the search is in progress
            _isSearching ? const LinearProgressIndicator()
                : const SizedBox(
              height: 0,
              width: 0,
            ),

            //Filter
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isFilterOpen ?
              Row(
                children: [
                  //Rating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 18),
                          child: Text(
                              'Rating',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist'
                            ),
                          )
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.45,
                        child: RangeSlider(
                          values: RangeValues(_selectedMinRating, _selectedMaxRating),
                          min: _minRating,
                          max: _maxRating,
                          divisions: 5,
                          labels: RangeLabels(
                            _selectedMinRating.toString(),
                            _selectedMaxRating.toString(),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _selectedMinRating = values.start;
                              _selectedMaxRating = values.end;
                              performSearch(
                                  searchedText,
                                  minRating: _selectedMaxRating,
                                  minPrice: _selectedMinPrice,
                                  maxPrice: _selectedMaxPrice
                              );
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  //Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(top: 10, left: 18),
                          child: Text(
                            'Price',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Urbanist'
                            ),
                          )
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.45,
                        child: RangeSlider(
                          values: RangeValues(_selectedMinPrice, _selectedMaxPrice),
                          min: _minPrice,
                          max: _maxPrice,
                          divisions: 100,
                          labels: RangeLabels(
                            _selectedMinPrice.toString(),
                            _selectedMaxPrice.toString(),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _selectedMinPrice = values.start;
                              _selectedMaxPrice = values.end;
                              performSearch(
                                  searchedText,
                                  minRating: _selectedMaxRating,
                                  minPrice: _selectedMinPrice,
                                  maxPrice: _selectedMaxPrice
                              );
                            });
                          },
                        ),
                      )
                    ],
                  )
                ],
              ) : const SizedBox(),
            ),

            if(isTyping == false)...[
              // The search results are displayed in a list view
              Expanded(
                child: GridView.builder(
                  itemCount: _searchResults.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    // Get the document snapshot for the current item
                    var result = _searchResults[index];

                    double discountCal = (result.get('price') / 100) * (100 - result.get('discount'));

                    // Display a card for the result
                    return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => ProductScreen(productId: result.id))
                            );
                          },
                          child: SizedBox(
                            //width: 200,
                            width: MediaQuery.of(context).size.width*0.48,
                            height: 300,
                            child: Stack(
                              children: [
                                //Pulls image from variation 1's 1st image
                                FutureBuilder(
                                  future: FirebaseFirestore
                                      .instance
                                      .collection('/Products/${result.id}/Variations').get(),
                                  builder: (context, snapshot) {
                                    if(snapshot.hasData){
                                      String docID = snapshot.data!.docs.first.id;
                                      return FutureBuilder(
                                        future: result.reference.collection('/Variations').doc(docID).get(),
                                        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                          if(snapshot.hasData){
                                            return CustomImage(
                                              snapshot.data?['images'][0],
                                              radius: 10,
                                              width: 200,
                                              height: 210,//210
                                            );
                                          }else if(snapshot.connectionState == ConnectionState.waiting){
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

                                //Discount %Off
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade800,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding:   const EdgeInsets.all(7),
                                      child: Text(
                                        'Discount: ${result.get('discount')}%',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                //Title
                                Positioned(
                                  top: 220,
                                  left: 5,
                                  child: Text(
                                    result.get('title'),
                                    style: const TextStyle(
                                        overflow: TextOverflow.clip,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.black45//darker
                                    ),
                                  ),
                                ),

                                //price
                                Positioned(
                                    top: 240,
                                    left: 5,
                                    child: Row(
                                      children: [
                                        /*SvgPicture.asset(
                                        "assets/icons/taka.svg",
                                        width: 17,
                                        height: 17,
                                      ),*/
                                        Text(
                                          "Tk ${discountCal.toStringAsFixed(2)}/-",
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              color: textColor
                                          ),
                                        ),
                                      ],
                                    )
                                ),

                                //Row
                                Positioned(
                                  top: 260,
                                  left: 2,
                                  child:  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 3,),
                                      //Rating
                                      Text(
                                        result.get('rating').toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.grey.shade400//darker
                                        ),
                                      ),
                                      const SizedBox(width: 20,),
                                      //Sold
                                      Text(
                                        "${result.get('sold').toString()} Sold",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.grey.shade400//darker
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                    );
                  },
                ),
              ),
            ]else...[
              // The search suggestions are displayed in a list view
              Expanded(
                child: FutureBuilder(
                    future: FirebaseFirestore
                        .instance
                        .collection('/Products').get(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        return Card(
                          child: ListView.separated(
                            itemCount: _searchResults.length, // _searchResults.length
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: GestureDetector(
                                  onTap: () {
                                    _isSearching = true;
                                    performSearch(_searchResults[index].get('title'));
                                    isTyping = false;
                                    _searchController.clear();
                                  },
                                  child: Text(
                                    _searchResults[index].get('title'),
                                    maxLines: 1,
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Urbanist'
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return const Divider();
                            },
                          ),
                        );
                      }else if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(
                          child: LinearProgressIndicator(),
                        );
                      }else{
                        return const Center(
                          child: Text('Error Loading Data'),
                        );
                      }
                    }
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
