// // lib/Frontend/components/message_bubble.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MessageBubble extends StatelessWidget {
//   final String messageText;
//   final String mediaUrl;
//   final String mediaType;
//   final bool isSentByUser;
//   final DateTime timestamp;
//   final VoidCallback? onLongPress;

//   const MessageBubble({
//     super.key,
//     required this.messageText,
//     required this.mediaUrl,
//     required this.mediaType,
//     required this.isSentByUser,
//     required this.timestamp,
//     this.onLongPress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final formattedTime = DateFormat('hh:mm a').format(timestamp);
//     final alignment = isSentByUser ? Alignment.centerRight : Alignment.centerLeft;
//     final color = isSentByUser ? Colors.blue[200] : Colors.grey[300];

//     return GestureDetector(
//       onLongPress: onLongPress,
//       child: Align(
//         alignment: alignment,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (mediaUrl.isNotEmpty && mediaType == 'image')
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(mediaUrl, height: 150),
//                 ),
//               if (messageText.isNotEmpty)
//                 Text(
//                   messageText,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               const SizedBox(height: 4),
//               Text(
//                 formattedTime,
//                 style: const TextStyle(fontSize: 10, color: Colors.black54),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
