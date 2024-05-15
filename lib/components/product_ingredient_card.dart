import 'package:flutter/material.dart';
import 'package:frontend/components/delete_product_ingredient_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class ProductIngredientCard extends StatefulWidget {
  const ProductIngredientCard({
    super.key,
    required this.item,
    required this.refreshCallback,
    required this.isEditable,
  });
  final VoidCallback refreshCallback;
  final Map<String, dynamic> item;
  final bool isEditable;

  @override
  State<ProductIngredientCard> createState() => _ProductIngredientCardState();
}

class _ProductIngredientCardState extends State<ProductIngredientCard> {
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
        children: [
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.item["ingredient_details"]["name"],
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                // Text(
                //   widget.item["ingredient_details"]["category"],
                //   style: GoogleFonts.montserrat(
                //       fontWeight: FontWeight.w500,
                //       fontSize: 14,
                //       color: grayText.withOpacity(0.5)),
                // )
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.item['ingredient_details']['unit']} / serving",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${widget.item['quantity']}${widget.item['ingredient_details']['unit']}",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: grayText.withOpacity(0.5)),
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: IconButton(
              onPressed: widget.isEditable
                  ? () async {
                      final res = await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteProductIngredientDialog(
                            itemData: widget.item,
                          ); // Use the custom dialog widget
                        },
                      );
                      if (res != null && res == true) {
                        widget.refreshCallback();
                      }
                    }
                  : null,
              icon: widget.isEditable
                  ? const Icon(
                      Icons.delete,
                      color: errorColor,
                    )
                  : const SizedBox(),
            ),
          )
        ],
      ),
    );
  }
}
