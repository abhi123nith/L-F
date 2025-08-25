// // lib/Backend/chat_service.dart
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   /// Fetches a stream of messages between the current user and another user.
//   Stream<QuerySnapshot> getChatMessages(String otherUserId) {
//     if (currentUser == null) {
//       throw Exception('User not authenticated');
//     }

//     // Get chat ID by combining UIDs to ensure a unique chat for two users
//     List<String> participants = [currentUser!.uid, otherUserId];
//     participants.sort();
//     participants.join('_');

//     return _firestore
//         .collection('chats')
//         .where('participants', arrayContains: currentUser!.uid)
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }

//   /// Sends a new text message.
//   Future<void> sendMessage({
//     required String receiverId,
//     required String message,
//     String postId = '',
//   }) async {
//     if (currentUser == null || message.isEmpty) return;

//     await _firestore.collection('chats').add({
//       'senderId': currentUser!.uid,
//       'receiverId': receiverId,
//       'participants': [currentUser!.uid, receiverId],
//       'message': message,
//       'postId': postId,
//       'timestamp': Timestamp.now(),
//       'mediaUrl': '',
//       'mediaType': '',
//     });
//   }

//   /// Sends a new message with attached media.
//   Future<void> sendMessageWithMedia({
//     required String receiverId,
//     required String message,
//     required String fileUrl,
//     required String mediaType,
//   }) async {
//     if (currentUser == null) return;
//     await _firestore.collection('chats').add({
//       'senderId': currentUser!.uid,
//       'receiverId': receiverId,
//       'participants': [currentUser!.uid, receiverId],
//       'message': message,
//       'postId': '',
//       'timestamp': Timestamp.now(),
//       'mediaUrl': fileUrl,
//       'mediaType': mediaType,
//     });
//   }

//   /// Uploads a file (image/video) to Firebase Storage.
//   Future<String> uploadFile(File file) async {
//     try {
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       Reference storageRef = _storage.ref().child('chats/$fileName');

//       UploadTask uploadTask = storageRef.putFile(file);
//       TaskSnapshot taskSnapshot = await uploadTask;
//       String fileUrl = await taskSnapshot.ref.getDownloadURL();
//       return fileUrl;
//     } catch (e) {
//       print("Error uploading file: $e");
//       return '';
//     }
//   }

//   /// Deletes a message from Firestore and its associated media from Storage.
//   Future<void> deleteMessage(String messageId, String mediaUrl) async {
//     try {
//       if (mediaUrl.isNotEmpty) {
//         await _storage.refFromURL(mediaUrl).delete();
//       }
//       await _firestore.collection('chats').doc(messageId).delete();
//     } catch (e) {
//       print("Error deleting message: $e");
//     }
//   }

//   /// Updates an existing message with new text.
//   Future<void> updateMessage(String messageId, String newText) async {
//     try {
//       await _firestore
//           .collection('chats')
//           .doc(messageId)
//           .update({'message': newText});
//     } catch (e) {
//       print("Error updating message: $e");
//     }
//   }
// }
