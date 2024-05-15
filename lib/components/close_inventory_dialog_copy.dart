// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../constants.dart';
// import 'package:intl/intl.dart';

// class CloseInventoryDialog extends StatefulWidget {
//   const CloseInventoryDialog(
//       {super.key, required this.inventoryItems, required this.stateData});

//   final List<Map<String, dynamic>> inventoryItems;
//   final Map<String, dynamic> stateData;
//   @override
//   State<CloseInventoryDialog> createState() => _CloseInventoryDialogState();
// }

// class _CloseInventoryDialogState extends State<CloseInventoryDialog> {
//   TextEditingController newQuantity = TextEditingController(text: '0');
//   TextEditingController expired = TextEditingController(text: '0');
//   TextEditingController spoiled = TextEditingController(text: '0');
//   TextEditingController badOrder = TextEditingController(text: '0');

//   List<Map<String, dynamic>> closingItems = [];

//   dynamic consumed = 0;
//   int itemIndex = 0;
//   bool isValid = true;
//   bool isCreating = false;

//   computeConsumed(double quantity, double newQuantity, double expired,
//       double badOrder, double spoiled) {
//     final consumed = quantity - newQuantity - expired - badOrder - spoiled;
//     return consumed > 0 ? consumed : 0;
//   }

//   setFields(Map<String, dynamic> item) {
//     newQuantity.text = item["new_quantity"].toString();
//     expired.text = item["expired"].toString();
//     spoiled.text = item["spoiled"].toString();
//     badOrder.text = item["bad_order"].toString();
//     consumed = item["consumed"];
//   }

//   @override
//   void initState() {
//     for (var item in widget.inventoryItems) {
//       Map<String, dynamic> closingItem = {
//         "ingredient_id": item["ingredient_id"],
//         "name": item["name"],
//         "unit": item["unit"],
//         "quantity": item["quantity"],
//         "new_quantity": item["quantity"],
//         "consumed": 0,
//         "expired": 0,
//         "spoiled": 0,
//         "bad_order": 0
//       };
//       closingItems.add(closingItem);
//     }
//     setFields(closingItems[0]);
//     newQuantity.addListener(() {
//       closingItems[itemIndex]["new_quantity"] =
//           double.tryParse(newQuantity.text) ?? 0;
//       if (newQuantity.text.isEmpty ||
//           expired.text.isEmpty ||
//           spoiled.text.isEmpty ||
//           badOrder.text.isEmpty) {
//         isValid = false;
//       } else {
//         isValid = true;
//         closingItems[itemIndex]["consumed"] = computeConsumed(
//           closingItems[itemIndex]["quantity"],
//           double.tryParse(newQuantity.text) ?? 0,
//           double.tryParse(expired.text) ?? 0,
//           double.tryParse(spoiled.text) ?? 0,
//           double.tryParse(badOrder.text) ?? 0,
//         );
//       }
//       setState(() {});
//     });

//     expired.addListener(() {
//       closingItems[itemIndex]["expired"] = double.tryParse(expired.text) ?? 0;
//       if (newQuantity.text.isEmpty ||
//           expired.text.isEmpty ||
//           spoiled.text.isEmpty ||
//           badOrder.text.isEmpty) {
//         isValid = false;
//       } else {
//         isValid = true;
//         closingItems[itemIndex]["consumed"] = computeConsumed(
//           closingItems[itemIndex]["quantity"],
//           double.tryParse(newQuantity.text) ?? 0,
//           double.tryParse(expired.text) ?? 0,
//           double.tryParse(spoiled.text) ?? 0,
//           double.tryParse(badOrder.text) ?? 0,
//         );
//       }
//       setState(() {});
//     });

//     spoiled.addListener(() {
//       closingItems[itemIndex]["spoiled"] = double.tryParse(spoiled.text) ?? 0;
//       if (newQuantity.text.isEmpty ||
//           expired.text.isEmpty ||
//           spoiled.text.isEmpty ||
//           badOrder.text.isEmpty) {
//         isValid = false;
//       } else {
//         isValid = true;
//         closingItems[itemIndex]["consumed"] = computeConsumed(
//           closingItems[itemIndex]["quantity"],
//           double.tryParse(newQuantity.text) ?? 0,
//           double.tryParse(expired.text) ?? 0,
//           double.tryParse(spoiled.text) ?? 0,
//           double.tryParse(badOrder.text) ?? 0,
//         );
//       }
//       setState(() {});
//     });

//     badOrder.addListener(() {
//       closingItems[itemIndex]["bad_order"] =
//           double.tryParse(badOrder.text) ?? 0;
//       if (newQuantity.text.isEmpty ||
//           expired.text.isEmpty ||
//           spoiled.text.isEmpty ||
//           badOrder.text.isEmpty) {
//         isValid = false;
//       } else {
//         isValid = true;
//         closingItems[itemIndex]["consumed"] = computeConsumed(
//           closingItems[itemIndex]["quantity"],
//           double.tryParse(newQuantity.text) ?? 0,
//           double.tryParse(expired.text) ?? 0,
//           double.tryParse(spoiled.text) ?? 0,
//           double.tryParse(badOrder.text) ?? 0,
//         );
//       }
//       setState(() {});
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         height: 520,
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Text(
//                 'Close Inventory Items',
//                 style: GoogleFonts.montserrat(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 18,
//                 ),
//               ),
//               const SizedBox(height: 15),
//               SizedBox(
//                 height: 75,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Item name',
//                       style: GoogleFonts.montserrat(
//                         color: grayText,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Container(
//                       height: 50,
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                             color: Colors.black.withOpacity(0.3), width: 1),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Text(
//                             closingItems[itemIndex]["name"],
//                             style: GoogleFonts.montserrat(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 80,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "New Quantity (${closingItems[itemIndex]['unit']})",
//                       style: GoogleFonts.montserrat(
//                         color: grayText,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     TextField(
//                       controller: newQuantity,
//                       keyboardType: TextInputType.number,
//                       style: GoogleFonts.montserrat(
//                         fontWeight: FontWeight.w300,
//                         fontSize: 14,
//                         color: grayText,
//                       ),
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide:
//                               BorderSide(color: Colors.black.withOpacity(0.3)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: SizedBox(
//                       height: 75,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Consumed',
//                             style: GoogleFonts.montserrat(
//                               color: grayText.withOpacity(0.5),
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           Container(
//                             height: 50,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                   color: grayText.withOpacity(0.3), width: 1),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               children: [
//                                 Text(
//                                   closingItems[itemIndex]["consumed"]
//                                       .toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w400,
//                                     color: grayText.withOpacity(0.3),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: SizedBox(
//                       height: 80,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Expired",
//                             style: GoogleFonts.montserrat(
//                               color: grayText,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           TextField(
//                             controller: expired,
//                             keyboardType: TextInputType.number,
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w300,
//                               fontSize: 14,
//                               color: grayText,
//                             ),
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 borderSide: BorderSide(
//                                     color: Colors.black.withOpacity(0.3)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: SizedBox(
//                       height: 80,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Bad Order",
//                             style: GoogleFonts.montserrat(
//                               color: grayText,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           TextField(
//                             controller: badOrder,
//                             keyboardType: TextInputType.number,
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w300,
//                               fontSize: 14,
//                               color: grayText,
//                             ),
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 borderSide: BorderSide(
//                                     color: Colors.black.withOpacity(0.3)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: SizedBox(
//                       height: 80,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Spoiled",
//                             style: GoogleFonts.montserrat(
//                               color: grayText,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           TextField(
//                             controller: spoiled,
//                             keyboardType: TextInputType.number,
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w300,
//                               fontSize: 14,
//                               color: grayText,
//                             ),
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                                 borderSide: BorderSide(
//                                     color: Colors.black.withOpacity(0.3)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "${itemIndex + 1} / ${widget.inventoryItems.length}",
//                 style: GoogleFonts.montserrat(
//                   color: grayText,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: isValid
//                           ? () {
//                               if (itemIndex > 0) {
//                                 itemIndex--;
//                                 setFields(closingItems[itemIndex]);
//                                 setState(() {});
//                               } else {
//                                 Navigator.of(context).pop(false);
//                               }
//                             }
//                           : null,
//                       child: Container(
//                         width: 120,
//                         height: 45,
//                         decoration: BoxDecoration(
//                             color: isValid
//                                 ? grayColor
//                                 : grayColor.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Center(
//                           child: Text(
//                             itemIndex == 0 ? 'Cancel' : 'Back',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14,
//                               color: isValid
//                                   ? Colors.black
//                                   : grayColor.withOpacity(0.3),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: isValid
//                           ? () async {
//                               if (itemIndex < closingItems.length - 1) {
//                                 itemIndex++;
//                                 setFields(closingItems[itemIndex]);
//                                 setState(() {});
//                               } else {
//                                 setState(() {
//                                   isCreating = true;
//                                 });
//                                 await closeInventory(closingItems);
//                                 // ignore: use_build_context_synchronously
//                                 Navigator.of(context).pop(true);
//                               }
//                             }
//                           : null,
//                       child: Container(
//                         width: 120,
//                         height: 45,
//                         decoration: BoxDecoration(
//                             color: isValid
//                                 ? primaryColor
//                                 : primaryColor.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(10)),
//                         child: isCreating
//                             ? const Center(
//                                 child: SizedBox(
//                                   width: 25,
//                                   height: 25,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 3,
//                                   ),
//                                 ),
//                               )
//                             : Center(
//                                 child: Text(
//                                 itemIndex + 1 == widget.inventoryItems.length
//                                     ? 'Finish'
//                                     : 'Next',
//                                 style: GoogleFonts.montserrat(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 14,
//                                   color: isValid
//                                       ? Colors.white
//                                       : Colors.white.withOpacity(0.3),
//                                 ),
//                               )),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<Map<String, dynamic>> closeInventory(
//       List<Map<String, dynamic>> closingItems) async {
//     String url = '$baseURL/inventory_closing';
//     final response = await http.post(Uri.parse(url),
//         body: json.encode({
//           "auth_token": widget.stateData["auth_token"],
//           "date": DateFormat('MM/dd/yyyy HH:mm:ss')
//               .format(widget.stateData["date"]),
//           "branch_id": widget.stateData["branch_id"],
//           "closing_items": closingItems
//         }));
//     final decoded = json.decode(response.body) as Map<String, dynamic>;
//     return decoded;
//   }
// }
