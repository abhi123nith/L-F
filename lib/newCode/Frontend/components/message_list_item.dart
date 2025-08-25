// // lib/Frontend/components/message_list_item.dart
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Frontend/pages/chat_detail_page.dart';

// class MessageListItem extends StatelessWidget {
//   final String otherUserId;
//   final String userName;
//   final String userProfileImage;
//   final String messageText;
//   final bool isSentByUser;
//   final String formattedTimestamp;

//   const MessageListItem({
//     super.key,
//     required this.otherUserId,
//     required this.userName,
//     required this.userProfileImage,
//     required this.messageText,
//     required this.isSentByUser,
//     required this.formattedTimestamp,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child: Card(
//         elevation: 4,
//         child: ListTile(
//           leading: CircleAvatar(
//             backgroundImage: userProfileImage.isNotEmpty
//                 ? NetworkImage(userProfileImage)
//                 : const AssetImage('assets/default_avatar.png')
//                     as ImageProvider,
//           ),
//           title: Text(
//             isSentByUser ? 'You to $userName' : userName,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Text(
//             messageText,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           trailing: Text(
//             formattedTimestamp,
//             style: const TextStyle(fontSize: 12, color: Colors.grey),
//           ),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       ChatDetailPage(otherUserId: otherUserId)),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
