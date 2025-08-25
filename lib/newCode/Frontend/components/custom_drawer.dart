// // lib/Frontend/components/custom_drawer.dart
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Frontend/components/dialogs.dart';
// import 'package:l_f/newCode/Frontend/pages/create_post/create_post_page.dart';
// import 'package:l_f/newCode/Frontend/pages/profile/profile_page.dart';

// /// A reusable Drawer component for mobile viewports.
// class CustomDrawer extends StatelessWidget {
//   const CustomDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           // Header with logo
//           Container(
//             padding:
//                 const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
//             decoration: const BoxDecoration(
//               color: Colors.deepOrange,
//             ),
//             child: Row(
//               children: [
//                 Image.asset('assets/logo2.png', height: 80, width: 80),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'CampusTracker',
//                   style: TextStyle(
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Drawer menu items
//           Expanded(
//             child: ListView(
//               children: [
//                 ListTile(
//                   title: const Text("Home"),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   title: const Text("New Post"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const CreatePostPage()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   title: const Text("My List"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Assuming this is for chats
//                     // Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesPage()));
//                   },
//                 ),
//                 ListTile(
//                   title: const Text("Profile"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ProfilePage()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   title: const Text("My Chats"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     // Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesPage()));
//                   },
//                 ),
//               ],
//             ),
//           ),
//           // Logout button at the bottom
//           GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//               showLogoutDialog(context);
//             },
//             child: Container(
//               color: Colors.deepOrange,
//               padding: const EdgeInsets.all(10),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Logout",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Icon(
//                     Icons.logout,
//                     color: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
