import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.isPassword,
    required this.controller,
  });
  final String label;
  final bool isPassword;
  final TextEditingController controller;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: const Color(0xFF646464),
            ),
          ),
          SizedBox(
            width: 306,
            height: 50,
            child: TextField(
              obscureText: widget.isPassword ? !showPassword : showPassword,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: const Color(0xFF646464),
                letterSpacing: widget.isPassword
                    ? showPassword
                        ? 0
                        : 3
                    : 0,
              ),
              decoration: InputDecoration(
                suffixIcon: widget.isPassword
                    ? InkWell(
                        onTap: widget.isPassword
                            ? () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              }
                            : null,
                        child: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      )
                    : null,
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF00875A)),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(0, 0, 0, 0.3), // 30% opacity black
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  widget.controller.text = val;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
