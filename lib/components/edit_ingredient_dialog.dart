import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class EditIngredientDialog extends StatefulWidget {
  const EditIngredientDialog({
    super.key,
    required this.stateData,
    required this.ingredientData,
  });

  final Map<String, dynamic> stateData;
  final Map<String, dynamic> ingredientData;
  @override
  State<EditIngredientDialog> createState() => _EditIngredientDialogState();
}

class _EditIngredientDialogState extends State<EditIngredientDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController tolerance = TextEditingController();
  String? unit;

  Map<String, dynamic>? units;

  bool isValid = false;
  bool isCreating = false;
  String message = "";
  @override
  void initState() {
    name.text = widget.ingredientData["name"];
    tolerance.text = widget.ingredientData["tolerance"].toString();

    unit = widget.ingredientData["unit"];
    name.addListener(() {
      setState(() {
        validate();
      });
    });
    tolerance.addListener(() {
      setState(() {
        validate();
      });
    });
    fetchData();
    super.initState();
  }

  fetchData() async {
    units = await getUnits(widget.stateData["branch"]["id"]);
    log(units.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: units == null
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
                      "Edit Ingredient",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: name,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: grayText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      items: units!.keys.map((String value) {
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
                      value: unit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
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
                          unit = value;
                          validate();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tolerance,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: grayText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Tolerance',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
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
                                  final resp = await updateIngredient(
                                      widget.ingredientData["id"],
                                      name.text.trim(),
                                      // categories![category!],
                                      units![unit!],
                                      double.parse(tolerance.text.trim()));
                                  setState(() {
                                    isCreating = false;
                                  });
                                  if (resp["status"] == 200) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop(true);
                                  } else {
                                    setState(() {
                                      message = resp["remarks"];
                                    });
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

  validate() {
    isValid = name.text.isNotEmpty &&
        tolerance.text.isNotEmpty &&
        // category != null &&
        unit != null &&
        (name.text.trim() != widget.ingredientData["name"] ||
            tolerance.text.trim() !=
                widget.ingredientData["tolerance"].toString() ||
            // category != widget.ingredientData["category"] ||
            unit != widget.ingredientData["unit"]);
  }

  Future<Map<String, dynamic>?> getUnits(int branchID) async {
    String url = '$baseURL/unit?branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    if (responseData["status"] == 200) {
      Map<String, dynamic> units = {};
      for (var unit in List.of(responseData["units"])) {
        units[unit["name"]] = unit["id"];
      }
      return units;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateIngredient(
      int ingredientId, String name, int unitID, double tolerance) async {
    String url =
        '$baseURL/ingredient?id=$ingredientId'; // Include ingredient_id as a path parameter
    final response =
        await http.patch(Uri.parse(url), // Change the request method to PUT
            body: json.encode({
              "auth_token": widget.stateData["auth_token"],
              "name": name,
              "unit_id": unitID,
              "tolerance": tolerance,
              "branch_id": widget.stateData["branch"]["id"],
            }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
