// ignore: file_names
// ignore: file_names
// import 'package:flutter/material.dart';
// import 'package:frontend/components/portal_card.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../constants.dart';

// class IngredientsScreen extends StatefulWidget {
//   const IngredientsScreen({super.key, required this.stateData});

//   final Map<String, dynamic> stateData;
//   @override
//   State<IngredientsScreen> createState() => _IngredientsScreenState();
// }

// class _IngredientsScreenState extends State<IngredientsScreen> {
//   late String storeImage;

//   @override
//   void initState() {
//     if (widget.stateData["branch_id"] == 1 ||
//         widget.stateData["branch_id"] == 2) {
//       storeImage = "assets/ayame-logo-small.png";
//     } else {
//       storeImage = "assets/myjoy-logo-small.png";
//     }
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
//                 child: PortalCard(portalName: "ingredients")),
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
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: SizedBox(
//                 height: 50,
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(50),
//                         image: DecorationImage(image: AssetImage(storeImage)),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.stateData["branch_name"],
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             widget.stateData["fullname"],
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w300,
//                               fontSize: 14,
//                               color: grayText,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 130,
//             right: 55,
//             child: Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.white,
//                   width: 3,
//                 ),
//                 color: primaryColor,
//                 borderRadius: BorderRadius.circular(60),
//               ),
//               child: Center(
//                   child: Icon(
//                 Icons.add,
//                 color: Colors.white,
//                 size: 40,
//               )),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
