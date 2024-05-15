import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductIngredientDialog extends StatefulWidget {
  const AddProductIngredientDialog({super.key, required this.stateData});

  final Map<String, dynamic> stateData;
  @override
  State<AddProductIngredientDialog> createState() =>
      _AddProductIngredientDialogState();
}

class _AddProductIngredientDialogState
    extends State<AddProductIngredientDialog> {
  TextEditingController quantity = TextEditingController();
  String? item;

  bool isValid = false;
  bool isCreating = false;
  String message = "";
  Map<String, dynamic> ingredients = {};
  List<String> ingredientNames = [];
  String unit = "";

  @override
  void initState() {
    quantity.addListener(() {
      setState(() {
        isValid = quantity.text.isNotEmpty && item != null;
      });
    });
    for (var ingredient in widget.stateData["ingredients"]) {
      ingredients[ingredient["name"]] = ingredient["id"];
      ingredientNames.add(ingredient["name"]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Product Ingredient",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ingredient name",
                    style: GoogleFonts.montserrat(
                      color: grayText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  DropdownButtonFormField<String>(
                    items: ingredientNames.map((String value) {
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
                    isExpanded: true,
                    value: item,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        item = value;
                        isValid = quantity.text.isNotEmpty && item != null;
                        unit = getUnitForId(ingredients[value])!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit == "" ? "Quantity" : "Quantity ($unit)",
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
                      controller: quantity,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: grayText,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
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
                            final response = await addProductIngredient(
                                widget.stateData["auth_token"],
                                ingredients[item],
                                double.parse(quantity.text),
                                widget.stateData["product_id"]);

                            if (response["status"] == 200) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop(true);
                            } else {
                              message = "Error adding ingredient.";
                              isCreating = false;
                            }
                            setState(() {});
                            // handle response
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
                                  color: isValid ? Colors.white : Colors.black,
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

  String? getUnitForId(int id) {
    Map<String, dynamic>? ingredient =
        widget.stateData["ingredients"].firstWhere(
      (ingredient) => ingredient["id"] == id,
      orElse: () => null,
    );

    return ingredient != null ? ingredient["unit"] : null;
  }

  Future<Map<String, dynamic>> addProductIngredient(
      String token, int ingredientID, double quantity, int productID) async {
    String url = '$baseURL/product_ingredients';
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "ingredient_id": ingredientID,
          "quantity": quantity,
          "product_id": productID,
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
