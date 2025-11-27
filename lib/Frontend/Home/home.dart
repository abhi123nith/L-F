import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:l_f/Frontend/Contants/lists.dart';
import 'package:l_f/Frontend/Home/Post/post_model.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart';
import 'package:l_f/constants/api_keys.dart';
import 'package:l_f/newCode/Frontend/pages/create_post/ai_create_post_page.dart';
import 'package:share_plus/share_plus.dart';

class LostFoundPage extends StatefulWidget {
  const LostFoundPage({super.key});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  final Map<String, Map<String, String>> _userCache =
      {}; // Cache to store user data
  User? user = FirebaseAuth.instance.currentUser;
  // String? postId;

  List<PostModel> _filteredPosts = [];

  // Function to fetch filtered posts from Firestore
  void _filterPosts(
      String status, String location, DateTime? uploadDate, String title) {
    Query query = FirebaseFirestore.instance.collection('posts');

    // Apply filters
    if (status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    if (location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }
    if (uploadDate != null) {
      query = query.where('uploadDate', isEqualTo: uploadDate);
    }
    if (title.isNotEmpty) {
      query = query.where('itemTitle', isEqualTo: title);
    }

    // Get the results and update the UI
    query.get().then((snapshot) {
      setState(() {
        _filteredPosts = snapshot.docs
            .map((doc) => PostModel.fromJson(doc as Map<String, dynamic>))
            .toList();
      });
    });
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Future<void> _deletePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Post deleted successfully'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.0),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to delete post: $e')),
      );
    }
  }

  // --- ADD THIS METHOD 1: To submit a report to Firestore ---
  Future<void> _submitReport(
      BuildContext context, PostModel post, String reason,
      {String? details}) async {
    if (user == null) return; // User must be logged in to report

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'postId': post.postId,
        'postOwnerId': post.postmakerId,
        'reporterId': user!.uid,
        'reason': reason,
        'details': details ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // For moderation tracking
      });

      if (!mounted) return;
      Navigator.of(context).pop(); // Close the report dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Report submitted successfully. Thank you.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to submit report: $e'),
        ),
      );
    }
  }

  // --- ADD THIS METHOD 2: To show the report dialog ---
  void _showReportDialog(BuildContext context, PostModel post) {
    String? selectedReason;
    final otherReasonController = TextEditingController();
    final reportReasons = [
      'Spam or Misleading',
      'Inappropriate Content',
      'Potential Scam',
      'Harassment',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Report Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...reportReasons.map((reason) => RadioListTile<String>(
                          title: Text(reason),
                          value: reason,
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedReason = value;
                            });
                          },
                        )),
                    if (selectedReason == 'Other')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: otherReasonController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Please provide details...',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null // Disable button until a reason is selected
                      : () {
                          _submitReport(
                            dialogContext,
                            post,
                            selectedReason!,
                            details: selectedReason == 'Other'
                                ? otherReasonController.text
                                : null,
                          );
                        },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>> _fetchUserNameAndProfilePic(String uid) async {
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

  Stream<QuerySnapshot>? _postStream;

  @override
  void initState() {
    super.initState();
    // Initialize stream without filters
    _postStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _applyFilters() {
    // Start with the collection reference
    Query query = FirebaseFirestore.instance.collection('posts');

    // Apply Type filter (Lost/Found)
    if (selectedType != 'All') {
      query = query.where('status', isEqualTo: selectedType);
    }

    // Apply Location filter
    if (selectedLocation != 'Campus, NITH') {
      query = query.where('location', isEqualTo: selectedLocation);
    }

    // Apply Item Category filter
    if (selectedCategory != 'All') {
      query = query.where('item', isEqualTo: selectedCategory);
    }

    // Apply Date filter (based on upload timestamp)
    DateTime now = DateTime.now();
    DateTime? startDate;

    switch (selectedDateRange) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = null;
    }

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }

    // Update the stream for the StreamBuilder
    setState(() {
      _postStream = query.orderBy('timestamp', descending: true).snapshots();
    });
  }

  String selectedType = 'All';
  String selectedLocation = 'Campus, NITH';
  String selectedCategory = 'All';
  String selectedDateRange = 'All Time';

// Dummy lists for dropdowns (replace with your provided lists)
  List<String> itemTypes = ['All', 'Lost', 'Found'];
  List<String> locations = locationsList;
  List<String> categories = [
    'All',
    'Mobile Phone',
    'Laptop',
    'Charger',
    'Wallet',
    'ID Card',
    'Hoodie',
    'Jacket/Coat',
    'Bat',
    'Electronics Item',
    'Cloth',
    'Belt',
    'Ball',
    'Book',
    'Earphones',
    'Earbuds',
    'Water Bottle',
    'Watch',
    'Specs',
    'Jewellry',
    'Shoes',
    'Keys',
    'Umbrella',
    'Other'
  ];
  List<String> dateRanges = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];

// Filter Dropdowns
  Widget buildDropdowns() {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDropdown(selectedType, itemTypes, (newValue) {
              setState(() {
                selectedType = newValue!;
              });
              _applyFilters();
            }),
            const SizedBox(width: 10),
            buildDropdown(selectedLocation, locations, (newValue) {
              setState(() {
                selectedLocation = newValue!;
              });
              _applyFilters();
            }),
            const SizedBox(width: 10),
            buildDropdown(selectedCategory, categories, (newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
              _applyFilters();
            }),
            const SizedBox(width: 10),
            buildDropdown(selectedDateRange, dateRanges, (newValue) {
              setState(() {
                selectedDateRange = newValue!;
              });
              _applyFilters();
            }),
          ],
        ),
      );
    });
  }

// Helper method to create a DropdownButton
  Widget buildDropdown(String selectedValue, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: buildDropdowns()),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _postStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('ERROR ${snapshot.error}');
                  return const Center(child: Text('Error loading posts'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Center(child: Text('No posts available')));
                }

                final posts = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String uid = data['postmakerId'];
                  final bool isClaimed = data['isClaimed'] ?? false;
                  final String? claimerUid = data['postClaimer'];
                  print("post claimerasss: : $claimerUid");
                  print("POST IDDDDDDDD : ${data['postId']}");
                  print("Is Post Claimed: $isClaimed");

                  return _fetchUserNameAndProfilePic(uid)
                      .then((userDetails) async {
                    String postClaimerName = '';
                    String postClaimerProfilePic = '';

                    if (isClaimed && claimerUid != null) {
                      final claimerDetails =
                          await _fetchUserNameAndProfilePic(claimerUid);
                      postClaimerName = claimerDetails['name'] ?? 'NITH User';
                      postClaimerProfilePic = claimerDetails['profileImage']!;
                    }

                    return PostModel(
                      userName: userDetails['name'] ?? 'NITH User',
                      profileImageUrl: userDetails['profileImage'] ??
                          'https://static.wikia.nocookie.net/logopedia/images/e/ec/220px-National_Institute_of_Technology,_Hamirpur_Logo.png/revision/latest?cb=20200330143312',
                      postTime: _formatDate(data['timestamp']),
                      itemImages: List<String>.from(data['imageUrls'] ?? ''),
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
                    if (futureSnapshot.connectionState ==
                        ConnectionState.waiting) {
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
                              width: isMobile
                                  ? MediaQuery.of(context).size.width
                                  : 600,
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
                                        // print(
                                        //     'EROROR ::: ${post.profileImageUrl}');
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                                milliseconds:
                                                    400), // smoothness
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                ProfilePage2(
                                                    uid: post.postmakerId),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              // Curve for smoother effect
                                              final curvedAnimation =
                                                  CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOut,
                                              );

                                              return SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(1.0,
                                                      0.0), // start from right
                                                  end: Offset.zero,
                                                ).animate(curvedAnimation),
                                                child: FadeTransition(
                                                  opacity: curvedAnimation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                              post.profileImageUrl),
                                        ),
                                        title: Text(post.userName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            "Location : ${post.location} , NITH"),
                                        // --- REPLACE the existing trailing property with this ---
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'Delete') {
                                              // Assumes _showDeleteConfirmation is defined elsewhere in your class
                                              _showDeleteConfirmation(
                                                  context, post);
                                            } else if (value == 'Report') {
                                              _showReportDialog(context, post);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            List<PopupMenuEntry<String>>
                                                menuItems = [];

                                            // Only show the delete option if the current user is the owner
                                            if (user?.uid == post.postmakerId) {
                                              menuItems.add(
                                                const PopupMenuItem<String>(
                                                  value: 'Delete',
                                                  child: Text('Delete'),
                                                ),
                                              );
                                            }

                                            // Always show the report option for other users' posts
                                            if (user?.uid != post.postmakerId) {
                                              menuItems.add(
                                                const PopupMenuItem<String>(
                                                  value: 'Report',
                                                  child: Text('Report'),
                                                ),
                                              );
                                            }
                                            return menuItems;
                                          },
                                        ),
                                        // trailing: PopupMenuButton<String>(
                                        //   onSelected: (value) {
                                        //     if (value == 'Delete') {
                                        //       if (user!.uid ==
                                        //           post.postmakerId) {
                                        //         _showDeleteConfirmation(
                                        //             context, post);
                                        //       } else {
                                        //         ScaffoldMessenger.of(context)
                                        //             .showSnackBar(
                                        //           const SnackBar(
                                        //               backgroundColor:
                                        //                   Colors.red,
                                        //               content: Text(
                                        //                   "You can't delete this post")),
                                        //         );
                                        //       }
                                        //     }
                                        //   },
                                        //   itemBuilder: (BuildContext context) {
                                        //     return {'Delete'}
                                        //         .map((String choice) {
                                        //       return PopupMenuItem<String>(
                                        //         value: choice,
                                        //         child: Text(choice),
                                        //       );
                                        //     }).toList();
                                        //   },
                                        // ),
                                      ),
                                    ),

                                    // LOST OR FOUND
                                    Stack(
                                      children: [
                                        CarouselSlider(
                                          options: CarouselOptions(
                                            autoPlay: true,
                                            height: 450.0,
                                            enlargeCenterPage: true,
                                          ),
                                          items: post.itemImages
                                              .map<Widget>((imageUrl) {
                                            return GestureDetector(
                                              onTap: () {
                                                // Open image viewer when the image is tapped
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullScreenImageViewer(
                                                            post.itemImages,
                                                            isMobile),
                                                  ),
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
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(width: 5),
                                              Row(
                                                children: [
                                                  Text("${post.status} On : ",
                                                      overflow:
                                                          TextOverflow.clip,
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
                                              builder:
                                                  (context, claimSnapshot) {
                                                if (claimSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }

                                                bool userHasRequestedClaim =
                                                    false;

                                                if (claimSnapshot.hasData &&
                                                    claimSnapshot.data!.docs
                                                        .isNotEmpty) {
                                                  final claimData =
                                                      claimSnapshot
                                                              .data!.docs.first
                                                              .data()
                                                          as Map<String,
                                                              dynamic>;

                                                  if (claimData[
                                                          'claimStatusC'] ==
                                                      'requested') {
                                                    userHasRequestedClaim =
                                                        true;
                                                  }
                                                  if (claimData[
                                                              'claimStatusC'] ==
                                                          'accepted' ||
                                                      claimData[
                                                              'claimStatusC'] ==
                                                          'declined') {
                                                    userHasRequestedClaim =
                                                        false;
                                                  }
                                                }

                                                return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          _sharePost(
                                                              context,
                                                              post.title,
                                                              post.description,
                                                              post.postId);
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Icon(Icons
                                                                .share_rounded),
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
                                                                Colors.green
                                                                    .shade600,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(Icons.reply,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                  width: 3),
                                                              Text(
                                                                'Reply',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                      //Claimed Button
                                                      if (post.status !=
                                                              'Lost' &&
                                                          post.isClaimed ==
                                                              true)
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
                                                            backgroundColor:
                                                                Colors
                                                                    .deepOrange
                                                                    .shade600,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .back_hand,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                  width: 3),
                                                              Text(
                                                                'Claimed',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                      // Claim Buttton
                                                      if (post.postmakerId !=
                                                              user!.uid &&
                                                          post.status ==
                                                              'Found' &&
                                                          post.isClaimed ==
                                                              false &&
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
                                                            backgroundColor:
                                                                Colors
                                                                    .deepOrange
                                                                    .shade600,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .back_hand,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                'Claim',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                      // Request Button
                                                      if (post.postmakerId !=
                                                              user!.uid &&
                                                          post.status ==
                                                              'Found' &&
                                                          post.isClaimed ==
                                                              false &&
                                                          userHasRequestedClaim)
                                                        ElevatedButton(
                                                          onPressed: () {},
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .deepOrange
                                                                    .shade600,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .back_hand,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                  width: 3),
                                                              Text(
                                                                'Requested',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AICreatePostPage(geminiApiKey: geminiApiKey),
            ),
          );
        },
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.auto_fix_high),
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
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 400), // smoothness
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ProfilePage2(uid: postmakerId),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              // Curve for smoother effect
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(
                                      1.0, 0.0), // start from right
                                  end: Offset.zero,
                                ).animate(curvedAnimation),
                                child: FadeTransition(
                                  opacity: curvedAnimation,
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
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
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 400), // smoothness
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ProfilePage2(uid: postclaimerId),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              // Curve for smoother effect
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(
                                      1.0, 0.0), // start from right
                                  end: Offset.zero,
                                ).animate(curvedAnimation),
                                child: FadeTransition(
                                  opacity: curvedAnimation,
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
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

  void _sharePost(BuildContext context, String title, String description,
      [String? postId]) async {
    final postLink = postId != null
        ? 'https://nithlostandfoundweb.netlify.app/post/$postId'
        : '';
    final content = postId != null
        ? 'Check out this post: $title\nDescription: $description\n\nLink: $postLink\n\nShared from Lost & Found NITH app'
        : 'Check out this post: $title\nDescription: $description\n\nShared from Lost & Found NITH app';

    try {
      // Share the content with link
      await Share.share(content);

      // Show a success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared successfully!')),
      );
    } catch (e) {
      print('Error sharing post: $e');

      // Fallback for web or platforms where share is not supported
      await Clipboard.setData(ClipboardData(text: content));

      // Show a snackbar with fallback message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Link copied to clipboard! You can now share it manually.')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    // postId = post.postId;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
            'Are you sure you want to delete this post?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Call your delete functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      backgroundColor: Colors.deepOrange,
                      content: Text('Post deleted successfully')),
                );

                await _deletePost(context, post.postId);

                Navigator.of(context).pop();
              },
              child: const Text(
                'Yes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'No',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  bool isMobile;
  FullScreenImageViewer(this.images, this.isMobile, {super.key});

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black.withOpacity(0.8), // Background color for overlay
      body: Stack(
        children: [
          PageView.builder(
            itemCount: widget.images.length,
            controller: PageController(initialPage: _currentIndex),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.network(
                  width: widget.isMobile
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 0.5,
                  widget.images[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
