// // lib/Frontend/pages/chat_detail_page.dart
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:l_f/newCode/Backend/chat_service.dart';
// import 'package:l_f/newCode/Frontend/components/message_bubble.dart';
// import 'package:l_f/newCode/Frontend/components/shimmer_skeleton.dart';
// import 'package:l_f/newCode/Frontend/pages/profile/user_see_page.dart';
// import 'package:l_f/newCode/service/user_service.dart';

// class ChatDetailPage extends StatefulWidget {
//   final String otherUserId;
//   const ChatDetailPage({required this.otherUserId, super.key});

//   @override
//   _ChatDetailPageState createState() => _ChatDetailPageState();
// }

// class _ChatDetailPageState extends State<ChatDetailPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   final ChatService _chatService = ChatService();
//   final UserService _userService = UserService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chat"),
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//       ),
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: _userService.fetchUserData(widget.otherUserId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: ShimmerSkeleton());
//           }
//           if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text('User not found'));
//           }

//           var userData = snapshot.data!;
//           String name = userData['name'] ?? 'Unknown User';
//           String profileImage =
//               userData['profileImage'] ?? 'https://placehold.co/100x100/png';

//           return Column(
//             children: [
//               _buildUserProfileSection(name, profileImage),
//               Expanded(child: _buildChatSection()),
//               _buildMessageInputSection(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildUserProfileSection(String name, String profileImage) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => UserSeePage(uid: widget.otherUserId)),
//         );
//       },
//       child: Card(
//         elevation: 2,
//         child: ListTile(
//           leading: CircleAvatar(
//             radius: 30,
//             backgroundImage: NetworkImage(profileImage),
//           ),
//           title:
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: const Text(
//               '...'), // You can display online status here if implemented
//         ),
//       ),
//     );
//   }

//   Widget _buildChatSection() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _chatService.getChatMessages(widget.otherUserId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: ShimmerSkeleton());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No messages yet'));
//         }

//         final messages = snapshot.data!.docs.where((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           return (data['senderId'] == currentUser!.uid &&
//                   data['receiverId'] == widget.otherUserId) ||
//               (data['senderId'] == widget.otherUserId &&
//                   data['receiverId'] == currentUser!.uid);
//         }).toList();

//         return ListView.builder(
//           reverse: true,
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             var message = messages[index];
//             var data = message.data() as Map<String, dynamic>;

//             final isSentByUser = data['senderId'] == currentUser!.uid;
//             final messageText = data['message'] ?? '';
//             final mediaUrl = data['mediaUrl'] ?? '';
//             final mediaType = data['mediaType'] ?? '';
//             final timestamp = (data['timestamp'] as Timestamp).toDate();

//             return MessageBubble(
//               messageText: messageText,
//               mediaUrl: mediaUrl,
//               mediaType: mediaType,
//               isSentByUser: isSentByUser,
//               timestamp: timestamp,
//               onLongPress: isSentByUser
//                   ? () =>
//                       _showEditDeleteDialog(message.id, messageText, mediaUrl)
//                   : null,
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildMessageInputSection() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.photo),
//             onPressed: _pickImageOrVideo,
//           ),
//           Expanded(
//             child: TextFormField(
//               controller: _messageController,
//               decoration: const InputDecoration(
//                 labelText: 'Type your message...',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: null,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: () {
//               final message = _messageController.text.trim();
//               if (message.isNotEmpty) {
//                 _chatService.sendMessage(
//                   receiverId: widget.otherUserId,
//                   message: message,
//                 );
//                 _messageController.clear();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImageOrVideo() async {
//     final picker = ImagePicker();
//     final XFile? pickedFile =
//         await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       File file = File(pickedFile.path);
//       String fileUrl = await _chatService.uploadFile(file);

//       if (fileUrl.isNotEmpty) {
//         _chatService.sendMessageWithMedia(
//           receiverId: widget.otherUserId,
//           message: '',
//           fileUrl: fileUrl,
//           mediaType: 'image',
//         );
//       }
//     }
//   }

//   void _showEditDeleteDialog(
//       String messageId, String oldText, String mediaUrl) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.edit),
//             title: const Text('Edit'),
//             onTap: () {
//               Navigator.pop(context);
//               _showEditMessageDialog(messageId, oldText);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete),
//             title: const Text('Delete'),
//             onTap: () {
//               Navigator.pop(context);
//               _chatService.deleteMessage(messageId, mediaUrl);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditMessageDialog(String messageId, String oldText) {
//     final TextEditingController editController =
//         TextEditingController(text: oldText);
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Edit Message"),
//           content: TextField(
//             controller: editController,
//             maxLines: null,
//             decoration: const InputDecoration(hintText: "Enter new message"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String updatedText = editController.text.trim();
//                 if (updatedText.isNotEmpty) {
//                   await _chatService.updateMessage(messageId, updatedText);
//                 }
//                 Navigator.pop(context);
//               },
//               child: const Text("Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
