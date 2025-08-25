// // lib/Frontend/components/profile_info_field.dart
// import 'package:flutter/material.dart';

// /// A reusable widget to display or edit a single line of profile information.
// class ProfileInfoField extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final bool isEditable;

//   const ProfileInfoField({
//     super.key,
//     required this.label,
//     required this.controller,
//     this.isEditable = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16.0,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8.0),
//         TextFormField(
//           controller: controller,
//           enabled: isEditable,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16.0),
//       ],
//     );
//   }
// }
