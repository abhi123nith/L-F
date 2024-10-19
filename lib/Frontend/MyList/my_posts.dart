import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l_f/Frontend/Home/Post/post_model.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final Map<String, Map<String, String>> _userCache =
      {}; // Cache to store user data
  User? user = FirebaseAuth.instance.currentUser;
  String? postId;
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Future<void> _deletePost(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.0),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<Map<String, String>> fetchUserNameAndProfilePic(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid]!; // Return cached data if available
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

      // Cache the user data
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .where('postmakerId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error : ${snapshot.error}");
            return const Center(child: Text('Error loading posts'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available'));
          }
          final postDocs = snapshot.data!.docs;

          final postsFutures = postDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String uid = data['postmakerId'];

            return fetchUserNameAndProfilePic(uid).then((userDetails) {
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
                postId: doc.id,
              );
            });
          });

          return FutureBuilder<List<PostModel>>(
            future:
                Future.wait(postsFutures), // Wait for all futures to complete
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (futureSnapshot.hasError) {
                return const Center(child: Text('Error loading posts'));
              }

              final postsList = futureSnapshot.data ?? [];

              return ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (context, index) {
                  final post = postsList[index];
                  return Padding(
                    padding: EdgeInsets.all(isMobile ? 2 : 8.0),
                    child: Center(
                      child: SizedBox(
                        width: isMobile ? size.width : 600,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                    //    radius: 40,
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
                              Stack(
                                children: [
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      autoPlay: true,
                                      height: 400.0,
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
                                            width: 500,
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
                                    top: isMobile ? 10 : 2,
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 10 : 58.0,
                                    vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          post.title == 'Other'
                                              ? '${post.status} Item'
                                              : post.title,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: isMobile ? 0 : 5),
                                        Row(
                                          children: [
                                            Text("${post.status} On : ",
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
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align text to the start
                                      children: [
                                        const Text(
                                          "Description : ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            post.description,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _sharePost(context, post.title,
                                                post.description);
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.share_rounded),
                                              SizedBox(width: 5),
                                              Text('Share'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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

  void _sharePost(BuildContext context, String title, String description) {
    final content = 'Check out this post: $title\nDescription: $description';
    final snackBar = SnackBar(content: Text('Shared! $content'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    postId = post.postId;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () async {
                // Call your delete functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      backgroundColor: Colors.deepOrange,
                      content: Text('Post deleted successfully')),
                );

                await _deletePost(context);

                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
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
          child: Stack(
            children: [
              Image.network(imageUrl),
              Positioned(
                right: 10,
                top: 10,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
