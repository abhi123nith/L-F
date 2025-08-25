// // lib/Frontend/pages/post_details_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:l_f/newCode/Backend/post_service.dart';
// import 'package:l_f/newCode/Frontend/components/post_card.dart';
// import 'package:l_f/newCode/models/post_model.dart';
// import 'package:l_f/newCode/service/user_service.dart';

// class PostDetailsPage extends StatefulWidget {
//   final String postId;
//   const PostDetailsPage({super.key, required this.postId});

//   @override
//   State<PostDetailsPage> createState() => _PostDetailsPageState();
// }

// class _PostDetailsPageState extends State<PostDetailsPage> {
//   final PostService _postService = PostService();
//   final UserService _userService = UserService();
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   late Future<PostModel?> _postFuture;

//   @override
//   void initState() {
//     super.initState();
//     _postFuture = _fetchPostDetails();
//   }

//   Future<PostModel?> _fetchPostDetails() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('posts')
//           .doc(widget.postId)
//           .get();
//       if (!doc.exists) {
//         return null;
//       }
//       final data = doc.data() as Map<String, dynamic>;
//       final userDetails = await _userService.fetchUserData(data['postmakerId']);

//       return PostModel(
//         postId: doc.id,
//         postmakerId: data['postmakerId'] ?? '',
//         userName: userDetails!['name'] ?? 'NITH User',
//         profileImageUrl:
//             userDetails['profileImage'] ?? 'https://placehold.co/100x100/png',
//         status: data['status'] ?? '',
//         title: data['item'] ?? '',
//         location: data['location'] ?? '',
//         description: data['description'] ?? '',
//         itemImages: List<String>.from(data['imageUrls'] ?? []),
//         postTime: _formatDate(data['timestamp']),
//         question: data['question'],
//         isClaimed: data['isClaimed'] ?? false,
//         postClaimerId: data['postClaimer'],
//         postClaimerName: data['postClaimerName'],
//         postClaimerPic: data['postClaimerPic'],
//       );
//     } catch (e) {
//       print("Error fetching post details: $e");
//       return null;
//     }
//   }

//   Future<bool> _hasRequestedClaim(String postId, String userId) async {
//     final claimSnapshot = await FirebaseFirestore.instance
//         .collection('posts')
//         .doc(postId)
//         .collection('claims')
//         .where('senderId', isEqualTo: userId)
//         .get();
//     return claimSnapshot.docs.isNotEmpty;
//   }

//   String _formatDate(Timestamp? timestamp) {
//     if (timestamp == null) return 'Not available';
//     DateTime date = timestamp.toDate();
//     return DateFormat('dd MMMM yyyy').format(date);
//   }

//   // --- Start of new dialog implementations ---
//   void _showDeleteConfirmationDialog(BuildContext context, String postId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Post'),
//           content: const Text(
//             'Are you sure you want to delete this post?',
//             style: TextStyle(fontWeight: FontWeight.w700),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _postService.deletePost(postId);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Yes',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('No',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showReplyDialog(BuildContext context, String postmakerId,
//       String postmaker, String postId) {
//     TextEditingController messageController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Send a Reply'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   const Text('Reply to'),
//                   TextButton(
//                     onPressed: () {
//                       // Navigator.push(context, MaterialPageRoute(builder: (_) => UserSeePage(uid: postmakerId)));
//                     },
//                     child: Text(postmaker),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: messageController,
//                 decoration: const InputDecoration(
//                   labelText: 'Your message',
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 String message = messageController.text.trim();
//                 if (message.isNotEmpty) {
//                   _postService.replyToPostmaker(postmakerId, message, postId);
//                 }
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Send'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showClaimDialog(
//       BuildContext context,
//       String postmakerId,
//       String postTitle,
//       String postQuestion,
//       String postDescription,
//       String postId) {
//     TextEditingController answerController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Claim Item'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Question from the post owner:'),
//               const SizedBox(height: 10),
//               Text(postQuestion,
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: answerController,
//                 decoration: const InputDecoration(
//                   labelText: 'Your answer',
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 String answer = answerController.text.trim();
//                 if (answer.isNotEmpty) {
//                   _postService.claimPost(postmakerId, postId, answer);
//                 }
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Send'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   // --- End of new dialog implementations ---

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//         title: const Text('Post Detail'),
//       ),
//       body: FutureBuilder<PostModel?>(
//         future: _postFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text('Error or post not found.'));
//           }

//           final post = snapshot.data!;
//           return Center(
//             child: SingleChildScrollView(
//               child: PostCard(
//                 post: post,
//                 onDelete: () =>
//                     _showDeleteConfirmationDialog(context, post.postId),
//                 onReply: () => _showReplyDialog(
//                     context, post.postmakerId, post.userName, post.postId),
//                 onClaim: () => _showClaimDialog(context, post.postmakerId,
//                     post.title, post.question!, post.description, post.postId),
//                 onShare: () => _postService.sharePost(
//                     context, post.title, post.description),
//                 currentUserId: currentUser!.uid,
//                 isMobile: isMobile,
//                 userHasRequestedClaim:
//                     false, // This is handled internally in the card for now
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
