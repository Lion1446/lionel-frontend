import 'dart:convert';
import 'dart:developer';
import 'package:frontend/components/add_sales_item_dialog.dart';
import 'package:frontend/components/sales_item_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/portal_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class SalesAndAuditScreen extends StatefulWidget {
  const SalesAndAuditScreen({super.key, required this.stateData});

  final Map<String, dynamic> stateData;
  @override
  State<SalesAndAuditScreen> createState() => _SalesAndAuditScreenState();
}

class _SalesAndAuditScreenState extends State<SalesAndAuditScreen> {
  late String storeImage;
  late DateTime selectedDate;
  late String date;

  List<Map<String, dynamic>>? salesItems;
  late List<Map<String, dynamic>> inventoryItemsClosing;

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
    selectedDate = DateTime.now();
    date = DateFormat('MMMM d, y').format(selectedDate);
    inventoryItemsClosing = widget.stateData["inventoryItemsClosing"];
    fetchData();
    super.initState();
  }

  fetchData() async {
    Map<String, dynamic> resp = await getSalesItems(
      widget.stateData["branch"]["id"],
      DateFormat('MM/dd/yyyy HH:mm:ss').format(selectedDate),
    );
    salesItems = List<Map<String, dynamic>>.from(resp["sales_items"] ?? {});
    print(salesItems);
    resp = await getInventoryClosing(widget.stateData["branch"]["id"],
        DateFormat('MM/dd/yyyy HH:mm:ss').format(selectedDate));
    if (resp["status"] == 200) {
      inventoryItemsClosing = List<Map<String, dynamic>>.from(resp["items"]);
    } else {
      inventoryItemsClosing = [];
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
            color: primaryColor,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: PortalCard(portalName: "sales")),
          ),
          Container(
            height: size.height - 150,
            padding: const EdgeInsets.only(left: 30, right: 30, top: 50),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image:
                                DecorationImage(image: AssetImage(storeImage)),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          date,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: primaryColor,
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                  ],
                ),
                salesItems == null
                    ? const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                    : salesItems!.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: salesItems!.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> item = salesItems![index];
                                // Use 'ingredient' to build each list item
                                item["auth_token"] =
                                    widget.stateData["auth_token"];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 20,
                                    left: 5,
                                    right: 5,
                                  ),
                                  child: SalesItemCard(item: item),
                                );
                              },
                            ),
                          )
                        : inventoryItemsClosing.isEmpty
                            ? selectedDate.month == DateTime.now().month &&
                                    selectedDate.day == DateTime.now().day &&
                                    selectedDate.year == DateTime.now().year
                                ? Expanded(
                                    child: Center(
                                      child: Text(
                                        "No Items added yet.\nTap the + button to add an item.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          color: grayText,
                                        ),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: Center(
                                      child: Text(
                                        "We cannot add a sales item.\nSelected date is not today's date.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          color: grayText,
                                        ),
                                      ),
                                    ),
                                  )
                            : Expanded(
                                child: Center(
                                  child: Text(
                                    "Inventory for this date has been closed.\n We cannot add a sales item.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: grayText,
                                    ),
                                  ),
                                ),
                              ),
              ],
            ),
          ),
          Positioned(
            bottom: 130,
            right: 55,
            child: GestureDetector(
              onTap: inventoryItemsClosing.isEmpty &&
                      selectedDate.month == DateTime.now().month &&
                      selectedDate.day == DateTime.now().day &&
                      selectedDate.year == DateTime.now().year
                  ? () async {
                      final res = await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          final stateData = {
                            "auth_token": widget.stateData["auth_token"],
                            "date": DateFormat('MM/dd/yyyy HH:mm:ss')
                                .format(selectedDate),
                            "branch_id": widget.stateData["branch"]["id"],
                            "user_id": widget.stateData["user"]["id"],
                            "products": widget.stateData["products"],
                            "ingredients": widget.stateData["ingredients"],
                          };
                          return AddSalesItemDialog(
                            stateData: stateData,
                          ); // Use the custom dialog widget
                        },
                      );
                      if (res != null && res == true) {
                        fetchData();
                      }
                    }
                  : null,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  color: inventoryItemsClosing.isEmpty &&
                          selectedDate.month == DateTime.now().month &&
                          selectedDate.day == DateTime.now().day &&
                          selectedDate.year == DateTime.now().year
                      ? primaryColor
                      : grayColor,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                    child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                )),
              ),
            ),
          ),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        salesItems = null;
        selectedDate = picked;
        date = DateFormat('MMMM d, y').format(selectedDate);
      });
    }
    log(selectedDate.toString());
    fetchData();
  }

  Future<Map<String, dynamic>> getSalesItems(int branchID, String date) async {
    String url = '$baseURL/sales?date=$date&branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }
}
