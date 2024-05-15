import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:intl/intl.dart';

class RemoveItemDialog extends StatefulWidget {
  const RemoveItemDialog({super.key, required this.stateData});

  final Map<String, dynamic> stateData;

  @override
  State<RemoveItemDialog> createState() => _RemoveItemDialogState();
}

class _RemoveItemDialogState extends State<RemoveItemDialog> {
  TextEditingController quantity = TextEditingController();
  TextEditingController remarks = TextEditingController();
  String? item;
  String? transactionType;

  bool isValid = false;
  bool isError = false;
  bool isCreating = false;
  bool isQuantityFieldEnabled = false;
  String message = "";
  Map<String, dynamic> ingredients = {};
  List<String> ingredientNames = [];
  String unit = "";
  List<String> transactions = ["withdraw", "spoiled", "expired", "bad order"];

  @override
  void initState() {
    quantity.addListener(() {
      setState(() {
        isValid = quantity.text.isNotEmpty &&
            item != null &&
            remarks.text.isNotEmpty &&
            transactionType != null &&
            quantity.text.isNotEmpty;
        isError = (double.tryParse(quantity.text) ?? 0) >
            (findQuantityByName(widget.stateData["ingredients"], item!)
                as double);
        if (isError) {
          message =
              "Item quantity to be removed can't exceed the item's initial quantity";
          isValid = false;
        } else {
          message = "";
          isValid = true;
        }
      });
    });
    remarks.addListener(() {
      setState(() {
        isValid = quantity.text.isNotEmpty &&
            item != null &&
            remarks.text.isNotEmpty &&
            transactionType != null &&
            quantity.text.isNotEmpty;

        isQuantityFieldEnabled = item != null && transactionType != null;
      });
    });
    for (var ingredient in widget.stateData["ingredients"]) {
      ingredients[ingredient["name"]] = ingredient;
      ingredientNames.add(ingredient["name"]);
    }
    super.initState();
  }

  double? findQuantityByName(
      List<Map<String, dynamic>> itemsRemoving, String name) {
    for (var item in itemsRemoving) {
      if (item['name'] == name) {
        return item['quantity'].toDouble();
      }
    }
    return null;
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
                "Remove Inventory Item",
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
                    "Item name",
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
                        isValid = quantity.text.isNotEmpty &&
                            item != null &&
                            remarks.text.isNotEmpty &&
                            transactionType != null &&
                            quantity.text.isNotEmpty;
                        unit = getUnit(value!);
                        isQuantityFieldEnabled =
                            item != null && transactionType != null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transaction Type",
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
                    items: transactions.map((String value) {
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
                    value: transactionType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        transactionType = value;
                        isValid = quantity.text.isNotEmpty &&
                            item != null &&
                            remarks.text.isNotEmpty &&
                            transactionType != null &&
                            quantity.text.isNotEmpty;
                        isQuantityFieldEnabled =
                            item != null && transactionType != null;
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
                        enabled: isQuantityFieldEnabled,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: isError
                                ? errorColor
                                : Colors.black.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isError
                                  ? errorColor
                                  : Colors.black.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isError
                                  ? errorColor
                                  : Colors.black.withOpacity(0.3)),
                        ),
                      ),
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
                      "Remarks",
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
                      controller: remarks,
                      // maxLines: null,
                      // keyboardType: TextInputType.multiline,
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
                            final response = await removeItem(
                                widget.stateData["branch_id"],
                                widget.stateData["auth_token"],
                                ingredients[item]["ingredient_id"],
                                double.parse(quantity.text),
                                remarks.text.trim(),
                                transactionType!);

                            if (response["status"] == 200) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop(true);
                            } else {
                              message = "Error removing item.";
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

  String getUnit(String ingredientName) {
    return ingredients[ingredientName]["unit"];
  }

  Future<Map<String, dynamic>> removeItem(
      int branchID,
      String token,
      int ingredientID,
      double quantity,
      String remarks,
      String transactionType) async {
    String url = '$baseURL/inventory_transaction';
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "ingredient_id": ingredientID,
          "quantity": quantity * -1,
          "datetime_created":
              DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now()),
          "branch_id": widget.stateData["branch_id"],
          "user_id": widget.stateData["user_id"],
          "transaction_type": transactionType,
          "remarks": remarks
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
