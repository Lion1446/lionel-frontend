import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'delete_ingredient_dialog.dart';

class IngredientCard extends StatefulWidget {
  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.refreshCallback,
  });
  final VoidCallback refreshCallback;
  final Map<String, dynamic> ingredient;

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
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
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.ingredient["name"],
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              onPressed: () async {
                final bool res = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteIngredientDialog(
                      ingredientData: widget.ingredient,
                    ); // Use the custom dialog widget
                  },
                );
                if (res) {
                  widget.refreshCallback();
                }
              },
              icon: const Icon(
                Icons.delete,
                color: errorColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
