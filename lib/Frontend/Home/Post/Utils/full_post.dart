import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l_f/Frontend/Home/Post/post_model.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart';

class PostDetailsPage extends StatefulWidget {
  final String postId;
  const PostDetailsPage({super.key, required this.postId});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final Map<String, Map<String, String>> _userCache = {};
  User? user = FirebaseAuth.instance.currentUser;

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Future<Map<String, String>> fetchUserNameAndProfilePic(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid]!;
    }

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception("User not found.");
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String name = userData['name'] ?? 'NITH User';
      String profileImage = userData['profileImage'] ?? '';

      _userCache[uid] = {
        'name': name,
        'profileImage': profileImage,
      };

      return _userCache[uid]!;
    } catch (e) {
      print("Error fetching user profile: $e");
      throw Exception("Error fetching user profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 830;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: const Text('Post Detail'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('postmakerId', isEqualTo: user!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading posts'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available'));
          }

          final posts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String uid = data['postmakerId'];
            final bool isClaimed = data['isClaimed'] ?? false;
            final String? claimerUid = data['postClaimer'];
            print("post claimerasss: : $claimerUid");
            print("POST IDDDDDDDD : ${data['postId']}");
            print("Is Post Claimed: $isClaimed");

            return fetchUserNameAndProfilePic(uid).then((userDetails) async {
              String postClaimerName = '';
              String postClaimerProfilePic = '';

              if (isClaimed && claimerUid != null) {
                final claimerDetails =
                    await fetchUserNameAndProfilePic(claimerUid);
                postClaimerName = claimerDetails['name'] ?? 'NITH User';
                postClaimerProfilePic = claimerDetails['profileImage'] ?? '';
              }

              return PostModel(
                userName: userDetails['name'] ?? 'NITH User',
                profileImageUrl: userDetails['profileImage'] ?? '',
                postTime: _formatDate(data['timestamp']),
                itemImages: List<String>.from(
                    data['imageUrls'] ?? ['assets/nith_logo.png']),
                status: data['status'] ?? '',
                title: data['item'] ?? '',
                location: data['location'] ?? '',
                description: data['description'] ?? '',
                postmakerId: data['postmakerId'],
                question: data['question'],
                postId: data['postId'],
                claimStatus: data['claimStatus'],
                isClaimed: isClaimed,
                postclaimerId: data['postClaimer'],
                postClaimer:
                    postClaimerName.isNotEmpty ? postClaimerName : null,
                postClaimerPic: postClaimerProfilePic.isNotEmpty
                    ? postClaimerProfilePic
                    : null,
              );
            });
          });

          return FutureBuilder<List<PostModel>>(
            future: Future.wait(posts.toList()),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (futureSnapshot.hasError) {
                print("Error : ${futureSnapshot.error}");
                return const Center(child: Text('Error loading posts'));
              }

              final postsList = futureSnapshot.data ?? [];

              return ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (context, index) {
                  final post = postsList[index];
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: SizedBox(
                        width:
                            isMobile ? MediaQuery.of(context).size.width : 600,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header  of the POST (profiel,name.location,delete)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProfilePage2(
                                              uid: post.postmakerId)));
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        NetworkImage(post.profileImageUrl),
                                  ),
                                  title: Text(post.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      "Location : ${post.location} , NITH"),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'Delete') {
                                        if (user!.uid == post.postmakerId) {
                                          _showDeleteConfirmation(
                                              context, post);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                    "You can't delete this post")),
                                          );
                                        }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return {'Delete'}.map((String choice) {
                                        return PopupMenuItem<String>(
                                          value: choice,
                                          child: Text(choice),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),

                              // LOST OR FOUND
                              Stack(
                                children: [
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      autoPlay: true,
                                      height: 500.0,
                                      enlargeCenterPage: true,
                                    ),
                                    items:
                                        post.itemImages.map<Widget>((imageUrl) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Stack(
                                                  children: [
                                                    Image.network(imageUrl),
                                                    Positioned(
                                                      right: 10,
                                                      top: 10,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.cancel,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.error);
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  Positioned(
                                    top: isMobile ? 16 : 6,
                                    left: 50,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: post.status == 'Lost'
                                            ? Colors.red
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        post.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ITEM item,date
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          post.title == 'Other'
                                              ? '${post.status} Item'
                                              : post.title,
                                          overflow: TextOverflow.clip,
                                          softWrap: true,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 5),
                                        Row(
                                          children: [
                                            Text("${post.status} On : ",
                                                overflow: TextOverflow.clip,
                                                softWrap: true,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(post.postTime,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),

                                    //DESCRIPTION
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align text to the top
                                      children: [
                                        const Text(
                                          "Description : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            post.description,
                                            overflow: TextOverflow.clip,
                                            softWrap: true,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    //BUTTONNS
                                    StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(post.postId)
                                            .collection('claims')
                                            .where('senderId',
                                                isEqualTo: user!.uid)
                                            .snapshots(),
                                        builder: (context, claimSnapshot) {
                                          if (claimSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          bool userHasRequestedClaim = false;

                                          if (claimSnapshot.hasData &&
                                              claimSnapshot
                                                  .data!.docs.isNotEmpty) {
                                            final claimData = claimSnapshot
                                                .data!.docs.first
                                                .data() as Map<String, dynamic>;

                                            if (claimData['claimStatusC'] ==
                                                'requested') {
                                              userHasRequestedClaim = true;
                                            }
                                            if (claimData['claimStatusC'] ==
                                                    'accepted' ||
                                                claimData['claimStatusC'] ==
                                                    'declined') {
                                              userHasRequestedClaim = false;
                                            }
                                          }

                                          return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _sharePost(
                                                        context,
                                                        post.title,
                                                        post.description);
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.share_rounded),
                                                      SizedBox(width: 3),
                                                      Text('Share'),
                                                    ],
                                                  ),
                                                ),

                                                if (post.postmakerId !=
                                                    user!.uid)
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      _replyToPostmaker(
                                                          context,
                                                          post.postmakerId,
                                                          post.userName,
                                                          post.postId);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green.shade600,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.reply,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          'Reply',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                //Claimed Button
                                                if (post.status != 'Lost' &&
                                                    post.isClaimed == true)
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      _claimedPost(
                                                          context,
                                                          post.postclaimerId!,
                                                          post.title,
                                                          post.postClaimer!,
                                                          post.postId);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors
                                                          .deepOrange.shade600,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.back_hand,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          'Claimed',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                // Claim Buttton
                                                if (post.postmakerId !=
                                                        user!.uid &&
                                                    post.status == 'Found' &&
                                                    post.isClaimed == false &&
                                                    !userHasRequestedClaim)
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      _claimPost(
                                                          context,
                                                          post.postmakerId,
                                                          post.title,
                                                          post.question!,
                                                          post.description,
                                                          post.postId);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors
                                                          .deepOrange.shade600,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.back_hand,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          'Claim',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                // Request Button
                                                if (post.postmakerId !=
                                                        user!.uid &&
                                                    post.status == 'Found' &&
                                                    post.isClaimed == false &&
                                                    userHasRequestedClaim)
                                                  ElevatedButton(
                                                    onPressed: () {},
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors
                                                          .deepOrange.shade600,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.back_hand,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          'Requested',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              ]);
                                        })
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _replyToPostmaker(BuildContext context, String postmakerId,
      String postmaker, String postId) {
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send a Reply'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Reply to'),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProfilePage2(uid: postmakerId)));
                      },
                      child: Text(postmaker))
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Your message',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without sending
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String message = messageController.text.trim();
                if (message.isNotEmpty) {
                  _sendMessageToPostmaker(
                      context, postmakerId, message, postId);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent successfully'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.0),
                  ),
                );
                Navigator.of(context).pop(); // Close the dialog after sending
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessageToPostmaker(BuildContext context, String postmakerId,
      String message, String postId) async {
    try {
      // Add a chat message to Firestore
      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': user!.uid,
        'receiverId': postmakerId,
        'participants': [user!.uid, postmakerId],
        'message': message,
        'postId': postId,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.0),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _claimPost(BuildContext context, String postmakerId, String postTitle,
      String postQuestion, String postdescription, String postId) {
    TextEditingController answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Claim Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Question from the post owner:'),
              const SizedBox(height: 10),
              Text(postQuestion,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Your answer',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String answer = answerController.text.trim();
                if (answer.isNotEmpty) {
                  _sendAnswerToPostmaker(
                      context, answer, postId, postmakerId, 'requested');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request sent successfully'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.0),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _claimedPost(BuildContext context, String postclaimerId,
      String postTitle, String claimername, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Claimed Item : $postTitle',
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Already claimed by :',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProfilePage2(uid: postclaimerId)));
                      },
                      child: Text(
                          user!.uid == postclaimerId ? 'You' : claimername,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendAnswerToPostmaker(
    BuildContext context,
    String answer,
    String postId,
    String postmakerId,
    String statusofRequest,
  ) async {
    try {
      // Reference to the specific post's claims subcollection
      CollectionReference claimsRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId) // Get the post document using its ID
          .collection('claims'); // Access the subcollection

      // Add a new claim document
      await claimsRef.add({
        'senderId': user!.uid,
        'answer': answer,
        'claimStatusC': statusofRequest,
        'timestamp': Timestamp.now(),
        'isClaimed': false,
        'receiverId': postmakerId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your answer has been sent to the post maker'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.0),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send answer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sharePost(BuildContext context, String title, String description) {
    final content = 'Check out this post: $title\nDescription: $description';
    final snackBar = SnackBar(content: Text('Shared! $content'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(post.postId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
    );
  }
}
