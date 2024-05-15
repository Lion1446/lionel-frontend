import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'add_category_dialog.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key, required this.stateData});
  final Map<String, dynamic> stateData;
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  String message = "";
  bool isValid = false;
  bool isCreating = false;
  String? category;
  Map<String, dynamic>? categories;

  @override
  void initState() {
    name.addListener(() {
      setState(() {
        isValid = name.text.isNotEmpty && price.text.isNotEmpty;
      });
    });
    price.addListener(() {
      setState(() {
        isValid = name.text.isNotEmpty && price.text.isNotEmpty;
      });
    });
    fetchData();
    super.initState();
  }

  fetchData() async {
    categories = await getCategories(widget.stateData["branch_id"]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: categories == null
          ? Container(
              height: 200,
              width: 100,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator()),
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      'Fetching Data',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add New Product",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product Name",
                            style: GoogleFonts.montserrat(
                              color: grayText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: name,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: grayText,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Category",
                            style: GoogleFonts.montserrat(
                              color: grayText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            items: categories!.keys.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: grayText,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.3)),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  final res = await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AddCategoryDialog(
                                          stateData: widget.stateData);
                                    },
                                  );
                                  if (res) {
                                    fetchData();
                                  }
                                },
                              ),
                            ),
                            onChanged: (String? value) {
                              setState(() {
                                category = value;
                                validate();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Price",
                            style: GoogleFonts.montserrat(
                              color: grayText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: price,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: grayText,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: errorColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Container(
                            width: 120,
                            height: 45,
                            decoration: BoxDecoration(
                                color: grayColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: isValid
                              ? () async {
                                  setState(() {
                                    isCreating = true;
                                    message = "";
                                  });
                                  // Create Inventory --> starting
                                  final response = await createProduct(
                                    widget.stateData["branch_id"],
                                    widget.stateData["auth_token"],
                                    name.text.trim(),
                                    double.tryParse(price.text) ?? 0,
                                    categories![category],
                                  );
                                  if (response["status"] == 200) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop(true);
                                  } else {
                                    message = "Error adding item.";
                                    isCreating = false;
                                    setState(() {});
                                  }
                                }
                              : null,
                          child: Container(
                            width: 120,
                            height: 45,
                            decoration: BoxDecoration(
                                color: isValid ? primaryColor : grayColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: isCreating
                                  ? const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
                                      'Save',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: isValid
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<Map<String, dynamic>> createProduct(int branchID, String token,
      String name, double price, int categoryID) async {
    String url = '$baseURL/products';
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "branch_id": widget.stateData["branch_id"],
          "category_id": categoryID,
          "name": name,
          "price": price
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    log(decoded.toString());
    return decoded;
  }

  Future<Map<String, dynamic>?> getCategories(int branchID) async {
    String url = '$baseURL/category?branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    if (responseData["status"] == 200) {
      Map<String, dynamic> categories = {};
      for (var category in List.of(responseData["categories"])) {
        categories[category["name"]] = category["id"];
      }
      return categories;
    } else {
      return null;
    }
  }

  validate() {
    isValid = name.text.isNotEmpty &&
        price.text.isNotEmpty &&
        category != null &&
        (name.text.trim() != widget.stateData["name"] ||
            price.text.trim() != widget.stateData["price"].toString() ||
            category != widget.stateData["category"]);
  }
}
