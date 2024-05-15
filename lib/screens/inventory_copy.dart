// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:frontend/components/add_item_dialog.dart';
// import 'package:frontend/components/close_inventory_dialog.dart';
// import 'package:frontend/components/edit_starting_item_dialog.dart';
// import 'package:frontend/components/portal_card.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../components/item_card.dart';
// import '../constants.dart';
// import 'package:http/http.dart' as http;

// class InventoryScreen extends StatefulWidget {
//   const InventoryScreen({super.key, required this.stateData});

//   final Map<String, dynamic> stateData;
//   @override
//   State<InventoryScreen> createState() => _InventoryScreenState();
// }

// class _InventoryScreenState extends State<InventoryScreen>
//     with SingleTickerProviderStateMixin {
//   late String storeImage;
//   late DateTime selectedDate;
//   late String date;

//   late TabController tabController;
//   int tabIndex = 0;

//   List<Map<String, dynamic>>? inventoryItemsOpening;
//   List<Map<String, dynamic>>? inventoryItemsClosing;
//   Map<String, dynamic>? inventoryItems;
//   bool inventorytIsClosed = false;

//   void refreshScaffold() {
//     setState(() {});
//   }

//   void fetchData() async {
//     Map<String, dynamic> inventoryItems = await getInventories(
//       widget.stateData["branch"]["id"],
//       DateFormat('MM/dd/yyyy HH:mm:ss').format(selectedDate),
//     );
//     inventoryItemsOpening = List<Map<String, dynamic>>.from(
//         inventoryItems["opening"]["items"] ?? {});
//     inventoryItemsClosing = List<Map<String, dynamic>>.from(
//         inventoryItems["closing"]["items"] ?? {});
//     inventorytIsClosed = inventoryItemsClosing!.isNotEmpty;
//     setState(() {});
//   }

//   @override
//   void initState() {
//     if (widget.stateData["branch_name"]
//         .toString()
//         .toLowerCase()
//         .contains("ayame")) {
//       storeImage = "assets/ayame-logo-small.png";
//     } else {
//       storeImage = "assets/myjoy-logo-small.png";
//     }
//     selectedDate = DateTime.now();
//     date = DateFormat('MMMM d, y').format(selectedDate);
//     tabController = TabController(length: 2, vsync: this);
//     tabController.addListener(() {
//       setState(() {
//         tabIndex = tabController.index;
//       });
//     });
//     fetchData();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
//             color: primaryColor,
//             child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: PortalCard(portalName: "inventory")),
//           ),
//           Container(
//             height: size.height - 150,
//             padding: const EdgeInsets.only(left: 30, right: 30, top: 50),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: SizedBox(
//                     height: 50,
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(50),
//                             image:
//                                 DecorationImage(image: AssetImage(storeImage)),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 widget.stateData["branch_name"],
//                                 style: GoogleFonts.montserrat(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 18,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 widget.stateData["fullname"],
//                                 style: GoogleFonts.montserrat(
//                                   fontWeight: FontWeight.w300,
//                                   fontSize: 14,
//                                   color: grayText,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           date,
//                           style: GoogleFonts.montserrat(
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.calendar_today,
//                             color: primaryColor,
//                           ),
//                           onPressed: () => _selectDate(context),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: DefaultTabController(
//                     length: 2,
//                     child: Column(
//                       children: [
//                         TabBar(
//                           controller: tabController,
//                           indicatorColor: primaryColor,
//                           indicatorWeight: 5,
//                           labelColor: Colors.black,
//                           labelStyle: GoogleFonts.montserrat(
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),
//                           tabs: const [
//                             Tab(text: 'Opening'),
//                             Tab(text: 'Closing'),
//                           ],
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             controller: tabController,
//                             children: [
//                               inventoryItemsOpening == null
//                                   ? const Center(
//                                       child: CircularProgressIndicator())
//                                   : inventoryItemsOpening!.isNotEmpty
//                                       ? ListView.builder(
//                                           itemCount:
//                                               inventoryItemsOpening!.length,
//                                           itemBuilder: (context, index) {
//                                             Map<String, dynamic> item =
//                                                 inventoryItemsOpening![index];
//                                             // Use 'ingredient' to build each list item
//                                             item["auth_token"] =
//                                                 widget.stateData["auth_token"];
//                                             return Padding(
//                                               padding: const EdgeInsets.only(
//                                                 bottom: 20,
//                                                 left: 5,
//                                                 right: 5,
//                                               ),
//                                               child: GestureDetector(
//                                                   onTap: inventorytIsClosed
//                                                       ? null
//                                                       : () async {
//                                                           final res =
//                                                               await showDialog(
//                                                             barrierDismissible:
//                                                                 false,
//                                                             context: context,
//                                                             builder:
//                                                                 (BuildContext
//                                                                     context) {
//                                                               return EditStartingItemDialog(
//                                                                 stateData: item,
//                                                               ); // Use the custom dialog widget
//                                                             },
//                                                           );
//                                                           if (res) {
//                                                             setState(() {});
//                                                           }
//                                                         },
//                                                   child: ItemCard(
//                                                     refreshCallback:
//                                                         refreshScaffold,
//                                                     item: item,
//                                                     isEditable:
//                                                         !inventorytIsClosed,
//                                                   )),
//                                             );
//                                           },
//                                         )
//                                       : Center(
//                                           child: Text(
//                                             "No Items added yet.\nTap the + button to add an item.",
//                                             textAlign: TextAlign.center,
//                                             style: GoogleFonts.montserrat(
//                                               fontWeight: FontWeight.w300,
//                                               fontSize: 14,
//                                               color: grayText,
//                                             ),
//                                           ),
//                                         ),
//                               inventoryItemsClosing == null
//                                   ? const Center(
//                                       child: CircularProgressIndicator())
//                                   : inventoryItemsClosing!.isNotEmpty
//                                       ? ListView.builder(
//                                           itemCount:
//                                               inventoryItemsClosing!.length,
//                                           itemBuilder: (context, index) {
//                                             Map<String, dynamic> item =
//                                                 inventoryItemsClosing![index];
//                                             // Use 'ingredient' to build each list item
//                                             item["auth_token"] =
//                                                 widget.stateData["auth_token"];
//                                             return Padding(
//                                               padding: const EdgeInsets.only(
//                                                 bottom: 20,
//                                                 left: 5,
//                                                 right: 5,
//                                               ),
//                                               child: ItemCard(
//                                                 refreshCallback:
//                                                     refreshScaffold,
//                                                 item: item,
//                                                 isEditable: false,
//                                               ),
//                                             );
//                                           },
//                                         )
//                                       : Center(
//                                           child: Text(
//                                             "Inventory is not yet closed.",
//                                             textAlign: TextAlign.center,
//                                             style: GoogleFonts.montserrat(
//                                               fontWeight: FontWeight.w300,
//                                               fontSize: 14,
//                                               color: grayText,
//                                             ),
//                                           ),
//                                         ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           tabIndex == 0 && !inventorytIsClosed
//               ? Positioned(
//                   bottom: 130,
//                   right: 55,
//                   child: GestureDetector(
//                     onTap: () async {
//                       final res = await showDialog(
//                         barrierDismissible: false,
//                         context: context,
//                         builder: (BuildContext context) {
//                           final stateData = {
//                             "auth_token": widget.stateData["auth_token"],
//                             "date": selectedDate,
//                             "branch_id": widget.stateData["branch_id"],
//                             "ingredients": widget.stateData["ingredients"]
//                           };
//                           return AddItemDialog(
//                             stateData: stateData,
//                           ); // Use the custom dialog widget
//                         },
//                       );
//                       if (res) {
//                         setState(() {
//                           inventoryItems = null;
//                           inventoryItemsOpening = null;
//                           inventoryItemsClosing = null;
//                         });
//                         fetchData();
//                       }
//                     },
//                     child: Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.white,
//                           width: 3,
//                         ),
//                         color: primaryColor,
//                         borderRadius: BorderRadius.circular(60),
//                       ),
//                       child: const Center(
//                           child: Icon(
//                         Icons.add,
//                         color: Colors.white,
//                         size: 40,
//                       )),
//                     ),
//                   ),
//                 )
//               : inventorytIsClosed
//                   ? const SizedBox()
//                   : Positioned(
//                       bottom: 170,
//                       right: 48,
//                       child: GestureDetector(
//                         onTap: inventoryItemsOpening != null &&
//                                 inventoryItemsOpening!.isNotEmpty
//                             ? () async {
//                                 Map<String, dynamic> stateData = {
//                                   "auth_token": widget.stateData["auth_token"],
//                                   "date": selectedDate,
//                                   "branch_id": widget.stateData["branch_id"]
//                                 };
//                                 final res = await showDialog(
//                                   barrierDismissible: false,
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return CloseInventoryDialog(
//                                       inventoryItems: inventoryItemsOpening!,
//                                       stateData: stateData,
//                                     ); // Use the custom dialog widget
//                                   },
//                                 );
//                                 if (res) {
//                                   fetchData();
//                                 }
//                               }
//                             : null,
//                         child: Container(
//                           width: 265,
//                           height: 47,
//                           decoration: BoxDecoration(
//                             color: inventoryItemsOpening != null &&
//                                     inventoryItemsOpening!.isNotEmpty
//                                 ? primaryColor
//                                 : grayColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Close Inventory',
//                               style: GoogleFonts.montserrat(
//                                 fontWeight: FontWeight.w300,
//                                 fontSize: 21,
//                                 color: inventoryItemsOpening != null &&
//                                         inventoryItemsOpening!.isNotEmpty
//                                     ? Colors.white
//                                     : Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         date = DateFormat('MMMM d, y').format(selectedDate);
//         inventoryItems = null;
//         inventoryItemsOpening = null;
//         inventoryItemsClosing = null;
//       });
//       fetchData();
//     }
//   }

//   Future<Map<String, dynamic>> getInventoryOpening(
//       int branchID, String date) async {
//     String url = '$baseURL/inventory_starting?date=$date&branch_id=$branchID';
//     final response = await http.get(Uri.parse(url));
//     Map<String, dynamic> responseData =
//         json.decode(response.body) as Map<String, dynamic>;
//     return responseData;
//   }

//   Future<Map<String, dynamic>> getInventoryClosing(
//       int branchID, String date) async {
//     String url = '$baseURL/inventory_closing?date=$date&branch_id=$branchID';
//     final response = await http.get(Uri.parse(url));
//     Map<String, dynamic> responseData =
//         json.decode(response.body) as Map<String, dynamic>;
//     return responseData;
//   }

//   Future<Map<String, dynamic>> getInventories(int branchID, String date) async {
//     Map<String, dynamic> opening = await getInventoryOpening(branchID, date);
//     Map<String, dynamic> closing = await getInventoryClosing(branchID, date);
//     return {"opening": opening, "closing": closing};
//   }
// }
