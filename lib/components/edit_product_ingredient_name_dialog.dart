import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EditProductIngredientNameDialog extends StatefulWidget {
  const EditProductIngredientNameDialog({super.key, required this.stateData});

  final Map<String, dynamic> stateData;

  @override
  State<EditProductIngredientNameDialog> createState() =>
      _EditProductIngredientNameDialogState();
}

class _EditProductIngredientNameDialogState
    extends State<EditProductIngredientNameDialog> {
  late TextEditingController name;
  late TextEditingController price;

  bool isValid = false;
  bool isCreating = false;
  String message = "";
  String? category;
  Map<String, dynamic>? categories;

  @override
  void initState() {
    log(widget.stateData.toString());
    name = TextEditingController(text: widget.stateData["name"]);
    price = TextEditingController(text: widget.stateData["price"].toString());
    category = widget.stateData["category"];
    name.addListener(() {
      setState(() {
        isValid = name.text.isNotEmpty &&
            price.text.isNotEmpty &&
            (widget.stateData["name"] != name.text ||
                widget.stateData["price"].toString() != price.text);
      });
    });
    price.addListener(() {
      setState(() {
        isValid = name.text.isNotEmpty &&
            price.text.isNotEmpty &&
            (widget.stateData["name"] != name.text ||
                widget.stateData["price"].toString() != price.text);
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Product Name",
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
                    value: category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: grayText,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        category = value;
                        validate();
                      });
                    },
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(null);
                          },
                          child: Container(
                            width: 110,
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
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: isValid
                              ? () async {
                                  setState(() {
                                    isCreating = true;
                                    message = "";
                                  });
                                  // Create Inventory --> starting
                                  final response =
                                      await editProductIngredientName(
                                    name.text.trim(),
                                    double.tryParse(price.text) ?? 0,
                                    categories![category],
                                  );

                                  if (response["status"] == 200) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop({
                                      "name": name.text.trim(),
                                      "price": double.tryParse(price.text),
                                      "category": category,
                                    });
                                  } else {
                                    message = response["remarks"];
                                    isCreating = false;
                                  }
                                  setState(() {});
                                  // handle response
                                }
                              : null,
                          child: Container(
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<Map<String, dynamic>> editProductIngredientName(
      String name, double price, int categoryID) async {
    String url = '$baseURL/products?id=${widget.stateData['id']}';
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "name": name,
          "price": price,
          "category_id": categoryID,
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
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
