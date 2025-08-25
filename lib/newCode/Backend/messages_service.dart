// // lib/Backend/messages_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MessagesService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   /// Fetches a stream of the latest messages for the current user.
//   Stream<QuerySnapshot> getLatestMessages() {
//     return _firestore
//         .collection('chats')
//         .where('participants', arrayContains: currentUser!.uid)
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }

//   /// Sends a new message in a chat.
//   Future<void> sendMessage({
//     required String receiverId,
//     required String message,
//     required String postId,
//   }) async {
//     if (currentUser == null) return;
//     await _firestore.collection('chats').add({
//       'senderId': currentUser!.uid,
//       'receiverId': receiverId,
//       'participants': [currentUser!.uid, receiverId],
//       'message': message,
//       'postId': postId,
//       'timestamp': Timestamp.now(),
//     });
//   }
// }
