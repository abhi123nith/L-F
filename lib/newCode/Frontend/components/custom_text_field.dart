// // lib/Frontend/components/custom_text_field.dart
// import 'package:flutter/material.dart';

// /// A reusable, stylized text field widget.
// class CustomTextField extends StatelessWidget {
//   final TextEditingController? controller;
//   final String label;
//   final IconData icon;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final void Function(String?)? onSaved;

//   const CustomTextField({
//     super.key,
//     this.controller,
//     required this.label,
//     required this.icon,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.onSaved,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         prefixIcon: Icon(icon, color: Colors.deepOrange),
//         filled: true,
//         fillColor: Colors.white.withOpacity(1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       style: const TextStyle(color: Colors.black),
//       validator: validator,
//       onSaved: onSaved,
//     );
//   }
// }
