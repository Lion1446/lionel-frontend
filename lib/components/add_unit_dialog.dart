import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AddUnitDialog extends StatefulWidget {
  const AddUnitDialog({super.key, required this.stateData});
  final Map<String, dynamic> stateData;
  @override
  State<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends State<AddUnitDialog> {
  TextEditingController name = TextEditingController();
  String message = "";
  bool isValid = false;
  bool isCreating = false;

  @override
  void initState() {
    name.addListener(() {
      setState(() {
        isValid = name.text.isNotEmpty;
      });
    });
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
                "Add New Unit",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unit Name",
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
                            final response = await createUnit(
                                widget.stateData["auth_token"],
                                name.text.trim(),
                                widget.stateData["branch"]["id"]);
                            if (response["status"] == 200) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop(true);
                            } else {
                              message = "Error adding unit.";
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

  Future<Map<String, dynamic>> createUnit(
      String token, String name, int branchID) async {
    String url = '$baseURL/unit';
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "name": name,
          "branch_id": branchID
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
