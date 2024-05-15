import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/edit_product_ingredient_dialog.dart';
import 'package:frontend/components/edit_product_ingredient_name_dialog.dart';
import 'package:frontend/components/product_ingredient_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../components/add_product_ingredient_dialog.dart';
import '../constants.dart';

class ProductIngredientsScreen extends StatefulWidget {
  const ProductIngredientsScreen(
      {super.key,
      required this.stateData,
      required this.refreshProductNameCallback});

  final Map<String, dynamic> stateData;
  final Function refreshProductNameCallback;
  @override
  State<ProductIngredientsScreen> createState() =>
      _ProductIngredientsScreenState();
}

class _ProductIngredientsScreenState extends State<ProductIngredientsScreen> {
  late String storeImage;
  late String name;
  late double price;
  late String category;

  List<Map<String, dynamic>>? productIngredients;

  @override
  void initState() {
    if (widget.stateData["branch"]["name"]
        .toString()
        .toLowerCase()
        .contains("ayame")) {
      storeImage = "assets/ayame-logo-small.png";
    } else {
      storeImage = "assets/myjoy-logo-small.png";
    }
    productIngredients = List<Map<String, dynamic>>.from(
        widget.stateData["product_ingredients"]);
    name = widget.stateData['product']['name'];
    price = widget.stateData['product']['price'];
    category = widget.stateData['product']['category'];
    super.initState();
  }

  fetchData() async {
    final result = await getProductDetail(widget.stateData["product"]["id"]);
    if (result["status"] == 200) {
      productIngredients =
          List<Map<String, dynamic>>.from(result["product_ingredients"]);
      widget.refreshProductNameCallback();
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            padding: const EdgeInsets.only(left: 30, right: 30, top: 50),
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
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back),
                        const SizedBox(width: 5),
                        Text(
                          'Back',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            Map<String, dynamic> stateData = {
                              "name": name,
                              "price": price,
                              "category": category,
                              "id": widget.stateData['product']['id'],
                              "auth_token": widget.stateData["auth_token"],
                              "branch_id": widget.stateData["branch"]["id"]
                            };
                            final res = await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return EditProductIngredientNameDialog(
                                    stateData:
                                        stateData); // Use the custom dialog widget
                              },
                            );
                            if (res != null) {
                              name = res["name"];
                              price = res["price"];
                              category = res["category"];
                              fetchData();
                            }
                          },
                          child: const Icon(
                            Icons.edit,
                            color: grayColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: productIngredients!.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> productIngredient =
                              productIngredients![index];
                          productIngredient["auth_token"] =
                              widget.stateData["auth_token"];
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
                                  builder: (BuildContext context) {
                                    return EditProductIngredientDialog(
                                      stateData: productIngredient,
                                    ); // Use the custom dialog widget
                                  },
                                );
                                if (res != null && res == true) {
                                  fetchData();
                                }
                              },
                              child: ProductIngredientCard(
                                  item: productIngredient,
                                  refreshCallback: fetchData,
                                  isEditable: true),
                            ),
                          );
                        }))
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            right: 55,
            child: GestureDetector(
              onTap: () async {
                final res = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    final stateData = {
                      "auth_token": widget.stateData["auth_token"],
                      "product_id": widget.stateData["product"]["id"],
                      "ingredients": widget.stateData["ingredients"]
                    };
                    return AddProductIngredientDialog(
                      stateData: stateData,
                    ); // Use the custom dialog widget
                  },
                );
                if (res != null && res == true) {
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

  Future<Map<String, dynamic>> getProductDetail(int productID) async {
    String url = '$baseURL/product_ingredients?product_id=$productID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }
}
