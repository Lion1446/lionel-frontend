import 'dart:convert';
import 'package:frontend/screens/portal.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/components/textfield.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController username;
  late TextEditingController password;

  bool isValid = false;
  bool isSigningIn = false;
  String message = "";
  @override
  void initState() {
    username = TextEditingController();
    password = TextEditingController();

    username.addListener(() {
      setState(() {
        isValid = username.text.isNotEmpty && password.text.isNotEmpty;
      });
    });

    password.addListener(() {
      setState(() {
        isValid = username.text.isNotEmpty && password.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            Text(
              'Please sign in to continue',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: grayText,
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              label: 'Username',
              isPassword: false,
              controller: username,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              isPassword: true,
              controller: password,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: Text(message,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: errorColor,
                  )),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: isValid
                    ? () async {
                        setState(() {
                          isSigningIn = true;
                          message = "";
                        });
                        final resp = await signin(username.text, password.text);
                        setState(() {
                          isSigningIn = false;
                        });
                        if (resp["status"] == 200) {
                          setState(() {
                            message = "";
                          });
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => Portal(
                                stateData: resp,
                              ),
                            ),
                          );
                        } else if (resp["status"] == 401) {
                          setState(() {
                            message = "Invalid credentials. Please try again.";
                          });
                        } else {
                          setState(() {
                            message = "Internal server error.";
                          });
                        }
                      }
                    : null,
                child: Container(
                  width: 130,
                  height: 50,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: isValid ? primaryColor : const Color(0xFFC3C3C3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Login',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: username.text.isNotEmpty &&
                                  password.text.isNotEmpty
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      isSigningIn
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              Icons.arrow_right_alt,
                              color: username.text.isNotEmpty &&
                                      password.text.isNotEmpty
                                  ? Colors.white
                                  : Colors.black,
                            ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> signin(String username, String password) async {
  String url = '$baseURL/login';
  final response = await http.post(Uri.parse(url),
      body: json.encode({"username": username, "password": password}));
  final decoded = json.decode(response.body) as Map<String, dynamic>;
  return decoded;
}
