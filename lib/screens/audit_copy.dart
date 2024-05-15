// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:csv/csv.dart';
// import '../constants.dart';
// import 'dart:math';

// class AuditScreen extends StatefulWidget {
//   const AuditScreen({super.key, required this.stateData});

//   final Map<String, dynamic> stateData;
//   @override
//   State<AuditScreen> createState() => _AuditScreenState();
// }

// class _AuditScreenState extends State<AuditScreen> {
//   late String storeImage;
//   late List<Map<String, dynamic>> audit;
//   bool isCreating = false;

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
//     audit = List<Map<String, dynamic>>.from(widget.stateData["audit"]);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 50.0),
//             child: Container(
//               padding: const EdgeInsets.only(left: 30, right: 30),
//               height: 50,
//               child: Row(
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(50),
//                       image: DecorationImage(image: AssetImage(storeImage)),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           widget.stateData["branch_name"],
//                           style: GoogleFonts.montserrat(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 18,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           widget.stateData["fullname"],
//                           style: GoogleFonts.montserrat(
//                             fontWeight: FontWeight.w300,
//                             fontSize: 14,
//                             color: grayText,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 30),
//           Align(
//             alignment: Alignment.center,
//             child: Text(
//               "Audit for ${widget.stateData['date_string']}",
//               style: GoogleFonts.montserrat(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Row(
//                 children: [
//                   Expanded(
//                       flex: 3,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border(
//                               right: BorderSide(
//                                   color: grayColor)), // Set the border color
//                         ),
//                         child: DataTable(
//                           columns: [
//                             DataColumn(
//                                 label: Text(
//                               'Name',
//                               style: GoogleFonts.montserrat(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                             )),
//                           ],
//                           rows: [
//                             for (var entry in audit)
//                               DataRow(cells: [
//                                 DataCell(Text(
//                                   entry['ingredient_name'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                               ])
//                           ],
//                         ),
//                       )),
//                   // Second ListView for the rest of the table (scrollable)
//                   Expanded(
//                     flex: 5,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         columns: [
//                           DataColumn(
//                               label: Text(
//                             'Consumed (S)',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                           DataColumn(
//                               label: Text(
//                             'Consumed (I)',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                           DataColumn(
//                               label: Text(
//                             'Difference',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                           DataColumn(
//                               label: Text(
//                             'Remarks',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                           DataColumn(
//                               label: Text(
//                             'Tolerance',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                           DataColumn(
//                               label: Text(
//                             'Expired',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                           DataColumn(
//                               label: Text(
//                             'Spoiled',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                           DataColumn(
//                               label: Text(
//                             'Bad Order',
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                             ),
//                           )),
//                         ],
//                         rows: [
//                           for (var entry in audit)
//                             DataRow(
//                               cells: [
//                                 DataCell(Text(
//                                   entry['sales_consumed'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                                 DataCell(Text(
//                                   entry['inventory_consumed'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                                 DataCell(Text(
//                                   entry['unit_difference'].abs().toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                                 DataCell(Text(
//                                   entry['remarks'],
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                     color: entry['remarks'] == "okay"
//                                         ? primaryColor
//                                         : errorColor,
//                                   ),
//                                 )),
//                                 DataCell(Text(
//                                   entry['ingredient_tolerance'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                                 DataCell(Text(
//                                   entry['inventory_expired'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                                 DataCell(Text(
//                                   entry['inventory_spoiled'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                                 DataCell(Text(
//                                   entry['inventory_bad_order'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 )),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).pop(false);
//                     },
//                     child: Container(
//                       height: 45,
//                       decoration: BoxDecoration(
//                           color: grayColor,
//                           borderRadius: BorderRadius.circular(10)),
//                       child: Center(
//                         child: Text(
//                           'Exit',
//                           style: GoogleFonts.montserrat(
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () async {
//                       setState(() {
//                         isCreating = true;
//                       });
//                       await downloadCsvFile(audit);
//                       setState(() {
//                         isCreating = false;
//                       });
//                     },
//                     child: Container(
//                       height: 45,
//                       decoration: BoxDecoration(
//                           color: primaryColor,
//                           borderRadius: BorderRadius.circular(10)),
//                       child: Center(
//                         child: isCreating
//                             ? const SizedBox(
//                                 width: 25,
//                                 height: 25,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 3,
//                                 ),
//                               )
//                             : Text(
//                                 'Export as File',
//                                 style: GoogleFonts.montserrat(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 14,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> downloadCsvFile(List<Map<String, dynamic>> auditData) async {
//     List<List<dynamic>> rows = [];

//     // Add header row
//     rows.add([
//       'Ingredient ID',
//       'Ingredient Name',
//       'Sales Consumed',
//       'Inventory Consumed',
//       'Unit Difference'
//           'Remarks',
//       'Ingredient Tolerance',
//       'Inventory Expired',
//       'Inventory Spoiled',
//       'Inventory Bad Order',
//     ]);

//     // Add data rows
//     for (var entry in auditData) {
//       rows.add([
//         entry['ingredient_id'],
//         entry['ingredient_name'],
//         entry['sales_consumed'],
//         entry['inventory_consumed'],
//         entry['unit_difference'],
//         entry['remarks'],
//         entry['ingredient_tolerance'],
//         entry['inventory_expired'],
//         entry['inventory_spoiled'],
//         entry['inventory_bad_order'],
//       ]);
//     }

//     String csv = const ListToCsvConverter().convert(rows);
//     const String path = "/storage/emulated/0/Download";
//     String fileName =
//         "${widget.stateData['date'].split(' ')[0].replaceAll('/', '-')}-${generateRandomString(5)}.csv";
//     final File file = File("$path/$fileName");

//     await file.writeAsString(csv);
//     final snackBar = SnackBar(
//       content: Text('File downloaded at Downloads/$fileName'),
//       duration: Duration(seconds: 3), // Optional: Set a duration
//     );

//     // ScaffoldMessenger is used to show a snackbar
//     // ignore: use_build_context_synchronously
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     // await Permission.manageExternalStorage.request();
//     // var status = await Permission.manageExternalStorage.status;
//     // if (status.isDenied) {
//     //   // We didn't ask for permission yet or the permission has been denied   before but not permanently.
//     //   return;
//     // }

//     // // You can can also directly ask the permission about its status.
//     // if (await Permission.storage.isRestricted) {
//     //   // The OS restricts access, for example because of parental controls.
//     //   return;
//     // }
//     // if (status.isGranted) {

//     // }
//   }

//   String generateRandomString(int length) {
//     const String _chars =
//         'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
//     Random _rnd = Random.secure();

//     return String.fromCharCodes(Iterable.generate(
//         length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
//   }
// }
