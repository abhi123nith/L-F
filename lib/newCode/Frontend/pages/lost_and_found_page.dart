// // lib/Frontend/pages/lost_found_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:l_f/newCode/Backend/post_service.dart';
// import 'package:l_f/newCode/Frontend/components/filter_dropdowns.dart';
// import 'package:l_f/newCode/Frontend/components/post_card.dart';
// import 'package:l_f/newCode/Frontend/pages/profile/user_see_page.dart';
// import 'package:l_f/newCode/models/post_model.dart';
// import 'package:l_f/newCode/service/user_service.dart';

// class LostFoundPage extends StatefulWidget {
//   const LostFoundPage({super.key});

//   @override
//   State<LostFoundPage> createState() => _LostFoundPageState();
// }

// class _LostFoundPageState extends State<LostFoundPage> {
//   final PostService _postService = PostService();
//   final UserService _userService = UserService();
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   String _selectedType = 'All';
//   String _selectedLocation = 'Campus, NITH';
//   String _selectedCategory = 'All';
//   String _selectedDateRange = 'All Time';

//   Stream<QuerySnapshot>? _postStream;

//   @override
//   void initState() {
//     super.initState();
//     _applyFilters();
//   }

//   void _applyFilters() {
//     setState(() {
//       _postStream = _postService.getFilteredPosts(
//         status: _selectedType,
//         location: _selectedLocation,
//         category: _selectedCategory,
//         dateRange: _selectedDateRange,
//       );
//     });
//   }

//   // Dialog implementations
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
//               onPressed: () async {
//                 try {
//                   await _postService.deletePost(postId);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       backgroundColor: Colors.green,
//                       content: Text('Post deleted successfully'),
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       backgroundColor: Colors.red,
//                       content: Text(e.toString()),
//                     ),
//                   );
//                 }
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showReplyDialog(BuildContext context, String postmakerId, String postmaker, String postId) {
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
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => UserSeePage(uid: postmakerId)),
//                       );
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
//               onPressed: () async {
//                 String message = messageController.text.trim();
//                 if (message.isNotEmpty) {
//                   try {
//                     await _postService.replyToPostmaker(postmakerId, message, postId);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Message sent successfully'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(e.toString()),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
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

//   void _showClaimDialog(BuildContext context, String postmakerId, String postTitle, String postQuestion, String postDescription, String postId) {
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
//               Text(postQuestion, style: const TextStyle(fontWeight: FontWeight.bold)),
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
//               onPressed: () async {
//                 String answer = answerController.text.trim();
//                 if (answer.isNotEmpty) {
//                   try {
//                     await _postService.claimPost(postId, postmakerId, answer);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Request sent successfully'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(e.toString()),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
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
//     bool isMobile = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       body: Column(
//         children: [
//           FilterDropdowns(
//             selectedType: _selectedType,
//             selectedLocation: _selectedLocation,
//             selectedCategory: _selectedCategory,
//             selectedDateRange: _selectedDateRange,
//             onTypeChanged: (newValue) {
//               setState(() => _selectedType = newValue!);
//               _applyFilters();
//             },
//             onLocationChanged: (newValue) {
//               setState(() => _selectedLocation = newValue!);
//               _applyFilters();
//             },
//             onCategoryChanged: (newValue) {
//               setState(() => _selectedCategory = newValue!);
//               _applyFilters();
//             },
//             onDateRangeChanged: (newValue) {
//               setState(() => _selectedDateRange = newValue!);
//               _applyFilters();
//             },
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _postStream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   print('ERROR: ${snapshot.error}');
//                   return const Center(child: Text('Error loading posts'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No posts available'));
//                 }

//                 final posts = snapshot.data!.docs.map((doc) async {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final userDetails = await _userService.fetchUserData(data['postmakerId']);
                  
//                   final claimSnapshot = await FirebaseFirestore.instance
//                       .collection('posts')
//                       .doc(doc.id)
//                       .collection('claims')
//                       .where('senderId', isEqualTo: currentUser!.uid)
//                       .get();
//                   final userHasRequestedClaim = claimSnapshot.docs.isNotEmpty;

//                   return PostModel(
//                     postId: doc.id,
//                     postmakerId: data['postmakerId'] ?? '',
//                     userName: userDetails!['name'] ?? 'NITH User',
//                     profileImageUrl: userDetails['profileImage'] ?? 'https://placehold.co/100x100/png',
//                     status: data['status'] ?? '',
//                     title: data['item'] ?? '',
//                     location: data['location'] ?? '',
//                     description: data['description'] ?? '',
//                     itemImages: List<String>.from(data['imageUrls'] ?? []),
//                     postTime: _formatDate(data['timestamp']),
//                     question: data['question'],
//                     isClaimed: data['isClaimed'] ?? false,
//                     postClaimerId: data['postClaimer'],
//                     postClaimerName: data['postClaimerName'],
//                     postClaimerPic: data['postClaimerPic'],
//                   );
//                 });

//                 return FutureBuilder<List<PostModel>>(
//                   future: Future.wait(posts),
//                   builder: (context, futureSnapshot) {
//                     if (futureSnapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (futureSnapshot.hasError) {
//                       print("Error: ${futureSnapshot.error}");
//                       return const Center(child: Text('Error loading posts'));
//                     }

//                     final postsList = futureSnapshot.data ?? [];
//                     return ListView.builder(
//                       itemCount: postsList.length,
//                       itemBuilder: (context, index) {
//                         final post = postsList[index];
//                         return PostCard(
//                           post: post,
//                           onDelete: () => _showDeleteConfirmationDialog(context, post.postId),
//                           onReply: () => _showReplyDialog(context, post.postmakerId, post.userName, post.postId),
//                           onClaim: () => _showClaimDialog(context, post.postmakerId, post.title, post.question!, post.description, post.postId),
//                           onShare: () => _postService.sharePost(context, post.title, post.description),
//                           currentUserId: currentUser!.uid,
//                           isMobile: isMobile,
//                           // Corrected logic: only show the claim button if the post is "Found" and not already claimed
//                           userHasRequestedClaim: post.isClaimed || post.status == 'Lost',
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
