import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EditBranchDialog extends StatefulWidget {
  const EditBranchDialog({super.key, required this.stateData});

  final Map<String, dynamic> stateData;

  @override
  State<EditBranchDialog> createState() => _EditBranchDialogState();
}

class _EditBranchDialogState extends State<EditBranchDialog> {
  late TextEditingController name;

  bool isValid = false;
  bool isCreating = false;
  String message = "";
  @override
  void initState() {
    name = TextEditingController(text: widget.stateData["branch_name"]);
    name.addListener(() {
      setState(() {
        isValid = widget.stateData["branch_name"] != name.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit Branch Name",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Branch Name",
                  style: GoogleFonts.montserrat(
                    color: grayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
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
                      Navigator.of(context).pop(false);
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
                                await editBranch(widget.stateData["branch_id"]);

                            if (response["status"] == 200) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop(true);
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
                                  color: isValid ? Colors.white : Colors.black,
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

  Future<Map<String, dynamic>> editBranch(int branchID) async {
    String url = '$baseURL/branch?id=$branchID';
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "name": name.text.trim(),
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }

  Future<Map<String, dynamic>> editUser(int userID, String password,
      String fullname, int branchID, bool isAdmin) async {
    String url = '$baseURL/user?id=$userID';
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "password": password,
          "fullname": fullname,
          "branch_id": branchID,
          "is_admin": isAdmin
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
