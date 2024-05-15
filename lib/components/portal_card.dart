import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PortalCard extends StatelessWidget {
  PortalCard({
    super.key,
    required this.portalName,
  });

  final String portalName;

  final Map<String, String> portalDescriptions = {
    "ingredients": "Manage ingredients known to your store.",
    "inventory & audit":
        "Track the ins and outs of the ingredients in your store.",
    "products":
        "Set your ingredient requirements for your respective products.",
    "sales": "Manage your store product sales.",
    "system management":
        "Manage by creating and updating auditors and branch information.",
  };

  final Map<String, String> portalImages = {
    "ingredients": "assets/ingredients-icon.png",
    "inventory & audit": "assets/inventory-icon.png",
    "sales": "assets/audit-icon.png",
    "products": "assets/products-icon.png",
    "system management": "assets/settings-icon.png",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF1A936A),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portalName.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  portalDescriptions[portalName.toLowerCase()]!,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w200,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(portalImages[portalName.toLowerCase()]!)
        ],
      ),
    );
  }
}
