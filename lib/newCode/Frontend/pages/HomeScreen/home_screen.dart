// // lib/Frontend/pages/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Frontend/components/custom_app_bar.dart';
// import 'package:l_f/newCode/Frontend/components/custom_drawer.dart';
// import 'package:l_f/newCode/Frontend/pages/lost_and_found_page.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         bool isMobile = constraints.maxWidth < 700;
//         final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//         return Scaffold(
//           key: scaffoldKey,
//           appBar: CustomAppBar(isMobile: isMobile, scaffoldKey: scaffoldKey),
//           drawer: isMobile ? const CustomDrawer() : null,
//           body: isMobile
//               ? const Center(child: LostFoundPage())
//               : const Column(
//                   children: [
//                     Expanded(
//                       flex: 5,
//                       child: Center(
//                         child: LostFoundPage(),
//                       ),
//                     ),
//                   ],
//                 ),
//         );
//       },
//     );
//   }
// }
