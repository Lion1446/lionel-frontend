import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class SalesItemCard extends StatefulWidget {
  const SalesItemCard({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<SalesItemCard> createState() => _SalesItemCardState();
}

class _SalesItemCardState extends State<SalesItemCard> {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.item["name"],
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Quantity: ${widget.item['quantity']}",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: grayText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
