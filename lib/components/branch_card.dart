import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class BranchCard extends StatefulWidget {
  const BranchCard(
      {super.key, required this.branch, required this.refreshCallback});

  final Map<String, dynamic> branch;
  final VoidCallback refreshCallback;

  @override
  State<BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<BranchCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            offset: const Offset(2, 2),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.25),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              widget.branch["name"],
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Icon(
              Icons.edit,
              color: grayText,
            ),
          )
        ],
      ),
    );
  }
}
