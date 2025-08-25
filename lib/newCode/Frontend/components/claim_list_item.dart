// // lib/Frontend/components/claim_list_item.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:l_f/newCode/service/user_service.dart';

// class ClaimListItem extends StatelessWidget {
//   final DocumentSnapshot claim;
//   final Map<String, dynamic> postData;
//   final VoidCallback onTap;
//   final VoidCallback? onAccept;
//   final VoidCallback? onDecline;

//   const ClaimListItem({
//     super.key,
//     required this.claim,
//     required this.postData,
//     required this.onTap,
//     this.onAccept,
//     this.onDecline,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final claimData = claim.data() as Map<String, dynamic>;
//     final claimStatus = claimData['claimStatusC'];
//     final claimerId = claimData['senderId'];
//     final postmakerId = postData['postmakerId'];
//     final isReceived = claimerId != postmakerId;

//     final String title = postData['item'] ?? 'Unknown Item';
//     final String question = postData['question'] ?? '';
//     final String answer = claimData['answer'] ?? '';
//     final Timestamp timestamp = claimData['timestamp'];
//     final String formattedTime =
//         DateFormat('hh:mm a, d MMM yyyy').format(timestamp.toDate());

//     return FutureBuilder<Map<String, dynamic>?>(
//       future: UserService().fetchUserData(claimerId),
//       builder: (context, userSnapshot) {
//         if (!userSnapshot.hasData || userSnapshot.data == null) {
//           return const SizedBox.shrink();
//         }

//         final claimerName = userSnapshot.data!['name'] ?? 'Unknown User';

//         return GestureDetector(
//           onTap: onTap,
//           child: Card(
//             elevation: 4,
//             margin: const EdgeInsets.all(8.0),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Post Title: $title",
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 4),
//                   if (isReceived)
//                     Text("Your Question: $question",
//                         style: const TextStyle(
//                             fontWeight: FontWeight.w500, fontSize: 16)),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text("$claimerName's Answer: ",
//                           style: const TextStyle(
//                               fontSize: 14, color: Colors.blueGrey)),
//                       Expanded(child: Text(answer)),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text('Status: ',
//                           style: TextStyle(
//                               color: _getStatusColor(claimStatus),
//                               fontWeight: FontWeight.bold)),
//                       Text(claimStatus.toString().toUpperCase(),
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text('Time & Date: $formattedTime',
//                       style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                   if (isReceived &&
//                       claimStatus == 'requested' &&
//                       onAccept != null &&
//                       onDecline != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Row(
//                         children: [
//                           ElevatedButton(
//                             onPressed: onAccept,
//                             child: const Text('Accept'),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             onPressed: onDecline,
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red),
//                             child: const Text('Decline'),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'accepted':
//         return Colors.green;
//       case 'declined':
//         return Colors.red;
//       case 'requested':
//       default:
//         return Colors.blue;
//     }
//   }
// }
