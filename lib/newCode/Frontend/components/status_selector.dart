// // lib/Frontend/components/status_selector.dart
// import 'package:flutter/material.dart';

// /// A reusable widget for selecting 'Lost' or 'Found' status.
// class StatusSelector extends StatelessWidget {
//   final String status;
//   final String selectedStatus;
//   final ValueChanged<String> onSelected;

//   const StatusSelector({
//     super.key,
//     required this.status,
//     required this.selectedStatus,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ChoiceChip(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(
//             radius: 12,
//             backgroundColor: selectedStatus == status ? Colors.deepOrange : Colors.grey[300],
//             child: CircleAvatar(
//               radius: 10,
//               backgroundColor: Colors.white,
//               child: selectedStatus == status
//                   ? const Icon(Icons.check, size: 16, color: Colors.deepOrange)
//                   : null,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             status,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//       selectedColor: Colors.deepOrange.withOpacity(0.1),
//       backgroundColor: Colors.transparent,
//       selected: selectedStatus == status,
//       onSelected: (_) => onSelected(status),
//     );
//   }
// }
