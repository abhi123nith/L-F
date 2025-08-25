// // lib/Frontend/pages/my_posts_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:l_f/newCode/Backend/post_service.dart';
// import 'package:l_f/newCode/Frontend/components/post_card.dart';
// import 'package:l_f/newCode/models/post_model.dart';
// import 'package:l_f/newCode/service/user_service.dart';
// // Import dialogs

// class MyPostsPage extends StatefulWidget {
//   const MyPostsPage({super.key});

//   @override
//   State<MyPostsPage> createState() => _MyPostsPageState();
// }

// class _MyPostsPageState extends State<MyPostsPage> {
//   final PostService _postService = PostService();
//   final UserService _userService = UserService();
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   Stream<QuerySnapshot>? _postStream;

//   @override
//   void initState() {
//     super.initState();
//     if (currentUser != null) {
//       _postStream = _postService.getFilteredPosts(
//         status: 'All',
//         location: 'Campus, NITH',
//         category: 'All',
//         dateRange: 'All Time',
//         postmakerId: currentUser!.uid,
//       );
//     }
//   }

//   // Dialog implementations for post interactions
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
//                   _postService.claimPost(postId, postmakerId, answer);
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

//   String _formatDate(Timestamp? timestamp) {
//     if (timestamp == null) return 'Not available';
//     DateTime date = timestamp.toDate();
//     return DateFormat('dd MMMM yyyy').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (currentUser == null) {
//       return const Center(child: Text('Please log in to view your posts.'));
//     }

//     bool isMobile = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Posts'),
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _postStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             print('ERROR: ${snapshot.error}');
//             return const Center(child: Text('Error loading posts'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//                 child: Text('You have not created any posts yet.'));
//           }

//           final posts = snapshot.data!.docs.map((doc) async {
//             final data = doc.data() as Map<String, dynamic>;
//             final userDetails =
//                 await _userService.fetchUserData(data['postmakerId']);

//             // For MyPostsPage, the user has always requested a claim on their own posts (it's their own post)

//             return PostModel(
//               postId: doc.id,
//               postmakerId: data['postmakerId'] ?? '',
//               userName: userDetails!['name'] ?? 'NITH User',
//               profileImageUrl: userDetails['profileImage'] ??
//                   'https://placehold.co/100x100/png',
//               status: data['status'] ?? '',
//               title: data['item'] ?? '',
//               location: data['location'] ?? '',
//               description: data['description'] ?? '',
//               itemImages: List<String>.from(data['imageUrls'] ?? []),
//               postTime: _formatDate(data['timestamp']),
//               question: data['question'],
//               isClaimed: data['isClaimed'] ?? false,
//               postClaimerId: data['postClaimer'],
//               postClaimerName: data['postClaimerName'],
//               postClaimerPic: data['postClaimerPic'],
//             );
//           });

//           return FutureBuilder<List<PostModel>>(
//             future: Future.wait(posts),
//             builder: (context, futureSnapshot) {
//               if (futureSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (futureSnapshot.hasError) {
//                 print("Error: ${futureSnapshot.error}");
//                 return const Center(child: Text('Error loading posts'));
//               }

//               final postsList = futureSnapshot.data ?? [];
//               return ListView.builder(
//                 itemCount: postsList.length,
//                 itemBuilder: (context, index) {
//                   final post = postsList[index];
//                   return PostCard(
//                     post: post,
//                     onDelete: () =>
//                         _showDeleteConfirmationDialog(context, post.postId),
//                     onReply: () => _showReplyDialog(
//                         context, post.postmakerId, post.userName, post.postId),
//                     onClaim: () => _showClaimDialog(
//                         context,
//                         post.postmakerId,
//                         post.title,
//                         post.question!,
//                         post.description,
//                         post.postId),
//                     onShare: () => _postService.sharePost(
//                         context, post.title, post.description),
//                     currentUserId: currentUser!.uid,
//                     isMobile: isMobile,
//                     userHasRequestedClaim: false,
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
