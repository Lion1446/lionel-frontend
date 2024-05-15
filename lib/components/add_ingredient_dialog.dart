import 'dart:convert';
import 'dart:developer';
import 'package:frontend/components/add_unit_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AddIngredientDialog extends StatefulWidget {
  const AddIngredientDialog({super.key, required this.stateData});

  final Map<String, dynamic> stateData;
  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController tolerance = TextEditingController();
  // TextEditingController newCategoryController = TextEditingController();
  TextEditingController newUnitSymbolController = TextEditingController();
  TextEditingController newUnitController = TextEditingController();
  // String? category;
  String? unit;
  Map<String, dynamic>? categories;
  Map<String, dynamic>? units;

  bool isValid = false;
  bool isCreating = false;
  String message = "";
  @override
  void initState() {
    log(widget.stateData.toString());
    name.addListener(() {
      setState(() {
        isValid = name.text.isNotEmpty &&
            tolerance.text.isNotEmpty &&
            // category != null &&
            unit != null;
      });
    });
    tolerance.addListener(() {
      setState(() {
        isValid = name.text.isNotEmpty &&
            tolerance.text.isNotEmpty &&
            // category != null &&
            unit != null;
      });
    });
    fetchData();
    super.initState();
  }

  fetchData() async {
    categories = await getCategories(widget.stateData["branch"]["id"]);
    units = await getUnits(widget.stateData["branch"]["id"]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: units == null || categories == null
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
                      "Add New Ingredient",
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
                            "Name",
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
                            "Unit",
                            style: GoogleFonts.montserrat(
                              color: grayText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
                                      return AddUnitDialog(
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
                                unit = value;
                                isValid = name.text.isNotEmpty &&
                                    tolerance.text.isNotEmpty &&
                                    // category != null &&
                                    unit != null;
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit != null ? "Tolerance ($unit)" : "Tolerance",
                            style: GoogleFonts.montserrat(
                              color: grayText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextField(
                            controller: tolerance,
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
                                  final resp = await createIngredient(
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

  Future<Map<String, dynamic>> createIngredient(
      String name, int unitID, double tolerance) async {
    String url = '$baseURL/ingredient';
    final response = await http.post(Uri.parse(url),
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
