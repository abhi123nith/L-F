// // lib/Frontend/pages/messages_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:l_f/newCode/Backend/claims_service.dart';
// import 'package:l_f/newCode/Backend/messages_service.dart';
// import 'package:l_f/newCode/Frontend/components/claim_list_item.dart';
// import 'package:l_f/newCode/Frontend/components/message_list_item.dart';
// import 'package:l_f/newCode/Frontend/pages/my_posts/my_post_page.dart';
// import 'package:l_f/newCode/Frontend/pages/post_details_page.dart';
// import 'package:l_f/newCode/service/user_service.dart';

// class MessagesPage extends StatefulWidget {
//   const MessagesPage({super.key});

//   @override
//   State<MessagesPage> createState() => _MessagesPageState();
// }

// class _MessagesPageState extends State<MessagesPage>
//     with SingleTickerProviderStateMixin {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   late TabController _tabController;

//   final MessagesService _messagesService = MessagesService();
//   final ClaimsService _claimsService = ClaimsService();
//   final UserService _userService = UserService();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (currentUser == null) {
//       return const Scaffold(
//         body: Center(
//             child: Text('Please log in to view your messages and claims.')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//         title: const Text('Messages and Claims'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Messages'),
//             Tab(text: 'Claims'),
//             Tab(text: 'My Posts'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildMessagesTab(),
//           _buildClaimsTab(),
//           const MyPostsPage(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessagesTab() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _messagesService.getLatestMessages(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No Messages available'));
//         }

//         var latestMessagesMap = <String, DocumentSnapshot>{};
//         for (var doc in snapshot.data!.docs) {
//           var data = doc.data() as Map<String, dynamic>;
//           var otherUserId = data['senderId'] == currentUser!.uid
//               ? data['receiverId']
//               : data['senderId'];
//           if (!latestMessagesMap.containsKey(otherUserId)) {
//             latestMessagesMap[otherUserId] = doc;
//           }
//         }

//         var sortedMessages = latestMessagesMap.values.toList()
//           ..sort((a, b) => (b['timestamp'] as Timestamp)
//               .compareTo(a['timestamp'] as Timestamp));

//         return ListView.builder(
//           itemCount: sortedMessages.length,
//           itemBuilder: (context, index) {
//             var message = sortedMessages[index];
//             var isSentByUser = message['senderId'] == currentUser!.uid;
//             var otherUserId =
//                 isSentByUser ? message['receiverId'] : message['senderId'];

//             return FutureBuilder<Map<String, dynamic>?>(
//               future: _userService.fetchUserData(otherUserId),
//               builder: (context, userSnapshot) {
//                 if (userSnapshot.connectionState == ConnectionState.waiting) {
//                   return const ListTile(title: Text('Loading user...'));
//                 }

//                 if (!userSnapshot.hasData || userSnapshot.data == null) {
//                   return const SizedBox();
//                 }

//                 var userProfile = userSnapshot.data!;
//                 return MessageListItem(
//                   otherUserId: otherUserId,
//                   userName: userProfile['name'] ?? 'Unknown User',
//                   userProfileImage: userProfile['profileImage'] ??
//                       'https://placehold.co/100x100/png',
//                   messageText: message['message'],
//                   isSentByUser: isSentByUser,
//                   formattedTimestamp: DateFormat('hh:mm a, d MMM yyyy')
//                       .format((message['timestamp'] as Timestamp).toDate()),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildClaimsTab() {
//     return DefaultTabController(
//       length: 2,
//       child: Column(
//         children: [
//           const TabBar(
//             tabs: [
//               Tab(text: 'Sent Claims'),
//               Tab(text: 'Received Claims'),
//             ],
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 _buildSentClaimsTab(),
//                 _buildReceivedClaimsTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSentClaimsTab() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _claimsService.getSentClaims(currentUser!.uid),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No Sent Claims available'));
//         }

//         final postsWithClaims = snapshot.data!.docs.where((postDoc) {
//           final postData = postDoc.data() as Map<String, dynamic>;
//           final postmakerId = postData['postmakerId'];
//           return postmakerId != currentUser!.uid;
//         }).toList();

//         return ListView.builder(
//           itemCount: postsWithClaims.length,
//           itemBuilder: (context, index) {
//             final post = postsWithClaims[index];
//             final postData = post.data() as Map<String, dynamic>;
//             final postId = post.id;

//             return StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('posts')
//                   .doc(postId)
//                   .collection('claims')
//                   .where('senderId', isEqualTo: currentUser!.uid)
//                   .snapshots(),
//               builder: (context, claimSnapshot) {
//                 if (!claimSnapshot.hasData ||
//                     claimSnapshot.data!.docs.isEmpty) {
//                   return const SizedBox.shrink();
//                 }

//                 final claim = claimSnapshot.data!.docs.first;
//                 return ClaimListItem(
//                   claim: claim,
//                   postData: postData,
//                   onTap: () {
//                     // Navigate to post details
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => PostDetailsPage(postId: postId)));
//                   },
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildReceivedClaimsTab() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _claimsService.getReceivedClaims(currentUser!.uid),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No Received Claims available'));
//         }

//         final postsWithClaims = snapshot.data!.docs.where((postDoc) {
//           final postData = postDoc.data() as Map<String, dynamic>;
//           final postmakerId = postData['postmakerId'];
//           return postmakerId == currentUser!.uid;
//         }).toList();

//         return ListView.builder(
//           itemCount: postsWithClaims.length,
//           itemBuilder: (context, index) {
//             final post = postsWithClaims[index];
//             final postData = post.data() as Map<String, dynamic>;
//             final postId = post.id;

//             return StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('posts')
//                   .doc(postId)
//                   .collection('claims')
//                   .where('receiverId', isEqualTo: currentUser!.uid)
//                   .snapshots(),
//               builder: (context, claimSnapshot) {
//                 if (!claimSnapshot.hasData ||
//                     claimSnapshot.data!.docs.isEmpty) {
//                   return const SizedBox.shrink();
//                 }

//                 final claim = claimSnapshot.data!.docs.first;
//                 return ClaimListItem(
//                   claim: claim,
//                   postData: postData,
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => PostDetailsPage(postId: postId)));
//                   },
//                   onAccept: () {
//                     _claimsService.acceptClaim(
//                       postId: postId,
//                       claimId: claim.id,
//                       postmakerId: postData['postmakerId'],
//                       claimerId: claim['senderId'],
//                     );
//                   },
//                   onDecline: () {
//                     _claimsService.declineClaim(
//                         postId: postId, claimId: claim.id);
//                   },
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
