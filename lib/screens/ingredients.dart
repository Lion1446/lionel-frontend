import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/ingredient_card.dart';
import 'package:frontend/components/portal_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../components/add_ingredient_dialog.dart';
import '../components/edit_ingredient_dialog.dart';
import '../constants.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key, required this.stateData});

  final Map<String, dynamic> stateData;
  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  late String storeImage;
  List<Map<String, dynamic>>? ingredients;
  List<Map<String, dynamic>> filteredIngredients = [];
  TextEditingController search = TextEditingController();

  @override
  initState() {
    if (widget.stateData["branch"]["name"]
        .toString()
        .toLowerCase()
        .contains("ayame")) {
      storeImage = "assets/ayame-logo-small.png";
    } else {
      storeImage = "assets/myjoy-logo-small.png";
    }
    fetchData();
    super.initState();
  }

  fetchData() async {
    ingredients =
        await getIngredients(widget.stateData["branch"]["id"].toString());
    ingredients!.sort((a, b) => a['name'].compareTo(b['name']) as int);
    if (ingredients != null) {
      filteredIngredients = ingredients!;
    }
    setState(() {});
  }

  void refreshScaffold() {
    setState(() {
      // Set any state variables that need to be changed for the refresh
    });
  }

  void filterIngredients(String query) {
    setState(() {
      // Filter the list based on the query
      filteredIngredients = ingredients!
          .where((item) =>
              item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
            color: primaryColor,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: PortalCard(portalName: "ingredients")),
          ),
          Container(
            height: size.height - 150,
            padding: const EdgeInsets.only(left: 25, right: 25, top: 50),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image:
                                DecorationImage(image: AssetImage(storeImage)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.stateData["branch"]["name"],
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.stateData["user"]["fullname"],
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                  color: grayText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ingredients == null
                      ? const Center(child: CircularProgressIndicator())
                      : ingredients!.isEmpty
                          ? Center(
                              child: Text(
                                "No Ingredients added yet.\nTap the + button to add an ingredient.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                  color: grayText,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: TextField(
                                    controller: search,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: grayText,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Search Ingredient',
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: grayColor,
                                        ),
                                        onPressed: () {
                                          search.clear();
                                          if (ingredients != null) {
                                            filteredIngredients = ingredients!;
                                          }
                                          setState(() {});
                                        },
                                      ),
                                      // suffixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      filterIngredients(value);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: filteredIngredients.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> ingredient =
                                          filteredIngredients[index];
                                      // Use 'ingredient' to build each list item
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                          left: 5,
                                          right: 5,
                                        ),
                                        child: GestureDetector(
                                            onTap: () async {
                                              final res = await showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return EditIngredientDialog(
                                                    stateData: widget.stateData,
                                                    ingredientData: ingredient,
                                                  ); // Use the custom dialog widget
                                                },
                                              );
                                              if (res != null && res == true) {
                                                setState(() {
                                                  ingredients = null;
                                                  filteredIngredients = [];
                                                });
                                                fetchData();
                                              }
                                            },
                                            child: IngredientCard(
                                                refreshCallback: fetchData,
                                                ingredient: ingredient)),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 130,
            right: 55,
            child: GestureDetector(
              onTap: () async {
                final res = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AddIngredientDialog(
                      stateData: widget.stateData,
                    ); // Use the custom dialog widget
                  },
                );
                if (res != null && res == true) {
                  setState(() {
                    ingredients = null;
                    filteredIngredients = [];
                  });
                  fetchData();
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                    child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getIngredients(String branchID) async {
    String url = '$baseURL/ingredients';
    String modifiedUrl = Uri.parse(url)
        .replace(queryParameters: {'branch_id': branchID}).toString();
    final response = await http.get(Uri.parse(modifiedUrl));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    if (responseData["status"] == 200) {
      return List<Map<String, dynamic>>.from(responseData["ingredients"]);
    } else {
      return [];
    }
  }
}
