import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'package:intl/intl.dart';

class CloseInventoryDialog extends StatefulWidget {
  const CloseInventoryDialog(
      {super.key, required this.inventoryItems, required this.stateData});

  final List<Map<String, dynamic>> inventoryItems;
  final Map<String, dynamic> stateData;
  @override
  State<CloseInventoryDialog> createState() => _CloseInventoryDialogState();
}

class _CloseInventoryDialogState extends State<CloseInventoryDialog> {
  List<Map<String, dynamic>> closingItems = [];
  TextEditingController newQuantity = TextEditingController();
  TextEditingController remarks = TextEditingController();

  bool isValid = false;
  bool isCreating = false;
  int itemIndex = 0;
  bool isError = false;

  setFields(Map<String, dynamic> item) {
    newQuantity.text = item["new_quantity"].toString();
    remarks.text = item["remarks"];
  }

  @override
  void initState() {
    for (var item in widget.inventoryItems) {
      Map<String, dynamic> closingItem = {
        "ingredient_id": item["ingredient_id"],
        "name": item["name"],
        "unit": item["unit"],
        "quantity": item["quantity"],
        "new_quantity": item["quantity"],
        "tolerance": item["tolerance"],
        "remarks": "",
      };
      closingItems.add(closingItem);
    }
    if (closingItems.isNotEmpty) {
      setFields(closingItems[0]);
    }
    newQuantity.addListener(() {
      closingItems[itemIndex]["new_quantity"] =
          double.tryParse(newQuantity.text) ?? 0;
      if (newQuantity.text.isEmpty || remarks.text.isEmpty) {
        isValid = false;
      } else {
        isValid = true;
      }
      isError = (((double.tryParse(newQuantity.text) ?? 0) -
                  closingItems[itemIndex]['quantity'])
              .abs() >
          closingItems[itemIndex]['tolerance']);
      setState(() {});
    });
    remarks.addListener(() {
      closingItems[itemIndex]["remarks"] = remarks.text;
      if (newQuantity.text.isEmpty || remarks.text.isEmpty) {
        isValid = false;
      } else {
        isValid = true;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Close Inventory Items',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item name',
                      style: GoogleFonts.montserrat(
                        color: grayText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black.withOpacity(0.3), width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            closingItems[itemIndex]["name"],
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Quantity (${closingItems[itemIndex]['quantity']}${closingItems[itemIndex]['unit']})",
                      style: GoogleFonts.montserrat(
                        color: grayText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: newQuantity,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: grayText,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isError
                                  ? errorColor
                                  : Colors.black.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isError
                                  ? errorColor
                                  : Colors.black.withOpacity(0.3)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Remarks",
                      style: GoogleFonts.montserrat(
                        color: grayText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: remarks,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: grayText,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${itemIndex + 1} / ${widget.inventoryItems.length}",
                style: GoogleFonts.montserrat(
                  color: grayText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (itemIndex > 0) {
                          itemIndex--;
                          setFields(closingItems[itemIndex]);
                          setState(() {});
                        } else {
                          Navigator.of(context).pop(false);
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 45,
                        decoration: BoxDecoration(
                            color: grayColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            itemIndex == 0 ? 'Cancel' : 'Back',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: isValid
                          ? () async {
                              if (itemIndex < closingItems.length - 1) {
                                itemIndex++;
                                setFields(closingItems[itemIndex]);
                                setState(() {});
                              } else {
                                setState(() {
                                  isCreating = true;
                                });
                                final res = await closeInventory(closingItems);
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop(res["status"] == 200);
                              }
                            }
                          : null,
                      child: Container(
                        width: 120,
                        height: 45,
                        decoration: BoxDecoration(
                            color: isValid
                                ? primaryColor
                                : primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10)),
                        child: isCreating
                            ? const Center(
                                child: SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                itemIndex + 1 == widget.inventoryItems.length
                                    ? 'Finish'
                                    : 'Next',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isValid
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                ),
                              )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> closeInventory(
      List<Map<String, dynamic>> closingItems) async {
    String url = '$baseURL/inventory_closing';
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "auth_token": widget.stateData["auth_token"],
          "date": DateFormat('MM/dd/yyyy HH:mm:ss')
              .format(widget.stateData["date"]),
          "branch_id": widget.stateData["branch_id"],
          "closing_items": closingItems
        }));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
