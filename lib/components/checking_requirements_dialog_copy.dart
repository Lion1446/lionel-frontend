// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:frontend/screens/audit.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import '../constants.dart';

// class CheckingRequirementsDialog extends StatefulWidget {
//   const CheckingRequirementsDialog({super.key, required this.stateData});

//   final Map<String, dynamic> stateData;

//   @override
//   State<CheckingRequirementsDialog> createState() =>
//       _CheckingRequirementsDialogState();
// }

// class _CheckingRequirementsDialogState
//     extends State<CheckingRequirementsDialog> {
//   List<Map<String, dynamic>>? salesItems;
//   bool? inventorytIsClosed;

//   bool isCreating = false;
//   bool isAuditing = false;

//   fetchData() async {
//     Map<String, dynamic> resp = await getSalesItems(
//       widget.stateData["branch"]["id"],
//       widget.stateData["date"],
//     );
//     salesItems = List<Map<String, dynamic>>.from(resp["sales_items"] ?? {});
//     inventorytIsClosed = (await getInventoryClosing(
//             widget.stateData["branch"]["id"],
//             widget.stateData["date"]))["status"] ==
//         200;
//     if (!mounted) return;
//     setState(() {});
//   }

//   @override
//   void initState() {
//     fetchData();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.all(20),
//         child: inventorytIsClosed == null || salesItems == null
//             ? Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Checking Requirements',
//                     style: GoogleFonts.montserrat(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   const SizedBox(
//                     width: 50,
//                     height: 50,
//                     child: CircularProgressIndicator(
//                       color: primaryColor,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                 ],
//               )
//             : inventorytIsClosed == true && salesItems!.isNotEmpty
//                 ? Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Complete Requirements',
//                         style: GoogleFonts.montserrat(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(25),
//                             color: primaryColor),
//                         child: const Center(
//                           child: Icon(
//                             Icons.check_outlined,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         "Ready for audit, would you like to proceed?",
//                         style: GoogleFonts.montserrat(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.of(context).pop(false);
//                               },
//                               child: Container(
//                                 height: 45,
//                                 decoration: BoxDecoration(
//                                     color: grayColor,
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: Center(
//                                   child: Text(
//                                     'Cancel',
//                                     style: GoogleFonts.montserrat(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () async {
//                                 setState(() {
//                                   isCreating = true;
//                                 });
//                                 final resp = await generateAudit();
//                                 setState(() {
//                                   isCreating = true;
//                                 });
//                                 if (resp["status"] == 200) {
//                                   Map<String, dynamic> stateData =
//                                       widget.stateData;
//                                   stateData.addAll({"audit": resp["audit"]});
//                                   // ignore: use_build_context_synchronously
//                                   Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute<void>(
//                                       builder: (BuildContext context) =>
//                                           AuditScreen(
//                                         stateData: stateData,
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   Navigator.pop(context);
//                                 }
//                               },
//                               child: Container(
//                                 height: 45,
//                                 decoration: BoxDecoration(
//                                     color: primaryColor,
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: Center(
//                                   child: isCreating
//                                       ? const SizedBox(
//                                           width: 25,
//                                           height: 25,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 3,
//                                           ),
//                                         )
//                                       : Text(
//                                           'Start',
//                                           style: GoogleFonts.montserrat(
//                                               fontWeight: FontWeight.w500,
//                                               fontSize: 14,
//                                               color: Colors.white),
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   )
//                 : Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Incomplete Requirements',
//                         style: GoogleFonts.montserrat(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const SizedBox(
//                         width: 50,
//                         height: 50,
//                         child: Icon(
//                           Icons.cancel_rounded,
//                           color: errorColor,
//                           size: 50,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       inventorytIsClosed == true
//                           ? const SizedBox()
//                           : Text(
//                               "• Inventory for this date is not yet closed.",
//                               style: GoogleFonts.montserrat(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 14,
//                               ),
//                             ),
//                       const SizedBox(height: 10),
//                       salesItems!.isEmpty
//                           ? Text(
//                               "• Sales for this date is not yet encoded.",
//                               style: GoogleFonts.montserrat(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 14,
//                               ),
//                             )
//                           : const SizedBox(),
//                       const SizedBox(height: 20),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.of(context).pop(false);
//                               },
//                               child: Container(
//                                 height: 45,
//                                 decoration: BoxDecoration(
//                                     color: grayColor,
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: Center(
//                                   child: Text(
//                                     'Okay',
//                                     style: GoogleFonts.montserrat(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//       ),
//     );
//   }

//   Future<Map<String, dynamic>> getSalesItems(int branchID, String date) async {
//     String url = '$baseURL/sales?date=$date&branch_id=$branchID';
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

//   Future<Map<String, dynamic>> generateAudit() async {
//     String url = '$baseURL/audit';
//     final response = await http.post(Uri.parse(url),
//         body: json.encode({
//           "auth_token": widget.stateData["auth_token"],
//           "date": widget.stateData["date"],
//           "branch_id": widget.stateData["branch_id"],
//         }));
//     final decoded = json.decode(response.body) as Map<String, dynamic>;
//     return decoded;
//   }
// }
