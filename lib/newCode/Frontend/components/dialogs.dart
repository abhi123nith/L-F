// // lib/Frontend/components/dialogs.dart
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Backend/auth_service.dart';
// import 'package:l_f/newCode/Frontend/pages/Login/login_page.dart';

// /// Displays a confirmation dialog for logging out and handles the logout process.
// void showLogoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("Logout"),
//         content: const Text(
//           "Are you sure you want to log out?",
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text(
//               "Cancel",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: const Text(
//               "Logout",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             onPressed: () async {
//               try {
//                 await AuthService().signOut();
//                 // Navigate back to the login page after signing out.
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (_) => const LoginPage()),
//                   (Route<dynamic> route) => false,
//                 );
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     backgroundColor: Colors.red,
//                     content: Text('Error signing out: $e'),
//                   ),
//                 );
//                 Navigator.of(context).pop();
//               }
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
