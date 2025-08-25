import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/ChatPage/userchatpage.dart';
import 'package:l_f/Frontend/Home/Post/Utils/full_post.dart';
import 'package:l_f/Frontend/MyList/my_posts.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart';

class MessagesPage extends StatefulWidget {
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var slideAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Fetch user profile (name and profile image)
  Future<Map<String, dynamic>?> _fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: const Text('Messages and Claims'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Messages'),
            Tab(text: 'Claims'),
            Tab(text: 'My Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessagesTab(),
          _buildClaimsTab(), // Claims Tab
          const MyPostsPage()
        ],
      ),
    );
  }

// Build Messages Tab
  Widget _buildMessagesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('receiverId', isEqualTo: user!.uid)
          .snapshots(),
      builder: (context, receivedSnapshot) {
        // Show loading indicator if the first snapshot is still loading
        if (receivedSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ShimmerSkeleton());
        }

        // Fetch sent messages by the current user
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('senderId', isEqualTo: user!.uid)
              .snapshots(),
          builder: (context, sentSnapshot) {
            if (sentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: ShimmerSkeleton());
            }

            if (sentSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No Messags available'));
            }

            var sentMessages = sentSnapshot.data?.docs ?? [];
            var receivedMessages = receivedSnapshot.data?.docs ?? [];

            // Combine sent and received messages
            var allMessages = [...sentMessages, ...receivedMessages];

            // Map to store the latest message per user
            Map<String, DocumentSnapshot> latestMessages = {};

            for (var message in allMessages) {
              var otherUserId = message['senderId'] == user!.uid
                  ? message['receiverId']
                  : message['senderId'];

              // Check if this is the latest message for the other user
              if (!latestMessages.containsKey(otherUserId) ||
                  (message['timestamp'] as Timestamp).toDate().isAfter(
                      (latestMessages[otherUserId]!['timestamp'] as Timestamp)
                          .toDate())) {
                latestMessages[otherUserId] = message;
              }
            }

            // Sort messages by timestamp (latest first)
            var sortedMessages = latestMessages.values.toList()
              ..sort((a, b) => (b['timestamp'] as Timestamp)
                  .compareTo(a['timestamp'] as Timestamp));

            // Build the UI
            return ListView.builder(
              itemCount: sortedMessages.length,
              itemBuilder: (context, index) {
                var message = sortedMessages[index];
                var isSentByUser = message['senderId'] == user!.uid;
                var otherUserId =
                    isSentByUser ? message['receiverId'] : message['senderId'];
                var messageText = message['message'];
                var timestamp = (message['timestamp'] as Timestamp).toDate();

                // Fetch the profile of the other user
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _fetchUserProfile(otherUserId),
                  builder: (context, userSnapshot) {
                    // While the user profile is loading, show a placeholder
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ShimmerSkeleton();
                    }

                    // If user data is available, show the message
                    if (userSnapshot.hasData && userSnapshot.data != null) {
                      var userProfile = userSnapshot.data!;
                      String userName = userProfile['name'] ?? 'Unknown User';
                      String userProfileImage =
                          userProfile['profileImage'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: userProfileImage.isNotEmpty
                                  ? NetworkImage(userProfileImage)
                                  : const AssetImage(
                                          'assets/default_avatar.png')
                                      as ImageProvider,
                            ),
                            title: Text(
                              isSentByUser ? ' $userName' : ' $userName',
                              style: TextStyle(
                                fontWeight: isSentByUser
                                    ? FontWeight.bold
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Show last message regardless of who sent it
                                Text(
                                  messageText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}, ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 500),
                                  pageBuilder: (_, __, ___) =>
                                      ChatDetailPage(otherUserId: otherUserId),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      // When user data is not found, show an empty state
                      return const SizedBox(
                        height: 60, // Adjust height as needed
                        child: ListTile(
                          title: Text('User not found'),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildClaimsTab() {
    return DefaultTabController(
      length: 2, // Two tabs: Sent and Received
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Sent Claims'),
              Tab(text: 'Received Claims'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSentClaimsTab(),
                _buildReceivedClaimsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentClaimsTab() {
    bool isMobile = MediaQuery.of(context).size.width < 830;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: ShimmerSkeleton());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No Sent Claims available'));
        }

        var posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var postId = post.id;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('claims')
                  .where('senderId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, claimSnapshot) {
                if (!claimSnapshot.hasData) {
                  return const Center(
                      child: SizedBox(child: Center(child: ShimmerSkeleton())));
                }

                if (claimSnapshot.hasError) {
                  print('Error : ${snapshot.error}');
                  return const Center(child: Text('Error in loading !!!'));
                }

                var claims = claimSnapshot.data!.docs;
                print("SENT DATA ::: $claims");

                return Column(
                  children: claims.map((claim) {
                    var claimResponse = claim['answer'];
                    var timestamp = (claim['timestamp'] as Timestamp).toDate();
                    var claimStatus = claim['claimStatusC'];

                    return GestureDetector(
                      onTap: () {
                        print('Status: $claimStatus');
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) =>
                                PostDetailsPage(postId: postId),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: SizedBox(
                        width:
                            isMobile ? MediaQuery.of(context).size.width : 500,
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Post Title: ${post['item']}", // Assuming post has a title field
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Question: ${post['question']}", // Assuming post has a title field
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Your Answer: $claimResponse",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.blueGrey),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      'Status: ',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      post['claimStatus'] == 'accepted'
                                          ? 'Accepted'
                                          : claimStatus == 'declined'
                                              ? ' Declined'
                                              : 'Requested ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}, ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReceivedClaimsTab() {
    bool isMobile = MediaQuery.of(context).size.width < 830;

    // Main stream for posts
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Show a single CircularProgressIndicator while the posts are loading
        if (!snapshot.hasData) {
          return const Center(child: ShimmerSkeleton());
        }

        // If no posts are available, show the no data message
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No Received Claims available'));
        }

        // Retrieve the list of posts
        var posts = snapshot.data!.docs;

        // Build the list once all posts are loaded
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var postId = post.id;

            // Claim stream for each post
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('claims') // Access the claims sub-collection
                  .where('receiverId',
                      isEqualTo:
                          user!.uid) // Filter for claims received by the user
                  .snapshots(),
              builder: (context, claimSnapshot) {
                // Skip rendering this post if claims are still loading
                if (!claimSnapshot.hasData) {
                  return const Center(
                      child:
                          ShimmerSkeleton()); // Avoid showing loading indicator per post
                }

                var claims = claimSnapshot.data!.docs;

                // Display all claims for this post
                return Column(
                  children: claims.map((claim) {
                    var claimResponse = claim['answer'];
                    var timestamp = (claim['timestamp'] as Timestamp).toDate();
                    var senderId = claim['senderId'];
                    var claimStatus = claim['claimStatusC'];

                    print("Received DATA ::: $claims");

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(senderId)
                          .get(), // Fetching user details for the claimer
                      builder: (context, userSnapshot) {
                        // Skip rendering the card until the claimer's user data is loaded
                        if (!userSnapshot.hasData) {
                          return Container(); // Avoid showing a progress indicator here
                        }

                        var claimerName = userSnapshot.data!['name'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                                pageBuilder: (_, __, ___) =>
                                    PostDetailsPage(postId: postId),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: SizedBox(
                            width: isMobile
                                ? MediaQuery.of(context).size.width
                                : 500,
                            child: Card(
                              elevation: 4,
                              margin: EdgeInsets.all(isMobile ? 8.0 : 18),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, left: 12, right: 12, bottom: 9),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Post Title : ${post['item']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Your Question: ${post['question']}",
                                      softWrap: true,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "$claimerName's Answer: $claimResponse",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.blueGrey),
                                    ),
                                    Text(
                                      'Time & Date : ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}, ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    (post['claimStatus'] == 'accepted' &&
                                            post['isClaimed'] == true)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Accepted by you'),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Claimed by :',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.green),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          print(
                                                              "Sender ID: $senderId");
                                                          Navigator.of(context).push(
                                                              _createSmoothRoute(
                                                                  ProfilePage2(
                                                                      uid: senderId)));
                                                        },
                                                        child: Text(
                                                          '$claimerName',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .green),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        : (claimStatus == 'requested')
                                            ? Row(
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        _acceptclaimPost(
                                                            postId,
                                                            post['postmakerId'],
                                                            senderId,
                                                            claimResponse);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .deepOrange),
                                                      child:
                                                          const Text('Accept')),
                                                  const SizedBox(width: 7),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        _declinedclaimPost(
                                                            postId, claim.id);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .deepOrange),
                                                      child: const Text(
                                                          'Decline')),
                                                ],
                                              )
                                            : (claimStatus == 'declined')
                                                ? Column(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Claimed By :$claimerName ',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                          ),
                                                          const Text(
                                                            ' Your Response : Declined',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                : const Text('Error'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _acceptclaimPost(String postId, String postmakerId,
      String claimerId, String answer) async {
    try {
      final postDocRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final claimsDocRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('claims')
          .doc(claimerId);

      await postDocRef.update({
        'postClaimer': claimerId,
        'answer': answer,
        'claimStatus': 'accepted',
        'isClaimed': true,
      });
      await claimsDocRef.update({
        'claimStatusC': 'accepted',
        'isClaimed': true,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post claimed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      print('Post claimed successfully!');
    } catch (e) {
      print('Error claiming post: $e');
    }
  }

  Future<void> _declinedclaimPost(String postId, String claimerId) async {
    try {
      final claimsDocRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('claims')
          .doc(claimerId);

      // Update Firestore with the declined status
      await claimsDocRef.update({
        'claimStatusC': 'declined',
      });

      // Show a SnackBar notification for user feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim rejected by you'),
          backgroundColor: Colors.red,
        ),
      );

      // Firestore will notify the StreamBuilder of the change automatically,
      // so no need for additional state management here.
      print('Post rejected successfully!');
    } catch (e) {
      print('Error declining post: $e');
    }
  }
}
