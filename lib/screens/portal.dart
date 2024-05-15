import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/fetching_data_dialog.dart';
import 'package:frontend/screens/ingredients.dart';
import 'package:frontend/screens/inventory.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/products.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../components/portal_card.dart';
import '../constants.dart';
import 'sales.dart';
import 'package:intl/intl.dart';

import 'system_management.dart';

class Portal extends StatefulWidget {
  const Portal({super.key, required this.stateData});
  final Map<String, dynamic> stateData;

  @override
  State<Portal> createState() => _PortalState();
}

class _PortalState extends State<Portal> {
  late String storeImage;

  @override
  void initState() {
    if (widget.stateData["branch"]["name"]
        .toString()
        .toLowerCase()
        .contains("ayame")) {
      storeImage = "assets/ayame-logo-small.png";
    } else {
      storeImage = "assets/myjoy-logo-small.png";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 25, right: 25),
            color: primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.stateData["user"]["user_type"] == 1
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        IngredientsScreen(
                                      stateData: widget.stateData,
                                    ),
                                  ),
                                );
                              },
                              child: PortalCard(
                                portalName: "ingredients",
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 15),
                      widget.stateData["user"]["user_type"] == 1
                          ? GestureDetector(
                              onTap: () async {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const FetchingDataDialog();
                                  },
                                );
                                final res = await getIngredients(
                                    widget.stateData["branch"]["id"]);
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop();
                                Map<String, dynamic> stateData = {};
                                stateData.addAll(widget.stateData);

                                if (res["status"] == 200) {
                                  stateData.addAll(
                                      {"ingredients": res["ingredients"]});
                                } else {
                                  stateData.addAll({"ingredients": []});
                                }
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        ProductsScreen(
                                      stateData: stateData,
                                    ),
                                  ),
                                );
                              },
                              child: PortalCard(
                                portalName: "products",
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  InventoryScreen(
                                stateData: widget.stateData,
                              ),
                            ),
                          );
                        },
                        child: PortalCard(
                          portalName: "inventory & audit",
                        ),
                      ),
                      const SizedBox(height: 15),
                      [1, 3].contains(widget.stateData["user"]["user_type"])
                          ? GestureDetector(
                              onTap: () async {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const FetchingDataDialog();
                                  },
                                );
                                var res = await getIngredients(
                                    widget.stateData["branch"]["id"]);

                                Map<String, dynamic> stateData = {};
                                stateData.addAll(widget.stateData);

                                if (res["status"] == 200) {
                                  stateData.addAll(
                                      {"ingredients": res["ingredients"]});
                                } else {
                                  stateData.addAll({"ingredients": []});
                                }
                                res = await getProducts(
                                    widget.stateData["branch"]["id"]);
                                if (res["status"] == 200) {
                                  stateData
                                      .addAll({"products": res["products"]});
                                } else {
                                  stateData.addAll({"products": []});
                                }

                                res = await getInventoryClosing(
                                    widget.stateData["branch"]["id"],
                                    DateFormat('MM/dd/yyyy HH:mm:ss')
                                        .format(DateTime.now()));
                                if (res["status"] == 200) {
                                  stateData.addAll({
                                    "inventoryItemsClosing":
                                        List<Map<String, dynamic>>.from(
                                            res["items"])
                                  });
                                } else if (res["status"] == 404) {
                                  stateData.addAll({
                                    "inventoryItemsClosing":
                                        <Map<String, dynamic>>[]
                                  });
                                }

                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        SalesAndAuditScreen(
                                      stateData: stateData,
                                    ),
                                  ),
                                );
                              },
                              child: PortalCard(
                                portalName: "sales",
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 15),
                      widget.stateData["user"]["user_type"] == 1
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        SystemManagementScreen(
                                      stateData: widget.stateData,
                                    ),
                                  ),
                                );
                              },
                              child: PortalCard(
                                portalName: "system management",
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const Login(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Logout',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 100,
            padding: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        image: DecorationImage(image: AssetImage(storeImage)),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.stateData["branch"]["name"],
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.stateData["user"]["fullname"],
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: grayText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> getInventoryClosing(
      int branchID, String date) async {
    String url = '$baseURL/inventory_closing?date=$date&branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<Map<String, dynamic>> getIngredients(int branchID) async {
    String url = '$baseURL/ingredients?branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<Map<String, dynamic>> getProducts(int branchID) async {
    String url = '$baseURL/products?branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }
}
