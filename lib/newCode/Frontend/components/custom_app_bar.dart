// // lib/Frontend/components/custom_app_bar.dart
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Frontend/components/dialogs.dart';
// import 'package:l_f/newCode/Frontend/pages/HomeScreen/home_screen.dart';
// import 'package:l_f/newCode/Frontend/pages/create_post/create_post_page.dart';
// import 'package:l_f/newCode/Frontend/pages/messages/messages_page.dart';
// import 'package:l_f/newCode/Frontend/pages/profile/profile_page.dart';

// /// A reusable and responsive AppBar for the application.
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final bool isMobile;
//   final GlobalKey<ScaffoldState> scaffoldKey;

//   const CustomAppBar({
//     super.key,
//     required this.isMobile,
//     required this.scaffoldKey,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.deepOrange,
//       foregroundColor: Colors.white,
//       title: isMobile
//           ? Row(
//               children: [
//                 Image.asset('assets/lg.png', height: 75, width: 75),
//               ],
//             )
//           : Row(
//               children: [
//                 Image.asset('assets/lg.png', height: 75, width: 75),
//                 const SizedBox(width: 16),
//                 const Text("CampusTracker"),
//               ],
//             ),
//       actions: isMobile
//           ? [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const CreatePostPage()),
//                   );
//                 },
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(7),
//                     side: const BorderSide(width: 2, color: Colors.white),
//                   ),
//                   color: Colors.deepOrange,
//                   child: const Padding(
//                     padding: EdgeInsets.all(1.0),
//                     child: Icon(Icons.add, size: 22),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               IconButton(
//                 onPressed: () {
//                   // Assuming MessagesPage is the right screen for 'My Chats'
//                   // Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesPage()));
//                 },
//                 icon: const Icon(Icons.messenger_outline_rounded),
//               ),
//               const SizedBox(width: 10),
//             ]
//           : [
//               CustomButton(
//                 label: "Home",
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (_) => const HomePage()));
//                 },
//               ),
//               CustomButton(
//                 label: "New Post",
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => const CreatePostPage()));
//                 },
//               ),
//               CustomButton(
//                 label: "My Chats",
//                 onPressed: () {
//                   // Assuming this is for chats
//                   Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()));
//                 },
//               ),
//               CustomButton(
//                 label: "Profile",
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (_) => const ProfilePage()));
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.logout, color: Colors.white, size: 21),
//                 onPressed: () => showLogoutDialog(context),
//               ),
//             ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// // A simple reusable button component for the web view.
// class CustomButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;

//   const CustomButton({
//     super.key,
//     required this.label,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: onPressed,
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
