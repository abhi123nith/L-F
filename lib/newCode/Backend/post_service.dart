// // lib/Backend/post_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class PostService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   /// Deletes a post from Firestore. Throws an exception on failure.
//   Future<void> deletePost(String postId) async {
//     try {
//       await _firestore.collection('posts').doc(postId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete post: $e');
//     }
//   }

//   /// Sends a message to the post maker. Throws an exception on failure.
//   Future<void> replyToPostmaker(
//       String postmakerId, String message, String postId) async {
//     try {
//       if (currentUser == null) throw Exception('User not authenticated.');
//       if (message.isEmpty) return;

//       await _firestore.collection('chats').add({
//         'senderId': currentUser!.uid,
//         'receiverId': postmakerId,
//         'participants': [currentUser!.uid, postmakerId],
//         'message': message,
//         'postId': postId,
//         'timestamp': Timestamp.now(),
//       });
//     } catch (e) {
//       throw Exception('Failed to send message: $e');
//     }
//   }

//   /// Sends a claim request to the post owner. Throws an exception on failure.
//   Future<void> claimPost(
//       String postId, String postmakerId, String answer) async {
//     try {
//       if (currentUser == null) throw Exception('User not authenticated.');

//       final claimsRef =
//           _firestore.collection('posts').doc(postId).collection('claims');

//       await claimsRef.add({
//         'senderId': currentUser!.uid,
//         'answer': answer,
//         'claimStatusC': 'requested',
//         'timestamp': Timestamp.now(),
//         'receiverId': postmakerId,
//       });
//     } catch (e) {
//       throw Exception('Failed to send claim request: $e');
//     }
//   }

//   /// Handles sharing a post. This remains a UI function.
//   void sharePost(BuildContext context, String title, String description) {
//     final content = 'Check out this post: $title\nDescription: $description';
//     final snackBar = SnackBar(content: Text('Shared! $content'));
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   /// Fetches a stream of posts from Firestore with optional filtering.
//   Stream<QuerySnapshot> getFilteredPosts({
//     required String status,
//     required String location,
//     required String category,
//     required String dateRange,
//     String? postmakerId, // Add optional postmakerId filter
//   }) {
//     Query query = _firestore.collection('posts');

//     if (status != 'All') {
//       query = query.where('status', isEqualTo: status);
//     }
//     if (location != 'Campus, NITH') {
//       query = query.where('location', isEqualTo: location);
//     }
//     if (category != 'All') {
//       query = query.where('item', isEqualTo: category);
//     }
//     if (postmakerId != null) {
//       // Apply postmakerId filter if it exists
//       query = query.where('postmakerId', isEqualTo: postmakerId);
//     }

//     DateTime now = DateTime.now();
//     DateTime? startDate;
//     switch (dateRange) {
//       case 'Today':
//         startDate = DateTime(now.year, now.month, now.day);
//         break;
//       case 'This Week':
//         startDate = now.subtract(Duration(days: now.weekday - 1));
//         break;
//       case 'This Month':
//         startDate = DateTime(now.year, now.month, 1);
//         break;
//       case 'This Year':
//         startDate = DateTime(now.year, 1, 1);
//         break;
//       default:
//         startDate = null;
//     }

//     if (startDate != null) {
//       query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
//     }

//     return query.orderBy('timestamp', descending: true).snapshots();
//   }
// }
