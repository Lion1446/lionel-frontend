import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/add_product_dialog.dart';
import 'package:frontend/components/portal_card.dart';
import 'package:frontend/components/product_card.dart';
import 'package:frontend/screens/product_ingredients.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/fetching_data_dialog.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.stateData});

  final Map<String, dynamic> stateData;
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String storeImage;
  TextEditingController search = TextEditingController();
  List<Map<String, dynamic>>? products;
  List<Map<String, dynamic>> filteredProducts = [];

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
    fetchData();
    super.initState();
  }

  void filterProducts(String query) {
    setState(() {
      // Filter the list based on the query
      filteredProducts = products!
          .where((item) =>
              item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  fetchData() async {
    final result = await getProducts(widget.stateData["branch"]["id"]);
    products = List<Map<String, dynamic>>.from(result["products"]);
    if (!mounted) return;
    products!.sort((a, b) => a['name'].compareTo(b['name']) as int);
    if (products != null) {
      filteredProducts = products!;
    }
    setState(() {});
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
                child: PortalCard(portalName: "products")),
          ),
          Container(
            height: size.height - 150,
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                products == null
                    ? const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                    : products!.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Text(
                                "No products added yet.\nTap the + button to add a product.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                  color: grayText,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: Column(
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
                                    labelText: 'Search Product',
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: grayColor,
                                      ),
                                      onPressed: () {
                                        search.clear();
                                        if (products != null) {
                                          filteredProducts = products!;
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    // suffixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    filterProducts(value);
                                  },
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> product =
                                          filteredProducts[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                          left: 5,
                                          right: 5,
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const FetchingDataDialog();
                                              },
                                            );
                                            final res = await getProductDetail(
                                                product["id"]);
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context).pop();
                                            if (res["status"] == 200) {
                                              Map<String, dynamic> stateData =
                                                  {};
                                              stateData
                                                  .addAll(widget.stateData);
                                              stateData.addAll({
                                                "product_ingredients":
                                                    res["product_ingredients"],
                                                "product": product
                                              });
                                              // ignore: use_build_context_synchronously
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ProductIngredientsScreen(
                                                    stateData: stateData,
                                                    refreshProductNameCallback:
                                                        fetchData,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: ProductCard(
                                            product: product,
                                            refreshCallback: fetchData,
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          )),
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
                    final stateData = {
                      "auth_token": widget.stateData["auth_token"],
                      "branch_id": widget.stateData["branch"]["id"],
                    };
                    return AddProductDialog(
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

  Future<Map<String, dynamic>> getProducts(int branchID) async {
    String url = '$baseURL/products?branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<Map<String, dynamic>> getProductDetail(int productID) async {
    String url = '$baseURL/product_ingredients?product_id=$productID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }
}
