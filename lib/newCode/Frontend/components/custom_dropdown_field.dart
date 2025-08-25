// // lib/Frontend/components/custom_dropdown_field.dart
// import 'package:flutter/material.dart';

// /// A reusable dropdown form field with a consistent design.
// class CustomDropdownField<T> extends StatelessWidget {
//   final T? value;
//   final String label;
//   final List<T> items;
//   final String? Function(T?)? validator;
//   final ValueChanged<T?> onChanged;

//   const CustomDropdownField({
//     super.key,
//     this.value,
//     required this.label,
//     required this.items,
//     this.validator,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.2),
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         labelStyle: const TextStyle(color: Colors.black),
//       ),
//       items: items.map((T item) {
//         return DropdownMenuItem<T>(
//           value: item,
//           child: Text(item.toString()),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       validator: validator,
//     );
//   }
// }
