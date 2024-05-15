import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteProductIngredientDialog extends StatefulWidget {
  const DeleteProductIngredientDialog({super.key, required this.itemData});

  final Map<String, dynamic> itemData;

  @override
  State<DeleteProductIngredientDialog> createState() =>
      _DeleteProductIngredientDialogState();
}

class _DeleteProductIngredientDialogState
    extends State<DeleteProductIngredientDialog> {
  bool isDeleting = false;
  String message = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Remove Ingredient',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Are you sure you want to remove this ingredient?",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text: 'Name: ',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: "${widget.itemData['ingredient_details']['name']}\n",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                // TextSpan(
                //   text: 'Category: ',
                //   style: GoogleFonts.montserrat(
                //     fontWeight: FontWeight.bold,
                //     fontSize: 13,
                //   ),
                // ),
                // TextSpan(
                //   text:
                //       "${widget.itemData['ingredient_details']['category']}\n",
                //   style: GoogleFonts.montserrat(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 13,
                //   ),
                // ),
                TextSpan(
                  text: 'Serving: ',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text:
                      "${widget.itemData['quantity']} ${widget.itemData['ingredient_details']['unit']}",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: Align(
              alignment: Alignment.center,
              child: Text(message,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: errorColor,
                  )),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Container(
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
                  onTap: () async {
                    setState(() {
                      message = "";
                      isDeleting = true;
                    });
                    final res =
                        await deleteProductIngredient(widget.itemData["id"]);
                    if (res) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(true); // Close the dialog
                    } else {
                      setState(() {
                        message = "Failed to remove this ingredient.";
                        isDeleting = false;
                      });
                    }
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: isDeleting
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'Delete',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white,
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
    );
  }

  Future<bool> deleteProductIngredient(int itemID) async {
    String url = '$baseURL/product_ingredients?id=$itemID';
    final response = await http.delete(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    log(responseData.toString());
    return responseData["status"] == 200;
  }
}
