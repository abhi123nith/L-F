// // lib/Backend/claims_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ClaimsService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// Fetches a stream of all claims sent by the current user.
//   Stream<QuerySnapshot> getSentClaims(String userId) {
//     return _firestore
//         .collection('posts')
//         .where('postmakerId', isEqualTo: userId)
//         .snapshots();
//   }

//   /// Fetches a stream of all claims received by the current user's posts.
//   Stream<QuerySnapshot> getReceivedClaims(String userId) {
//     return _firestore
//         .collection('posts')
//         .where('postmakerId', isEqualTo: userId)
//         .snapshots();
//   }

//   /// Accepts a claim and updates the post and claim status.
//   Future<void> acceptClaim({
//     required String postId,
//     required String claimId,
//     required String postmakerId,
//     required String claimerId,
//   }) async {
//     final postDocRef = _firestore.collection('posts').doc(postId);
//     final claimDocRef = postDocRef.collection('claims').doc(claimId);

//     await _firestore.runTransaction((transaction) async {
//       final postSnapshot = await transaction.get(postDocRef);
//       if (!postSnapshot.exists) {
//         throw Exception("Post does not exist!");
//       }
//       final postData = postSnapshot.data() as Map<String, dynamic>;

//       if (postData['isClaimed'] == true) {
//         throw Exception("This post has already been claimed.");
//       }

//       transaction.update(postDocRef, {
//         'isClaimed': true,
//         'postClaimer': claimerId,
//       });

//       transaction.update(claimDocRef, {
//         'claimStatusC': 'accepted',
//       });
//     });
//   }

//   /// Declines a claim.
//   Future<void> declineClaim({
//     required String postId,
//     required String claimId,
//   }) async {
//     final claimDocRef = _firestore
//         .collection('posts')
//         .doc(postId)
//         .collection('claims')
//         .doc(claimId);
//     await claimDocRef.update({
//       'claimStatusC': 'declined',
//     });
//   }
// }
