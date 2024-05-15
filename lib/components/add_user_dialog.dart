import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key, required this.stateData});

  final Map<String, dynamic> stateData;

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController fullname = TextEditingController();

  Map<String, dynamic> userTypes = {"Admin": 1, "Auditor": 2, "User": 3};
  int? branchID;
  int? userType;
  late Map<String, dynamic> branches;
  String? branchName;

  bool isValid = false;
  bool isCreating = false;
  String message = "";

  @override
  void initState() {
    branches = {};
    for (var branch in widget.stateData["branches"]) {
      branches[branch["name"]] = branch["id"];
    }

    password.addListener(() {
      validate();
    });
    fullname.addListener(() {
      validate();
    });
    super.initState();
  }

  validate() {
    setState(() {
      isValid = password.text.isNotEmpty &&
          fullname.text.isNotEmpty &&
          branchID != null &&
          userType != null;
    });
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
                "Add a new user",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: fullname,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: grayText,
                ),
                decoration: InputDecoration(
                  labelText: 'Fullname',
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
              TextField(
                controller: username,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: grayText,
                ),
                decoration: InputDecoration(
                  labelText: 'Username',
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
              TextField(
                controller: password,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: grayText,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
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
              SizedBox(
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Branch",
                      style: GoogleFonts.montserrat(
                        color: grayText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      items: branches.keys.map((String value) {
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
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                      ),
                      onChanged: (String? value) {
                        branchName = value;
                        branchID = branches[branchName];
                        validate();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // user type
              SizedBox(
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Type",
                      style: GoogleFonts.montserrat(
                        color: grayText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      items: userTypes.keys.map((String value) {
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
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          userType = userTypes[value];
                          validate();
                        });
                      },
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
                            final resp = await createUser(
                                username.text.trim(),
                                password.text.trim(),
                                fullname.text.trim(),
                                branchID!,
                                userType!);
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

  Future<Map<String, dynamic>> createUser(String username, String password,
      String fullname, int branchID, int userType) async {
    String url = '$baseURL/user';
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "admin_auth_token": widget.stateData["auth_token"],
          "username": username,
          "password": password,
          "fullname": fullname,
          "branch_id": branchID,
          "user_type": userType,
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
