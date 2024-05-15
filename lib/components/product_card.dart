import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatefulWidget {
  const ProductCard(
      {super.key, required this.product, required this.refreshCallback});

  final Map<String, dynamic> product;
  final VoidCallback refreshCallback;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              widget.product["name"],
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              widget.product["category"],
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: grayColor,
              ),
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: IconButton(
          //     onPressed: () async {
          //       final bool res = await showDialog(
          //         barrierDismissible: false,
          //         context: context,
          //         builder: (BuildContext context) {
          //           return DeleteProductDialog(
          //             productData: widget.product,
          //           ); // Use the custom dialog widget
          //         },
          //       );
          //       if (res) {
          //         widget.refreshCallback();
          //       }
          //     },
          //     icon: const Icon(
          //       Icons.delete,
          //       color: errorColor,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
