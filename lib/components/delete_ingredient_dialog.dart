import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteIngredientDialog extends StatefulWidget {
  const DeleteIngredientDialog({super.key, required this.ingredientData});

  final Map<String, dynamic> ingredientData;

  @override
  State<DeleteIngredientDialog> createState() => _DeleteIngredientDialogState();
}

class _DeleteIngredientDialogState extends State<DeleteIngredientDialog> {
  bool isDeleting = false;
  String message = "";
  String tolerance = "";

  @override
  void initState() {
    tolerance = widget.ingredientData["tolerance"].toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete Ingredient',
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
            "Are you sure you want to delete this ingredient?\n\nThis deletion will cascade to Product Ingredients, Inventory Items, and Inventory Transactions.",
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
                  text: "${widget.ingredientData['name']}\n",
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
                //   text: "${widget.ingredientData['category']}\n",
                //   style: GoogleFonts.montserrat(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 13,
                //   ),
                // ),
                TextSpan(
                  text: 'Unit: ',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: "${widget.ingredientData['unit']}\n",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'Tolerance: ',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: "$tolerance ${widget.ingredientData['unit']}",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(message),
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
                        await deleteIngredient(widget.ingredientData["id"]);
                    if (res) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(true); // Close the dialog
                    } else {
                      setState(() {
                        message = "Failed to delete this ingredient.";
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
      // actions: <Widget>[
      //   TextButton(
      //     child: Text('Cancel'),
      //     onPressed: () {
      //       Navigator.of(context).pop(false); // Close the dialog
      //     },
      //   ),
      //   TextButton(
      //     child: Text('Delete'),
      //     onPressed: () async {
      //       setState(() {
      //         message = "";
      //         isDeleting = true;
      //       });
      //       final res = await deleteIngredient(widget.ingredientData["id"]);
      //       if (res) {
      //         Navigator.of(context).pop(true); // Close the dialog
      //       } else {
      //         setState(() {
      //           message = "Failed to delete this ingredient.";
      //           isDeleting = false;
      //         });
      //       }
      //     },
      //   ),
      // ],
    );
  }

  Future<bool> deleteIngredient(int ingredientID) async {
    String url = '$baseURL/ingredient?id=$ingredientID';
    final response = await http.delete(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData["status"] == 200;
  }
}
